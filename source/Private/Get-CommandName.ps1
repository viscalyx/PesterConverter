<#
    .SYNOPSIS
        Retrieves the command name from the provided CommandAst.

    .DESCRIPTION
        The Get-CommandNameFromAst function analyzes the CommandAst object to extract
        and return the command name. It handles different AST element types to ensure
        the command name is accurately determined.

    .PARAMETER CommandAst
        Specifies the CommandAst object representing the command from which the name is extracted.

    .OUTPUTS
        System.String

        The command name as a string.

    .EXAMPLE
        $commandAst = [System.Management.Automation.Language.Parser]::ParseInput('Get-Process -Name "powershell"')
        Get-CommandName -CommandAst $commandAst

        Returns "Get-Process"
#>

function Get-CommandName
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [System.Management.Automation.Language.CommandAst]
        $CommandAst
    )

    process
    {
        # Retrieve the first command element which represents the command name.
        $commandElement = $CommandAst.CommandElements[0]

        # Use a switch to handle common AST types for the command name.
        switch ($commandElement.GetType().Name)
        {
            'StringConstantExpressionAst'
            {
                return $commandElement.Value
            }

            default
            {
                return $null
            }
        }
    }
}
