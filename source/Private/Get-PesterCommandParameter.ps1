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
        Get-PesterCommandParameter -CommandAst $commandAst -IgnoreParameter 'Be', 'Not' -PositionalParameter 'ExpectedValue', 'Because', 'ActualValue'

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
        Write-Debug -Message "Retrieving the parameters of the extent: $($CommandAst.Extent.Text)"
        Write-Debug -Message "Command name: $CommandName"

        # Filter out the command name from the command elements.
        $commandElement = $CommandAst.CommandElements |
            Where-Object -FilterScript {
                -not (
                    $_ -is [System.Management.Automation.Language.StringConstantExpressionAst] `
                        -and $_.Extent.Text -eq $CommandName
                )
            }

        Write-Debug -Message "Ignoring the parameters: $($IgnoreParameter -join ', ')"

        <#
            Filter out the parameters to ignore from the command elements, e.g.:
                - Be
                - Not
        #>
        $commandElement = $commandElement |
            Where-Object -FilterScript {
                -not (
                    $_ -is [System.Management.Automation.Language.CommandParameterAst] `
                        -and $_.ParameterName -in $IgnoreParameter
                )
            }

        # Build a hashtable based on the values in $PositionalParameter and $NamedParameter.
        $positionalParameterHashtable = @{}

        if ($commandElement.Count -gt 0)
        {
            Write-Debug -Message "Named parameters: $($NamedParameter -join ', ')"

            <#
                Filter out the value parameters including its values from the command elements, e.g.:
                    - ActualValue
                    - ExpectedValue
                    - Because
            #>
            $parameterElements = $commandElement.Where({ $_ -is [System.Management.Automation.Language.CommandParameterAst] -and ($_.ParameterName -in $PositionalParameter -or $_.ParameterName -in $NamedParameter) })

            $filterCommandElements = @()

            foreach ($parameterElement in $parameterElements)
            {
                $parameterIndex = $commandElement.IndexOf($parameterElement)

                # Above returned -1 if parameter name was not found.
                if ($parameterIndex -ne -1)
                {
                    $parameterName = $commandElement[$parameterIndex].ParameterName

                    $positionalParameterHashtable.$parameterName = @{
                        Position   = 0
                        Positional = $false
                        ExtentText = $commandElement[$parameterIndex + 1].Extent.Text
                    }

                    $filterCommandElements += $commandElement[$parameterIndex]
                    $filterCommandElements += $commandElement[$parameterIndex + 1]
                }
            }

            # Filter out the value parameter and its value from the command elements.
            $commandElement = $commandElement |
                Where-Object -FilterScript { $_ -notin $filterCommandElements }
        }

        # Get the positional parameters extent text that are left (if any).
        if ($commandElement.Count -gt 0)
        {
            Write-Debug -Message "Positional parameters: $($PositionalParameter -join ', ')"

            $elementCounter = 0
            $positionalCounter = 1

            foreach ($parameter in $PositionalParameter)
            {
                # Only add the positional parameter if it does not exist in the hashtable.
                if (-not $positionalParameterHashtable.ContainsKey($parameter))
                {
                    # Only add positional parameter if there actually a value for it.
                    $positionalParameterHashtable.$parameter = @{
                        Position   = $positionalCounter
                        Positional = $true
                        ExtentText = $commandElement[$elementCounter].Extent.Text #? $commandElement.Extent.Text : $null
                    }

                    # Increment the positional counter.
                    $elementCounter++

                    # If the command element is $null then there are no more positional parameters to process.
                    if ($null -eq $commandElement[$elementCounter])
                    {
                        break
                    }
                }

                # Increment the positional counter.
                $positionalCounter++
            }
        }

        return $positionalParameterHashtable
    }
}
