<#
    .SYNOPSIS
        Determines the Pester command syntax version based on the command and
        parameter name.

    .DESCRIPTION
        This function checks the command and parameter name used in a Pester command
        to determine the syntax version of the command. It supports identifying syntax
        versions based on specific commands and parameters.

    .PARAMETER CommandAst
        The abstract syntax tree of the command being analyzed.

    .PARAMETER CommandName
        The name of the command to check for in the AST. This allows for dynamic
        checking of different commands.

    .PARAMETER ParameterName
        The name of the parameter to check for in the command. This allows for
        dynamic checking of different parameters.

    .EXAMPLE
        $ast = [System.Management.Automation.Language.Parser]::ParseInput('Should -BeExactly "value"', [ref]$null, [ref]$null)
        Get-PesterCommandSyntaxVersion -CommandAst $ast

        Returns the syntax version for the 'Should -BeExactly' command.
#>
function Get-PesterCommandSyntaxVersion
{
    [CmdletBinding()]
    [OutputType([System.Int32])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.Language.CommandAst]
        $CommandAst
    )

    $sourceSyntaxVersion = $null

    if ($CommandAst.CommandElements[0].Extent.Text -match 'Should-\w+\b')
    {
        $sourceSyntaxVersion = 6
    }
    elseif ($CommandAst.CommandElements[0].Extent.Text -eq 'Should' -and (Get-ShouldCommandOperatorName -CommandAst $CommandAst))
    {
        $sourceSyntaxVersion = 5
    }

    return $sourceSyntaxVersion
}
