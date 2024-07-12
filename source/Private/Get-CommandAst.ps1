<#
    .SYNOPSIS
        Retrieves the abstract syntax trees (AST's) of a PowerShell command.

    .DESCRIPTION
        The Get-CommandAst function retrieves the abstract syntax tree (AST) of a
        PowerShell command.  The AST represents the structure of the command and
        can be used for further analysis or manipulation.

    .PARAMETER Ast
        Specifies the AST of a script block.

    .PARAMETER CommandName
        Specifies the PowerShell command for which to retrieve the AST.

    .EXAMPLE
        Get-CommandAst -CommandName 'Should'

        This example retrieves the AST of the 'Should' command.

    .INPUTS
        [System.Collections.Generic.IEnumerable`1[System.Management.Automation.Language.Ast]]

        The AST of a script block.

    .OUTPUTS
        System.Management.Automation.Language.CommandAst[]

        The function returns the abstract syntax trees (AST's) of the specified PowerShell command.
#>
function Get-CommandAst
{
    [CmdletBinding()]
    [OutputType([System.Collections.Generic.IEnumerable`1[System.Management.Automation.Language.Ast]])]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [System.Management.Automation.Language.Ast]
        $Ast,

        [Parameter(Mandatory = $true)]
        [System.String]
        $CommandName
    )

    process
    {
        Write-Debug -Message ($script:localizedData.Get_CommandAst_Debug_RetrievingCommandAsts -f $CommandName)

        $commandAsts = $Ast.FindAll({
                param
                (
                    [Parameter()]
                    $node
                )

                return $node -is [System.Management.Automation.Language.CommandAst] -and $node.GetCommandName() -eq $CommandName
            }, $true)

        return $commandAsts
    }
}
