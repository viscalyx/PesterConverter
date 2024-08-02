<#
    .SYNOPSIS
        Retrieves the ScriptBlockAst definition of a PowerShell script file.

    .DESCRIPTION
        The Get-AstDefinition function parses a PowerShell script file and retrieves
        the ScriptBlockAst definition. It uses the Parser.ParseFile method from the
        System.Management.Automation.Language namespace to parse the file.

    .PARAMETER Path
        Specifies the path to the PowerShell script file(s) to parse.
        This parameter supports pipeline input and accepts both strings and FileInfo
        objects.

    .OUTPUTS
        System.Management.Automation.Language.ScriptBlockAst

        The ScriptBlockAst definition of the parsed PowerShell script file.

    .EXAMPLE
        Get-AstDefinition -Path 'C:\Scripts\Script.ps1'

        Retrieves the ScriptBlockAst definition of the 'Script.ps1' file.

    .EXAMPLE
        Get-AstDefinition -Path (Get-ChildItem -Path './scripts')

        Retrieves the ScriptBlockAst definition of all the files in the path pass
        as pipeline input.
#>
function Get-AstDefinition
{
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidMultipleTypeAttributes', '', Justification = 'We want to pass in both strings and FileInfo objects to parameter Path.')]
    [CmdletBinding()]
    [OutputType([System.Management.Automation.Language.ScriptBlockAst])]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [System.String[]]
        [System.IO.FileInfo[]]
        $Path
    )

    process
    {
        foreach ($filePath in $Path)
        {
            $tokens, $parseErrors = $null

            $ast = [System.Management.Automation.Language.Parser]::ParseFile($filePath, [ref] $tokens, [ref] $parseErrors)

            if ($parseErrors)
            {
                $PSCmdlet.ThrowTerminatingError(
                    [System.Management.Automation.ErrorRecord]::new(
                        ($script:localizedData.FailedParseScriptAst -f $parseErrors[0].Message),
                        'GAD0001', # cSpell: disable-line
                        [System.Management.Automation.ErrorCategory]::InvalidOperation,
                        $filePath
                    )
                )
            }

            if ($ast)
            {
                $ast
            }
        }
    }
}
