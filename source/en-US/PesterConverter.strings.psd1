<#
    .SYNOPSIS
        The localized resource strings in English (en-US). This file should only
        contain localized strings for private functions, public command, and
        classes (that are not a DSC resource).
#>

ConvertFrom-StringData @'
    ## Get-AstDefinition
    FailedParseScriptAst = Failed to parse the script. Error: "{0}"

    ## Convert-PesterSyntax
    Convert_PesterSyntax_ShouldProcessVerboseDescription = Converting the script file '{0}'.
    Convert_PesterSyntax__ShouldProcessVerboseWarning = Are you sure you want to convert the script file '{0}'?
    # This string shall not end with full stop (.) since it is used as a title of ShouldProcess messages.
    Convert_PesterSyntax__ShouldProcessCaption = Convert script file
'@
