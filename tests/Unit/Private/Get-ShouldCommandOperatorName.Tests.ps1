[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
param ()

BeforeAll {
    $script:dscModuleName = 'PesterConverter'

    Import-Module -Name $script:dscModuleName -Force

    $PSDefaultParameterValues['InModuleScope:ModuleName'] = $script:dscModuleName
    $PSDefaultParameterValues['Mock:ModuleName'] = $script:dscModuleName
    $PSDefaultParameterValues['Should-Invoke:ModuleName'] = $script:dscModuleName
    $PSDefaultParameterValues['Should-NotInvoke:ModuleName'] = $script:dscModuleName
}

AfterAll {
    $PSDefaultParameterValues.Remove('InModuleScope:ModuleName')
    $PSDefaultParameterValues.Remove('Mock:ModuleName')
    $PSDefaultParameterValues.Remove('Should-Invoke:ModuleName')
    $PSDefaultParameterValues.Remove('Should-NotInvoke:ModuleName')

    # Unload the module being tested so that it doesn't impact any other tests.
    Get-Module -Name $script:dscModuleName -All | Remove-Module -Force
}

Describe 'Get-ShouldCommandOperatorName' {
    It 'Should return the correct operator name ''<_>''' -ForEach @(
        'Be',
        'BeExactly',
        'BeGreaterThan',
        'BeLessOrEqual',
        'BeIn',
        'BeLessThan',
        'BeGreaterOrEqual',
        'BeLike',
        'BeLikeExactly',
        'BeNullOrEmpty',
        'BeOfType',
        'BeTrue',
        'BeFalse',
        'Contain',
        'Exist',
        'FileContentMatch',
        'FileContentMatchExactly',
        'FileContentMatchMultiline',
        'FileContentMatchMultilineExactly',
        'HaveCount',
        'HaveParameter',
        'Match',
        'MatchExactly',
        'Throw',
        'InvokeVerifiable',
        'Invoke'
    ) {
        InModuleScope -Parameters @{
            OperatorName = $_
        } -ScriptBlock {
            $mockScriptBlock = [ScriptBlock]::Create(('Should -{0} 1' -f $OperatorName))

            $mockCommandAst = $mockScriptBlock.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

            $result = Get-ShouldCommandOperatorName -CommandAst $mockCommandAst

            $result | Should-BeString -CaseSensitive -Expected $OperatorName
        }
    }

    It 'Should return the correct operator name for alias ''<AliasOperatorName>''' -ForEach @(
        @{
            AliasOperatorName = 'EQ'
            OperatorName = 'Be'
        },
        @{
            AliasOperatorName = 'CEQ'
            OperatorName = 'BeExactly'
        },
        @{
            AliasOperatorName = 'GT'
            OperatorName = 'BeGreaterThan'
        },
        @{
            AliasOperatorName = 'LE'
            OperatorName = 'BeLessOrEqual'
        },
        @{
            AliasOperatorName = 'LT'
            OperatorName = 'BeLessThan'
        },
        @{
            AliasOperatorName = 'GE'
            OperatorName = 'BeGreaterOrEqual'
        },
        @{
            AliasOperatorName = 'HaveType'
            OperatorName = 'BeOfType'
        },
        @{
            AliasOperatorName = 'CMATCH'
            OperatorName = 'MatchExactly'
        }
    ) {
        InModuleScope -Parameters $_ -ScriptBlock {
            $mockScriptBlock = [ScriptBlock]::Create(('Should -{0} 1' -f $AliasOperatorName))

            $mockCommandAst = $mockScriptBlock.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

            $result = Get-ShouldCommandOperatorName -CommandAst $mockCommandAst

            $result | Should-BeString -CaseSensitive -Expected $OperatorName
        }
    }
}
