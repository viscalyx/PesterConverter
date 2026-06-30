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

Describe 'Test-PesterCommandNegated' {
    It 'Should return the $†rue' {
        InModuleScope -ScriptBlock {
            $mockCommandAst = {
                Should -Not -Throw 'MockErrorMessage'
            }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

            $result = Test-PesterCommandNegated -CommandAst $mockCommandAst

            $result | Should-BeTrue
        }
    }

    It 'Should return the $false' {
        InModuleScope -ScriptBlock {
            $mockCommandAst = {
                Should -Throw 'MockErrorMessage'
            }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

            $result = Test-PesterCommandNegated -CommandAst $mockCommandAst

            $result | Should-BeFalse
        }
    }

    It 'Should return the $true when the command is part of a pipeline' {
        InModuleScope -ScriptBlock {
            $mockCommandAst = {
                Get-Something |
                    Get-ScriptBlock |
                        Should -Not -Throw 'MockErrorMessage'
            }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

            $result = Test-PesterCommandNegated -CommandAst $mockCommandAst

            $result | Should-BeTrue
        }
    }
}
