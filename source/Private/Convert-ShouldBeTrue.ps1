<#
    .SYNOPSIS
        Converts a command `Should -BeTrue` to the specified Pester syntax.

    .DESCRIPTION
        The Convert-ShouldBeTrue function is used to convert a command `Should -BeTrue` to
        the specified Pester syntax.

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
        $commandAst = [System.Management.Automation.Language.Parser]::ParseInput('Should -BeTrue')
        Convert-ShouldBeTrue -CommandAst $commandAst -Pester6

        This example converts the `Should -BeTrue` command to Pester 6 syntax.

    .NOTES
        Pester 5 Syntax:
            Should -BeTrue [[-ActualValue] <Object>] [[-Because] <string>] [-Not]

            Positional parameters:
                Position 1: Because
                Position 2: ActualValue

        Pester 6 Syntax:
            Should-BeTrue [[-Actual] <Object>] [[-Because] <String>]

            Positional parameters:
                Position 1: Actual
                Position 2: Because

        Conversion notes:
            If the Pester 5 syntax is negated it must be converted to Should-BeFalse.

            If the Pester 5 syntax uses positional parameters, the conversion must
            convert position 1 to position 2 and vice versa.
#>
function Convert-ShouldBeTrue
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
        if ($isNegated)
        {
            $newExtentText = 'Should-BeFalse'
        }
        else
        {
            $newExtentText = 'Should-BeTrue'
        }

        $getPesterCommandParameterParameters = @{
            CommandAst          = $CommandAst
            CommandName         = 'Should'
            IgnoreParameter     = 'BeTrue', 'Not'
            PositionalParameter = 'Because', 'ActualValue'
        }

        $commandParameters = Get-PesterCommandParameter @getPesterCommandParameterParameters

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
            if ($commandParameters.Because)
            {
                $commandParameters.Because.Positional = $true

                if ($commandParameters.ActualValue)
                {
                    $commandParameters.ActualValue.Positional = $true
                }
            }
        }

        $newExtentText += $commandParameters.ActualValue.Positional ? (' {0}' -f $commandParameters.ActualValue.ExtentText) : ''

        if ($commandParameters.Because)
        {
            # Only add second positional if the first positional was present.
            if ($commandParameters.ActualValue.Positional)
            {
                $newExtentText += $commandParameters.Because.Positional ? (' {0}' -f $commandParameters.Because.ExtentText) : ''
            }
            else
            {
                $commandParameters.Because.Positional = $false
            }
        }

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

            $newExtentText += ' -{0} {1}' -f $currentParameter, $commandParameters.$originalParameterName.ExtentText
        }
    }

    Write-Debug -Message ($script:localizedData.Convert_Should_Debug_ConvertedCommand -f $CommandAst.Extent.Text, $newExtentText)

    return $newExtentText
}
