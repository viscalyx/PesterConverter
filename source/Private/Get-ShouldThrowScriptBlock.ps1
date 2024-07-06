<#
    .SYNOPSIS
        Retrieves the script block associated with a pipeline or parameter.

    .DESCRIPTION
        The Get-ShouldThrowScriptBlock function is used to retrieve the script block
        associated with a pipeline or parameter. It can be used to extract the script
        block from a pipeline or from a specific parameter.

    .PARAMETER CommandAst
        The CommandAst parameter specifies the command AST (Abstract Syntax Tree)
        object from which the script block is to be retrieved.

    .PARAMETER ParameterName
        Specifies the name of the parameter whose script block is to be retrieved.

    .PARAMETER ParsePipeline
        Specifies whether to parse the pipeline to find the script block.

    .OUTPUTS
        System.String

        The function returns the text of the script block if found, otherwise it returns $null.

    .EXAMPLE
        Get-ShouldThrowScriptBlock -CommandAst $commandAst -ParameterName 'ActualValue' -ParsePipeline

        Retrieves the script block associated with the specified command AST and
        parameter name, parsing the pipeline if necessary.
#>
function Get-ShouldThrowScriptBlock
{
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [System.Management.Automation.Language.CommandAst]
        $CommandAst,

        [Parameter()]
        [System.String]
        $ParameterName,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $ParsePipeline
    )

    # Initialize the scriptblock variable
    $scriptBlock = $null

    # If scriptblock is not found in the pipeline, look for it in the parameters
    if ($ParameterName)
    {
        # Find the parameter by name
        $commandParameterAst = $CommandAst.CommandElements |
            Where-Object -FilterScript {
                $_ -is [System.Management.Automation.Language.CommandParameterAst] -and
                $_.ParameterName -eq $ParameterName
            }

        if ($commandParameterAst)
        {
            $commandParameterIndex = $commandParameterAst.Parent.CommandElements.IndexOf($commandParameterAst)

            # Assuming the next element is the argument to the parameter
            $argumentAst = $commandParameterAst.Parent.CommandElements[$commandParameterIndex + 1]

            # Retrieve the argument
            $scriptBlock = $argumentAst.Extent.Text

            # if ($argumentAst -and $argumentAst -is [System.Management.Automation.Language.ScriptBlockExpressionAst])
            # {
            #     $scriptBlock = $argumentAst.ScriptBlock
            # }
        }
    }

    # Check if we need to parse the pipeline
    if (-not $scriptBlock -and $ParsePipeline.IsPresent)
    {
        # Attempt to find a pipeline before the CommandAst in the script
        $pipelineAst = $CommandAst.Parent

        while ($pipelineAst -and -not $pipelineAst -is [System.Management.Automation.Language.PipelineAst])
        {
            $pipelineAst = $pipelineAst.Parent
        }

        if ($pipelineAst)
        {
            # If a pipeline is found, assume the scriptblock is the last element in the pipeline
            $scriptBlock = $pipelineAst.PipelineElements[-1].ScriptBlock
        }
    }

    # Return the scriptblock's text if found, otherwise return null
    return $scriptBlock?.Extent.Text
}
