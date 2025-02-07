<#
    .SYNOPSIS
        Converts a command `Should -MatchExactly` to the specified Pester syntax.

    .DESCRIPTION
        The Convert-ShouldMatchExactly function is used to convert a command
        `Should -MatchExactly` to the specified Pester syntax.

    .PARAMETER CommandAst
        The CommandAst object representing the command to be converted.

    .PARAMETER Pester6
        Specifies that the command should be converted to Pester version 6 syntax.

    .PARAMETER UseNamedParameters
        Specifies whether to use named parameters in the converted syntax.

    .PARAMETER UsePositionalParameters
        Specifies whether to use positional parameters in the converted syntax,
        where supported.

    .EXAMPLE
        $commandAst = [System.Management.Automation.Language.Parser]::ParseInput('Should -MatchExactly "Test"')
        Convert-ShouldMatchExactly -CommandAst $commandAst -Pester6

        This example converts the `Should -MatchExactly "Test"` command to Pester 6 syntax.

    .NOTES
        Pester 5 Syntax:
            Should -MatchExactly [[-ActualValue] <Object>] [-Not] [[-ExpectedValue] <Object>] [-Because <Object>]

            Positional parameters:
                Position 1: ExpectedValue
                Position 2: Because
                Position 3: ActualValue

        Pester 6 Syntax:
            Should-BeString [[-Actual] <Object>] [[-Expected] <String>] [-Because <String>] [-CaseSensitive] [-IgnoreWhitespace]
            Should-NotBeString [[-Actual] <Object>] [[-Expected] <String>] [-Because <String>] [-CaseSensitive] [-IgnoreWhitespace]

            Positional parameters:
                Position 1: Expected
                Position 2: Actual
#>
function Convert-ShouldMatchExactly
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.Language.CommandAst]
        $CommandAst,

        [Parameter(Mandatory = $true, ParameterSetName = 'Pester6')]
        [System.Management.Automation.SwitchParameter]
        $Pester6,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $UseNamedParameters,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $UsePositionalParameters
    )

    $assertBoundParameterParameters = @{
        BoundParameterList     = $PSBoundParameters
        MutuallyExclusiveList1 = @('UseNamedParameters')
        MutuallyExclusiveList2 = @('UsePositionalParameters')
    }

    Assert-BoundParameter @assertBoundParameterParameters

    Write-Debug -Message ($script:localizedData.Convert_Should_Debug_ParsingCommandAst -f $CommandAst.Extent.Text)

    # Determine if the command is negated
    $isNegated = Test-PesterCommandNegated -CommandAst $CommandAst

    $sourceSyntaxVersion = Get-PesterCommandSyntaxVersion -CommandAst $CommandAst

    # Parse the command elements and convert them to Pester 6 syntax
    if ($PSCmdlet.ParameterSetName -eq 'Pester6')
    {
        Write-Debug -Message ($script:localizedData.Convert_Should_Debug_ConvertingFromTo -f $sourceSyntaxVersion, '6')

        # Add the correct Pester command based on negation
        $newExtentText = $isNegated ? 'Should-NotMatchString' : 'Should-MatchString'

        # Always add the `-CaseSensitive` parameter since MatchExactly was case-sensitive.
        $newExtentText += ' -CaseSensitive'

        $getPesterCommandParameterParameters = @{
            CommandAst          = $CommandAst
            CommandName         = 'Should'
            IgnoreParameter     = @(
                'CMATCH'
                'MatchExactly'
                'Not'
            )
            PositionalParameter = @(
                'RegularExpression'
                'Because'
                'ActualValue'
            )
        }

        $commandParameters = Get-PesterCommandParameter @getPesterCommandParameterParameters

        # Parameter 'Because' is only supported as named parameter in Pester 6 syntax.
        if ($commandParameters.Because)
        {
            $commandParameters.Because.Positional = $false
        }

        # Determine if named or positional parameters should be forcibly used
        if ($UseNamedParameters.IsPresent)
        {
            $commandParameters.Keys.ForEach({ $commandParameters.$_.Positional = $false })
        }
        elseif ($UsePositionalParameters.IsPresent)
        {
            # First set all to named parameters
            $commandParameters.Keys.ForEach({ $commandParameters.$_.Positional = $false })

            <#
                If a previous positional parameter is missing then the ones behind
                it cannot be set to positional.
            #>
            if ($commandParameters.RegularExpression)
            {
                $commandParameters.RegularExpression.Positional = $true

                if ($commandParameters.ActualValue)
                {
                    $commandParameters.ActualValue.Positional = $true
                }
            }
        }

        $newExtentText += $commandParameters.RegularExpression.Positional ? (' {0}' -f $commandParameters.RegularExpression.ExtentText) : ''
        $newExtentText += $commandParameters.ActualValue.Positional ? (' {0}' -f $commandParameters.ActualValue.ExtentText) : ''

        # Holds the new parameter names so they can be added in alphabetical order.
        $parameterNames = @()

        foreach ($currentParameter in $commandParameters.Keys)
        {
            if ($commandParameters.$currentParameter.Positional -eq $true)
            {
                continue
            }

            switch ($currentParameter)
            {
                'ActualValue'
                {
                    $parameterNames += @{
                        Actual = 'ActualValue'
                    }

                    break
                }

                'RegularExpression'
                {
                    $parameterNames += @{
                        Expected = 'RegularExpression'
                    }

                    break
                }

                default
                {
                    $parameterNames += @{
                        $currentParameter = $currentParameter
                    }

                    break
                }
            }
        }

        # This handles the named parameters in the command elements, added in alphabetical order.
        foreach ($currentParameter in $parameterNames.Keys | Sort-Object)
        {
            $originalParameterName = $parameterNames.$currentParameter

            $newExtentText += ' -{0}' -f $currentParameter

            if ($commandParameters.$originalParameterName.ExtentText)
            {
                $newExtentText += ' {0}' -f $commandParameters.$originalParameterName.ExtentText
            }
        }
    }

    Write-Debug -Message ($script:localizedData.Convert_Should_Debug_ConvertedCommand -f $CommandAst.Extent.Text, $newExtentText)

    return $newExtentText
}
