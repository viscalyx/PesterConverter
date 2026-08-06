<#
    .SYNOPSIS
        Retrieves the extent text from the provided CommandAst.

    .DESCRIPTION
        The Get-ExtentText function evaluates if the CommandAst object has the property
        `TextWithConvertedChild`, if so return that as the extent text. If the property
        is missing the normal extent text property is returned.

    .PARAMETER CommandAst
        Specifies the CommandAst object representing the command from which the text is extracted.

    .OUTPUTS
        System.String

        The extent text as a string.

    .EXAMPLE
        $commandAst = [System.Management.Automation.Language.Parser]::ParseInput('Get-Process -Name "powershell"')
        Get-ExtentText -CommandAst $commandAst

        Returns `Get-Process -Name "powershell"`.

    .NOTES
        This is needed to handle an edge case where a user can use, for example, a `Should`
        Pester command inside a `Should` operator.
#>

function Get-ExtentText
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [System.Management.Automation.Language.CommandAst[]]
        $CommandAst
    )

    process
    {
        if ($CommandAst.Extent.PSObject.Members.Name -contains 'TextWithConvertedChild')
        {
            return $CommandAst.Extent.TextWithConvertedChild
        }

        return $CommandAst.Extent.Text
    }
}
