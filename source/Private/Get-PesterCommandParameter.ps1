<#
    .SYNOPSIS
        Get all the parameters of a Pester command.

    .DESCRIPTION
        The Get-PesterCommandParameter function returns all of parameter command
        elements.

    .PARAMETER CommandAst
        Specifies the CommandAst object representing the command.

    .PARAMETER CommandName
        Specifies the name of the command.

    .PARAMETER IgnoreParameter
        Specifies all the parameters that should be ignored.

    .PARAMETER NamedParameter
        Specifies all the names of the parameters that are not positional, that
        have a value associated with them.

    .PARAMETER PositionalParameter
        Specifies all the names of the positional parameters. Must be specified
        in the order of their numeric position.

    .OUTPUTS
        System.Collections.Hashtable

        Holds all the parameters of the CommandAst.

    .EXAMPLE
        $commandAst = [System.Management.Automation.Language.Parser]::ParseInput('Should -Be "ExpectedString" "BecauseString" "ActualString"')
        Get-PesterCommandParameter -CommandAst $commandAst -CommandName 'Should' -IgnoreParameter @('Be', 'Not') -PositionalParameter @('ExpectedValue', 'Because', 'ActualValue')

        Returns a hashtable with the parameters.
#>
function Get-PesterCommandParameter
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [System.Management.Automation.Language.CommandAst]
        $CommandAst,

        [Parameter(Mandatory = $true)]
        [System.String]
        $CommandName,

        [Parameter()]
        [System.String[]]
        $IgnoreParameter = @(),

        [Parameter()]
        [System.String[]]
        $NamedParameter = @(),

        [Parameter()]
        [System.String[]]
        $PositionalParameter = @()
    )

    process
    {
        Write-Debug -Message ($script:localizedData.Get_PesterCommandParameter_Debug_RetrievingParameters -f $CommandAst.Extent.Text)
        Write-Debug -Message ($script:localizedData.Get_PesterCommandParameter_Debug_RetrievingCommandName -f $CommandName)

        # Filter out the command name from the command elements.
        $commandElement = $CommandAst.CommandElements |
            Where-Object -FilterScript {
                -not (
                    $_ -is [System.Management.Automation.Language.StringConstantExpressionAst] `
                        -and $_.Extent.Text -eq $CommandName
                )
            }

        Write-Debug -Message ($script:localizedData.Get_PesterCommandParameter_Debug_IgnoreParameters -f ($IgnoreParameter -join ', '))

        <#
            Filter out the parameters to ignore from the command elements, e.g.:
                - Be
                - Not
        #>
        $commandElement = $commandElement |
            Where-Object -FilterScript {
                # Calls ConvertTo-ActualParameterName to handle abbreviated parameter names.
                -not (
                    $_ -is [System.Management.Automation.Language.CommandParameterAst] `
                        -and (ConvertTo-ActualParameterName -NamedParameter $_.ParameterName -CommandName $CommandName) -in $IgnoreParameter
                )
            }

        # Build a hashtable based on the values in $PositionalParameter and $NamedParameter.
        $parameterHashtable = @{}

        if (${commandElement}?.Count -gt 0)
        {
            Write-Debug -Message ($script:localizedData.Get_PesterCommandParameter_Debug_NamedParameters -f ($NamedParameter -join ', '))

            <#
                Filter out the named parameters including its values from the command elements, e.g.:
                    - ActualValue
                    - ExpectedValue
                    - Because
            #>
            $parameterElements = $commandElement.Where({
                    $result = $false

                    if ($_ -is [System.Management.Automation.Language.CommandParameterAst])
                    {
                        $actualParameterName = ConvertTo-ActualParameterName -NamedParameter $_.ParameterName -CommandName $CommandName

                        # Search for named parameters including positional parameters that too can be set as named parameters.
                        $result = $actualParameterName -in $PositionalParameter -or $actualParameterName -in $NamedParameter
                    }

                    $result
                })

            $filterCommandElements = @()

            foreach ($parameterElement in $parameterElements)
            {
                $parameterIndex = $commandElement.IndexOf($parameterElement)

                # Above returned -1 if parameter name was not found.
                if ($parameterIndex -ne -1)
                {
                    $convertToActualParameterNameParameters = @{
                        CommandName    = $CommandName
                        NamedParameter = $commandElement[$parameterIndex].ParameterName
                    }

                    # Handle abbreviated parameter names.
                    $parameterName = ConvertTo-ActualParameterName @convertToActualParameterNameParameters

                    $nextElementIndex = $parameterIndex + 1

                    # If the next element exist or is not of type CommandParameterAst then current element is a value for previous parameter.
                    $parameterHasValue = $commandElement.Count -ne $nextElementIndex -and $commandElement[$nextElementIndex].GetType().FullName -ne 'System.Management.Automation.Language.CommandParameterAst'

                    $parameterHashtable.$parameterName = @{
                        Position   = 0
                        Positional = $false
                        ExtentText = $parameterHasValue ? $commandElement[$nextElementIndex].Extent.Text : $null
                    }

                    $filterCommandElements += $commandElement[$parameterIndex]

                    if ($parameterHasValue)
                    {
                        $filterCommandElements += $commandElement[$nextElementIndex]
                    }
                }
            }

            # Filter out the value parameter and its value from the command elements.
            $commandElement = $commandElement |
                Where-Object -FilterScript {
                    $_ -notin $filterCommandElements
                }
        }

        # Get the positional parameters extent text that are left (if any).
        if (${commandElement}?.Count -gt 0)
        {
            Write-Debug -Message ($script:localizedData.Get_PesterCommandParameter_Debug_PositionalParameters -f ($PositionalParameter -join ', '))

            $elementCounter = 0
            $positionalCounter = 1

            # Positional parameters are discovered in the order they are specified in $PositionalParameter.
            foreach ($parameter in $PositionalParameter)
            {
                # Only add the positional parameter if it does not already exist in the hashtable.
                if (-not $parameterHashtable.ContainsKey($parameter))
                {
                    # Only add positional parameter if there actually a value for it.
                    $parameterHashtable.$parameter = @{
                        Position   = $positionalCounter++
                        Positional = $true
                        ExtentText = $commandElement[$elementCounter++].Extent.Text
                    }

                    # If the command element is $null then there are no more positional parameters to process.
                    if ($null -eq $commandElement[$elementCounter])
                    {
                        break
                    }
                }
            }
        }

        return $parameterHashtable
    }
}
