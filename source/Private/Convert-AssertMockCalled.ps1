<#
    .SYNOPSIS
        Converts a command `Assert-MockCalled` to `Should -Invoke`.

    .DESCRIPTION
        The Convert-AssertMockCalled function is used to convert a command `Assert-MockCalled`
        to `Should -Invoke`.

    .PARAMETER CommandAst
        The CommandAst object representing the command to be converted.

    .PARAMETER Pester5
        Specifies that the command should be converted to Pester version 5 syntax.

    .PARAMETER Pester6
        Specifies that the command should be converted to Pester version 6 syntax.

    .PARAMETER UseNamedParameters
        Specifies whether to use named parameters in the converted syntax.

    .PARAMETER UsePositionalParameters
        Specifies whether to use positional parameters in the converted syntax,
        where supported.

    .EXAMPLE
        $commandAst = [System.Management.Automation.Language.Parser]::ParseInput('Assert-MockCalled -CommandName "TestCommand"')
        Convert-AssertMockCalled -CommandAst $commandAst -Pester6

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

        [Parameter(Mandatory = $true, ParameterSetName = 'Pester6')]
        [System.Management.Automation.SwitchParameter]
        $Pester6,

        [Parameter(Mandatory = $true, ParameterSetName = 'Pester5')]
        [System.Management.Automation.SwitchParameter]
        $Pester5,

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

    $sourceSyntaxVersion = Get-PesterCommandSyntaxVersion -CommandAst $CommandAst

    # Parse the command elements and convert them to Pester 6 syntax
    if ($PSCmdlet.ParameterSetName -in @('Pester5', 'Pester6'))
    {
        <#
            Always convert to Pester 5 syntax. Converting to Pester 5 is an intermediate
            step for Pester 6 syntax, which will be used to convert to Pester 6 at the end.
        #>
        $debugMessage = $script:localizedData.Convert_AssertMockCalled_Debug_ConvertingFromTo -f $sourceSyntaxVersion, 5

        if ($PSCmdlet.ParameterSetName -eq 'Pester6')
        {
            $debugMessage += ' {0}' -f $script:localizedData.Convert_AssertMockCalled_Debug_IntermediateStep
        }

        Write-Debug -Message $debugMessage

        # Add the correct Pester 5 command.
        $newExtentText = 'Should -Invoke'

        $getPesterCommandParameterParameters = @{
            CommandAst          = $CommandAst
            CommandName         = 'Assert-MockCalled'
            IgnoreParameter     = @()
            PositionalParameter = @(
                'CommandName',
                'Times',
                'ParameterFilter',
                'ModuleName',
                'Scope'
            )
            NamedParameter      = @(
                'Exactly'
            )
        }

        $commandParameters = Get-PesterCommandParameter @getPesterCommandParameterParameters

        <#
            Parameter 'ParameterFilter', 'ModuleName' and 'Scope' are only supported
            as named parameters in Pester 5 and Pester 6 syntax.
        #>
        @(
            'ParameterFilter'
            'ModuleName'
            'Scope'
        ) | ForEach-Object -Process {
            if ($commandParameters.$_)
            {
                $commandParameters.$_.Positional = $false
            }
        }

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

        # Add positional parameters in the correct order.
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

        # Convert the extent to Pester 6 if necessary
        if ($PSCmdlet.ParameterSetName -eq 'Pester6')
        {
            Write-Debug -Message ($script:localizedData.Convert_AssertMockCalled_Debug_ConvertingFromTo -f 5, 6)

            $scriptBlockAst = [System.Management.Automation.Language.Parser]::ParseInput($newExtentText, [ref] $null, [ref] $null)

            $commandAsts = $scriptBlockAst.FindAll({
                    $args[0] -is [System.Management.Automation.Language.CommandAst]
                }, $true)

            $newExtentAst = $commandAsts | Select-Object -First 1

            $convertShouldInvokeParameters = @{
                Pester6    = $true
                CommandAst = $newExtentAst
            }

            if ($UseNamedParameters.IsPresent)
            {
                $convertShouldInvokeParameters.UseNamedParameters = $true
            }

            if ($UsePositionalParameters.IsPresent)
            {
                $convertShouldInvokeParameters.UsePositionalParameters = $true
            }


            $newExtentText = Convert-ShouldInvoke @convertShouldInvokeParameters
        }
    }

    Write-Debug -Message ($script:localizedData.Convert_AssertMockCalled_Debug_ConvertedCommand -f $CommandAst.Extent.Text, $newExtentText)

    return $newExtentText
}
