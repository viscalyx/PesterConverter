<#
    .SYNOPSIS
        Converts a command `Should -Invoke` (or `Should -Not -Invoke`) to Pester 6 syntax.

    .DESCRIPTION
        The Convert-ShouldInvoke function is used to convert Pester v5 commands for invoking commands
        to the Pester v6 syntax: Should-Invoke or Should-NotInvoke.

    .PARAMETER CommandAst
        The CommandAst object representing the command to be converted.

    .PARAMETER Pester6
        Specifies that the command should be converted to Pester version 6 syntax.

    .PARAMETER UseNamedParameters
        Specifies whether to use named parameters in the converted syntax.

    .PARAMETER UsePositionalParameters
        Specifies whether to use positional parameters in the converted syntax.

    .EXAMPLE
        $commandAst = [System.Management.Automation.Language.Parser]::ParseInput('Should -Invoke "Test"')
        Convert-ShouldBe -CommandAst $commandAst -Pester6

        This example converts the `Should -Be "Test"` command to Pester 6 syntax.

    .NOTES
        Pester 5 Syntax:
            Should -Invoke [-CommandName] <string> [[-Times] <int>] [-ParameterFilter <scriptblock>] [-ModuleName <string>] [-Scope <string>] [-Exactly] [-ActualValue <Object>] [-Not] [-Because <string>] [<CommonParameters>]
            Should -Invoke [-CommandName] <string> [[-Times] <int>] -ExclusiveFilter <scriptblock> [-ParameterFilter <scriptblock>] [-ModuleName <string>] [-Scope <string>] [-Exactly] [-ActualValue <Object>] [-Not] [-Because <string>] [<CommonParameters>]

            Positional parameters:
                Position 1: CommandName
                Position 2: Times

        Pester 6 Syntax:
            Should-Invoke [-CommandName] <String> [[-Times] <Int32>] [-ParameterFilter <ScriptBlock>] [-ExclusiveFilter <ScriptBlock>] [-ModuleName <String>] [-Scope <String>] [-Exactly] [-Because <String>] [<CommonParameters>]
            Should-Invoke -ExclusiveFilter <ScriptBlock> [<CommonParameters>]
            Should-Invoke [-Because <String>] [-Verifiable] [<CommonParameters>]

            Should-NotInvoke [-CommandName] <String> [[-Times] <Int32>] [-ParameterFilter <ScriptBlock>] [-ExclusiveFilter <ScriptBlock>] [-ModuleName <String>] [-Scope <String>] [-Exactly] [-Because <String>] [<CommonParameters>]
            Should-NotInvoke -ExclusiveFilter <ScriptBlock> [<CommonParameters>]
            Should-NotInvoke [-Because <String>] [-Verifiable] [<CommonParameters>]

            Positional parameters:
                Position 1: CommandName
                Position 2: Times
#>
function Convert-ShouldInvoke
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.Language.CommandAst]
        $CommandAst,

        [Parameter(Mandatory = $true, ParameterSetName = 'Pester6')]
        [System.Management.Automation.SwitchParameter]
        $Pester6,

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

    Write-Debug -Message ($script:localizedData.Convert_Should_Debug_ParsingCommandAst -f $CommandAst.Extent.Text)

    # Determine if the command is negated.
    $isNegated = Test-PesterCommandNegated -CommandAst $CommandAst

    $sourceSyntaxVersion = Get-PesterCommandSyntaxVersion -CommandAst $CommandAst

    # Parse the command elements and convert them to Pester 6 syntax
    if ($PSCmdlet.ParameterSetName -eq 'Pester6')
    {
        Write-Debug -Message ($script:localizedData.Convert_Should_Debug_ConvertingFromTo -f $sourceSyntaxVersion, '6')

        # Add the correct Pester command based on negation
        $newExtentText = $isNegated ? 'Should-NotInvoke' : 'Should-Invoke'

        $getPesterCommandParameterParameters = @{
            CommandAst          = $CommandAst
            CommandName         = 'Should'
            IgnoreParameter     = @(
                'Invoke',
                'Not'
            )
            PositionalParameter = @(
                'CommandName',
                'Times'
            )
            NamedParameter      = @(
                'ParameterFilter',
                'ExclusiveFilter',
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

        $newExtentText += $commandParameters.CommandName.Positional ? (' {0}' -f $commandParameters.CommandName.ExtentText) : ''
        $newExtentText += $commandParameters.Times.Positional ? (' {0}' -f $commandParameters.Times.ExtentText) : ''

        # Prepare remaining parameters as named parameters in alphabetical order.
        $parameterNames = @()

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
                    $parameterNames += @{
                        $currentParameter = $currentParameter
                    }

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
    }

    Write-Debug -Message ($script:localizedData.Convert_Should_Debug_ConvertedCommand -f $CommandAst.Extent.Text, $newExtentText)

    return $newExtentText
}
