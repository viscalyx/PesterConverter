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

Describe 'Get-PesterCommandSyntaxVersion' {
    Context 'When expecting Pester 5 syntax' {
        It 'Should return the correct Pester syntax version' {
            InModuleScope -ScriptBlock {
                $mockCommandAst = {
                    Should -BeExactly 'MockValue'
                }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                $result = Get-PesterCommandSyntaxVersion -CommandAst $mockCommandAst

                $result | Should-Be -Expected 5
            }
        }
    }

    Context 'When expecting Pester 6 syntax' {
        It 'Should return the correct Pester syntax version' {
            InModuleScope -ScriptBlock {
                $mockCommandAst = {
                    Should-Be 'MockValue'
                }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                $result = Get-PesterCommandSyntaxVersion -CommandAst $mockCommandAst

                $result | Should-Be -Expected 6
            }
        }
    }

    Context 'When expecting Pester 4 syntax' {
        It 'Should return the correct Pester syntax version for Assert-MockCalled' {
            InModuleScope -ScriptBlock {
                $mockCommandAst = {
                    Assert-MockCalled Get-Something -Times 1
                }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                $result = Get-PesterCommandSyntaxVersion -CommandAst $mockCommandAst

                $result | Should-Be -Expected 4
            }
        }
    }

    It 'Should return $null' {
        InModuleScope -ScriptBlock {
            $mockCommandAst = {
                Should Be 'MockValue'
            }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

            $result = Get-PesterCommandSyntaxVersion -CommandAst $mockCommandAst

            $result | Should-BeNull
        }
    }
}
