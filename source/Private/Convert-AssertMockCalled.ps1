<#
    .SYNOPSIS
        Converts a command `Assert-MockCalled` to `Should -Invoke`.

    .DESCRIPTION
        The Convert-AssertMockCalled function is used to convert a command `Assert-MockCalled`
        to `Should -Invoke`.

    .PARAMETER CommandAst
        The CommandAst object representing the command to be converted.

    .PARAMETER UseNamedParameters
        Specifies whether to use named parameters in the converted syntax.

    .PARAMETER UsePositionalParameters
        Specifies whether to use positional parameters in the converted syntax,
        where supported.

    .EXAMPLE
        $commandAst = [System.Management.Automation.Language.Parser]::ParseInput('Assert-MockCalled -CommandName "TestCommand"')
        Convert-AssertMockCalled -CommandAst $commandAst

        This example converts the `Assert-MockCalled -CommandName "TestCommand"` command to `Should -Invoke`.

    .NOTES
        Pester 4/5 Syntax:
            Assert-MockCalled [-CommandName] <String> [[-Times] <Int32>] [[-ParameterFilter] <ScriptBlock>] [[-ModuleName] <String>] [[-Scope] <String>] [-Exactly] [<CommonParameters>]
            Assert-MockCalled [-CommandName] <String> [[-Times] <Int32>] -ExclusiveFilter <ScriptBlock> [[-ModuleName] <String>] [[-Scope] <String>] [-Exactly] [<CommonParameters>]

            Positional parameters:
                Position 1: CommandName
                Position 2: Times
                Position 3: ParameterFilter
                Position 4: ModuleName
                Position 5: Scope


        Pester 5/6 Syntax:
            Should -Invoke [-CommandName] <string> [[-Times] <int>] [-ParameterFilter <scriptblock>] [-ModuleName <string>] [-Scope <string>] [-Exactly] [-ActualValue <Object>] [-Not] [-Because <string>] [<CommonParameters>]
            Should -Invoke [-CommandName] <string> [[-Times] <int>] -ExclusiveFilter <scriptblock> [-ParameterFilter <scriptblock>] [-ModuleName <string>] [-Scope <string>] [-Exactly] [-ActualValue <Object>] [-Not] [-Because <string>] [<CommonParameters>]

            Positional parameters:
                Position 1: CommandName
                Position 2: Times
#>
function Convert-AssertMockCalled
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.Language.CommandAst]
        $CommandAst,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $UseNamedParameters,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $UsePositionalParameters
    )

    $assertBoundParameterParameters = @{
        BoundParameterList     = $PSBoundParameters
        MutuallyExclusiveList1 = @('UseNamedParameters')
        MutuallyExclusiveList2 = @('UsePositionalParameters')
    }

    Assert-BoundParameter @assertBoundParameterParameters

    Write-Debug -Message ($script:localizedData.Convert_AssertMockCalled_Debug_ParsingCommandAst -f $CommandAst.Extent.Text)

    # Add the correct Pester command
    $newExtentText = 'Should-Invoke'

    $getPesterCommandParameterParameters = @{
        CommandAst          = $CommandAst
        CommandName         = 'Assert-MockCalled'
        IgnoreParameter     = @()
        PositionalParameter = @(
            'CommandName',
            'Times'
        )
        NamedParameter      = @(
            'ParameterFilter',
            'ModuleName',
            'Scope',
            'Exactly',
            'Because'
        )
    }

    $commandParameters = Get-PesterCommandParameter @getPesterCommandParameterParameters

    # Determine if named or positional parameters should be forcibly used
    if ($UseNamedParameters.IsPresent)
    {
        $commandParameters.Keys.ForEach({ $commandParameters.$_.Positional = $false })
    }
    elseif ($UsePositionalParameters.IsPresent)
    {
        # First set all to named parameters
        $commandParameters.Keys.ForEach({ $commandParameters.$_.Positional = $false })

        <#
            If a previous positional parameter is missing then the ones behind
            it cannot be set to positional.
        #>
        if ($commandParameters.CommandName)
        {
            $commandParameters.CommandName.Positional = $true

            if ($commandParameters.Times)
            {
                $commandParameters.Times.Positional = $true
            }
        }
    }

    # Ensure ParameterFilter, ModuleName, and Scope remain named in Pester 5 syntax
    if ($commandParameters.ContainsKey('ParameterFilter')) { $commandParameters.ParameterFilter.Positional = $false }
    if ($commandParameters.ContainsKey('ModuleName'))     { $commandParameters.ModuleName.Positional = $false }
    if ($commandParameters.ContainsKey('Scope'))          { $commandParameters.Scope.Positional = $false }

    $newExtentText += $commandParameters.CommandName.Positional ? (' {0}' -f $commandParameters.CommandName.ExtentText) : ''
    $newExtentText += $commandParameters.Times.Positional ? (' {0}' -f $commandParameters.Times.ExtentText) : ''

    # Prepare remaining parameters as named parameters in alphabetical order.
    $parameterNames = @{}

    foreach ($currentParameter in $commandParameters.Keys)
    {
        if ($commandParameters.$currentParameter.Positional -eq $true)
        {
            continue
        }

        switch ($currentParameter)
        {
            # There are no parameters that need to be converted to different names.

            default
            {
                $parameterNames.$currentParameter = $currentParameter

                break
            }
        }
    }

    # This handles the named parameters in the command elements, added in alphabetical order.
    foreach ($currentParameter in $parameterNames.Keys | Sort-Object)
    {
        $originalParameterName = $parameterNames.$currentParameter

        $newExtentText += ' -{0}' -f $currentParameter

        if ($commandParameters.$originalParameterName.ExtentText)
        {
            $newExtentText += ' {0}' -f $commandParameters.$originalParameterName.ExtentText
        }
    }

    Write-Debug -Message ($script:localizedData.Convert_AssertMockCalled_Debug_ConvertedCommand -f $CommandAst.Extent.Text, $newExtentText)

    return $newExtentText
}
