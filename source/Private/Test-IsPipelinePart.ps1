
<#
    .SYNOPSIS
        Determines if a command is part of a pipeline.

    .DESCRIPTION
        The Test-IsPipelinePart function checks if a given command is part of a
        pipeline. It examines the parent of the CommandAst and determines if it
        is a PipelineAst.

    .PARAMETER CommandAst
        The CommandAst object representing the command to be checked.

    .EXAMPLE
        Test-IsPipelinePart -CommandAst $commandAst

        Determines if the specified command is part of a pipeline.

    .OUTPUTS
        System.Boolean

        Returns $true if the command is part of a pipeline, otherwise returns $false.
#>
function Test-IsPipelinePart
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.Language.CommandAst]
        $CommandAst
    )

    # Check if the parent of the CommandAst is a PipelineAst
    $isPartOfPipeline = $CommandAst.Parent -and $CommandAst.Parent -is [System.Management.Automation.Language.PipelineAst] -and $CommandAst.Parent.PipelineElements.Count -gt 1

    # Return true if part of a pipeline, false otherwise
    return $isPartOfPipeline
}
