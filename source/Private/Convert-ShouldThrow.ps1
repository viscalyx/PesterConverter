<#
    .SYNOPSIS
        Converts a command `Should -Throw` to the specified Pester syntax.

    .DESCRIPTION
        The Convert-ShouldBe function is used to convert a command `Should -Throw` to
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
        $commandAst = [System.Management.Automation.Language.Parser]::ParseInput('Should -Throw "Test"')
        Convert-ShouldThrow -CommandAst $commandAst -Pester6

        This example converts the `Should -Throw "Test"` command to Pester 6 syntax.

    .NOTES
        Pester 5 Syntax:
            Should -Throw [[-ActualValue] <Object>] [[-ExpectedMessage] <string>] [[-ErrorId] <string>] [[-ExceptionType] <type>] [[-Because] <string>] [-Not] [-PassThru]

            Positional parameters:
                Position 1: ExpectedMessage
                Position 2: ErrorId
                Position 3: ExceptionType
                Position 4: Because

        Pester 6 Syntax:
            Should-Throw [-ScriptBlock] <ScriptBlock> [[-ExceptionType] <Type>] [[-ExceptionMessage] <String>] [[-FullyQualifiedErrorId] <String>] [-AllowNonTerminatingError] [[-Because] <String>]

            Positional parameters:
                Position 1: ExceptionMessage
                Position 2: FullyQualifiedErrorId
                Position 3: ExceptionType
                Position 4: Because

        Conversion notes:
            PassThru is the default in Pester 6, so it can be ignored in the conversion.
            But must be handled if it can have negative impact were it was not used
            before.

            TODO: Verify the positional parameters in next v6 alpha, and that they
                  are only the four. The code below assume they will be the same
                  as v5 in a future v6 alpha.
#>
function Convert-ShouldThrow
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
        BoundParameterList = $PSBoundParameters
        MutuallyExclusiveList1 = @('UseNamedParameters')
        MutuallyExclusiveList2 = @('UsePositionalParameters')
    }

    Assert-BoundParameter @assertBoundParameterParameters

    Write-Debug -Message ('Parsing the command AST: {0}' -f $CommandAst.Extent.Text)

    # Determine if the command is negated
    $isNegated = Test-PesterCommandNegated -CommandAst $CommandAst

    $sourceSyntaxVersion = Get-PesterCommandSyntaxVersion -CommandAst $CommandAst

    # Parse the command elements and convert them to Pester 6 syntax
    if ($PSCmdlet.ParameterSetName -eq 'Pester6')
    {
        Write-Debug -Message ('Converting from Pester v{0} to Pester v6 syntax.' -f $sourceSyntaxVersion)

        # Add the correct Pester command based on negation
        if ($isNegated)
        {
            #$shouldThrowNotImplementedMessage = $script:localizedData.ShouldThrow_NotImplemented

            $PSCmdlet.ThrowTerminatingError(
                [System.Management.Automation.ErrorRecord]::new(
                    'Convert-ShouldThrow should not be called with a negation parameter. Call Convert-ShouldNotThrow instead.', #$shouldThrowNotImplementedMessage,
                    'CST0001', # cspell: disable-line
                    [System.Management.Automation.ErrorCategory]::NotImplemented,
                    $CommandAst.Extent.Text
                )
            )
        }
        else
        {
            $newExtentText = 'Should-Throw'
        }

        $getPesterCommandParameterParameters = @{
            CommandAst = $CommandAst
            CommandName = 'Should'
            IgnoreParameter = @(
                'Throw'
                'Not'
                'PassThru'
            )
            PositionalParameter = @(
                'ExpectedMessage'
                'ErrorId'
                'ExceptionType'
                'Because'
            )
            NamedParameter = @(
                'ActualValue'
            )
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
            if ($commandParameters.ExpectedMessage)
            {
                $commandParameters.ExpectedMessage.Positional = $true

                if ($commandParameters.ErrorId)
                {
                    $commandParameters.ErrorId.Positional = $true

                    if ($commandParameters.ExceptionType)
                    {
                        $commandParameters.ExceptionType.Positional = $true

                        if ($commandParameters.Because)
                        {
                            $commandParameters.Because.Positional = $true
                        }
                    }
                }
            }
        }

        $newExtentText += $commandParameters.ExpectedMessage.Positional ? (' {0}' -f $commandParameters.ExpectedMessage.ExtentText) : ''
        $newExtentText += $commandParameters.ErrorId.Positional ? (' {0}' -f $commandParameters.ErrorId.ExtentText) : ''
        $newExtentText += $commandParameters.ExceptionType.Positional ? (' {0}' -f $commandParameters.ExceptionType.ExtentText) : ''
        $newExtentText += $commandParameters.Because.Positional ? (' {0}' -f $commandParameters.Because.ExtentText) : ''

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
                'ExpectedMessage'
                {
                    $parameterNames += @{
                        ExceptionMessage = 'ExpectedMessage'
                    }

                    break
                }

                'ErrorId'
                {
                    $parameterNames += @{
                        FullyQualifiedErrorId = 'ErrorId'
                    }

                    break
                }

                'ActualValue'
                {
                    $parameterNames += @{
                        ScriptBlock = 'ActualValue'
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

    Write-Debug -Message ('Converted the command `{0}` to `{1}`.' -f $CommandAst.Extent.Text, $newExtentText)

    return $newExtentText
}
