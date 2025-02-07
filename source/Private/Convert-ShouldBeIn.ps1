<#
    .SYNOPSIS
        Converts a command `Should -BeIn` to the specified Pester syntax.

    .DESCRIPTION
        The Convert-ShouldContain function is used to convert a command `Should -BeIn`
        to the specified Pester syntax.

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
        $commandAst = [System.Management.Automation.Language.Parser]::ParseInput('Should -BeIn @("Test", "Test2")')
        Convert-ShouldContain -CommandAst $commandAst -Pester6

        This example converts the `Should -BeIn @("Test", "Test2")` command to Pester 6 syntax.

    .NOTES
        Pester 5 Syntax:
            Should -BeIn [[-ActualValue] <Object>] [[-ExpectedValue] <Object>] [[-Because] <string>] [-Not]

            Positional parameters:
                Position 1: ExpectedValue
                Position 2: Because
                Position 3: ActualValue

        Pester 6 Syntax:
            Should-ContainCollection [-Actual] <Object>] [-Expected] <Object> [-Because <String>]
            Should-NotContainCollection [[-Actual] <Object>] [-Expected] <Object> [-Because <String>]

            Positional parameters:
                Position 1: Expected
                Position 2: Actual
#>
function Convert-ShouldBeIn
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
        $newExtentText = $isNegated ? 'Should-NotContainCollection' : 'Should-ContainCollection'

        $getPesterCommandParameterParameters = @{
            CommandAst          = $CommandAst
            CommandName         = 'Should'
            IgnoreParameter     = @(
                'BeIn'
                'Not'
            )
            PositionalParameter = @(
                'ExpectedValue'
                'Because'
                'ActualValue'
            )
            NamedParameter      = @()
        }

        $commandParameters = Get-PesterCommandParameter @getPesterCommandParameterParameters

        $pipelineExtentText = Get-PipelineBeforeShould -CommandAst $CommandAst -ParsePipeline

        # NOTE! This switches the arguments between expected and actual values.
        $originalActualValue = $commandParameters.ActualValue
        $commandParameters.ActualValue = $commandParameters.ExpectedValue
        $commandParameters.ExpectedValue = $originalActualValue

        # If we do not end up with a value for ExpectValue we need to get it from the pipeline.
        $isPipeline = $null -eq $commandParameters.ExpectedValue

        if ($isPipeline)
        {
            <#
                ActualValue was not part of the arguments as either positional or
                named parameter, assume there is a pipeline and the original
                ActualValue should be converted to Expected. Also using the
                position and positional property values from original ActualValue
                for the new ExpectedValue.
            #>
            $commandParameters.ExpectedValue = @{
                Position   = $commandParameters.ActualValue.Position
                Positional = $commandParameters.ActualValue.Positional
                ExtentText = '({0})' -f $pipelineExtentText
            }

            <#
                We must put the new actual value on the pipeline before the Should
                command, so we need to make sure it is not added as positional.
            #>
            $commandParameters.ActualValue.Position = 0
            $commandParameters.ActualValue.Positional = $false
        }

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
            if ($commandParameters.ExpectedValue)
            {
                $commandParameters.ExpectedValue.Positional = $true

                # If the actual value was originally passed in the pipeline, we should do the same.
                if ($commandParameters.ActualValue -and -not $isPipeline)
                {
                    $commandParameters.ActualValue.Positional = $true
                }
            }
        }

        $newExtentText += $commandParameters.ExpectedValue.Positional ? (' {0}' -f $commandParameters.ExpectedValue.ExtentText) : ''
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
                    if ($isPipeline)
                    {
                        continue
                    }

                    $parameterNames += @{
                        Actual = 'ActualValue'
                    }

                    break
                }

                'ExpectedValue'
                {
                    $parameterNames += @{
                        Expected = 'ExpectedValue'
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

    if ($isPipeline)
    {
        $newExtentText = '{0} | {1}' -f $commandParameters.ActualValue.ExtentText, $newExtentText
    }

    Write-Debug -Message ($script:localizedData.Convert_Should_Debug_ConvertedCommand -f $CommandAst.Extent.Text, $newExtentText)

    return $newExtentText
}
