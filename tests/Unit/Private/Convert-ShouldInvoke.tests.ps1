[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
param ()

BeforeAll {
    $script:dscModuleName = 'PesterConverter'

    Import-Module -Name $script:dscModuleName

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

Describe 'Convert-ShouldInvoke' {
    Context 'When converting Pester 5 Should -Invoke syntax to Pester 6' {

        Context 'When the tests are affirming' {
            It 'Should convert `Should -Invoke` using default settings correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAst = {
                        'TestCommand' | Should -Invoke 'TestCommand' -Times 3 -Because 'BecauseString'
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldInvoke -CommandAst $mockCommandAst -Pester6

                    $result | Should-BeString -CaseSensitive "Should-Invoke 'TestCommand' -Because 'BecauseString' -Times 3"
                }
            }

            It 'Should convert `Should -Invoke` using named parameters correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAst = {
                        'TestCommand' | Should -Invoke 'TestCommand' -Times 3 -Because 'BecauseString'
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldInvoke -CommandAst $mockCommandAst -Pester6 -UseNamedParameters

                    $result | Should-BeString -CaseSensitive "Should-Invoke -Because 'BecauseString' -CommandName 'TestCommand' -Times 3"
                }
            }

            It 'Should convert a multi-line `Should -Invoke` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAst = {
                        Should -Invoke -CommandName Start-SqlSetupProcess -ParameterFilter {
                            $ArgumentList | Should -MatchExactly '\/quiet \/IAcceptLicenseTerms'

                            # Return $true if none of the above throw.
                            $true
                        } -Exactly -Times 1 -Scope It
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldInvoke -CommandAst $mockCommandAst -Pester6 -UseNamedParameters

                    $result | Should-BeBlockString @"
Should-Invoke -CommandName Start-SqlSetupProcess -Exactly -ParameterFilter {
                            `$ArgumentList | Should -MatchExactly '\/quiet \/IAcceptLicenseTerms'

                            # Return `$true if none of the above throw.
                            `$true
                        } -Scope It -Times 1
"@
                }
            }

            It 'Should convert `Should -Invoke` using positional parameters correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAst = {
                        'TestCommand' | Should -Invoke 'TestCommand' -Times 3 -Because 'BecauseString'
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldInvoke -CommandAst $mockCommandAst -Pester6 -UsePositionalParameters

                    $result | Should-BeString -CaseSensitive "Should-Invoke 'TestCommand' 3 -Because 'BecauseString'"
                }
            }
        }

        Context 'When the tests are negated' {
            It 'Should convert `Should -Not -Invoke` using default settings correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAst = {
                        'TestCommand' | Should -Not -Invoke 'TestCommand' -Times 2 -Because 'BecauseString'
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldInvoke -CommandAst $mockCommandAst -Pester6

                    $result | Should-BeString -CaseSensitive "Should-NotInvoke 'TestCommand' -Because 'BecauseString' -Times 2"
                }
            }

            It 'Should convert `Should -Not -Invoke` using named parameters correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAst = {
                        'TestCommand' | Should -Not -Invoke 'TestCommand' -Times 2 -Because 'BecauseString'
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldInvoke -CommandAst $mockCommandAst -Pester6 -UseNamedParameters

                    $result | Should-BeString -CaseSensitive "Should-NotInvoke -Because 'BecauseString' -CommandName 'TestCommand' -Times 2"
                }
            }

            It 'Should convert `Should -Not -Invoke` using positional parameters correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAst = {
                        'TestCommand' | Should -Not -Invoke 'TestCommand' -Times 2 -Because 'BecauseString'
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)
                    $result = Convert-ShouldInvoke -CommandAst $mockCommandAst -Pester6 -UsePositionalParameters
                    $result | Should-BeString -CaseSensitive "Should-NotInvoke 'TestCommand' 2 -Because 'BecauseString'"
                }
            }
        }
    }

    Context 'When additional parameters are provided' {
        Context 'Affirming command' {
            It 'Should convert extra parameters using default settings correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAst = {
                        'TestCommand' | Should -Invoke 'TestCommand' -Times 5 `
                            -ParameterFilter { $_.Name -eq 'test' } `
                            -ModuleName 'TestModule' `
                            -Scope 'Global' `
                            -Exactly `
                            -Because 'ExtraBecause'
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $expected = 'Should-Invoke ''TestCommand'' -Because ''ExtraBecause'' -Exactly -ModuleName ''TestModule'' -ParameterFilter { $_.Name -eq ''test'' } -Scope ''Global'' -Times 5'

                    $result = Convert-ShouldInvoke -CommandAst $mockCommandAst -Pester6

                    $result | Should-BeString -CaseSensitive $expected
                }
            }
            It 'Should convert extra parameters using positional settings correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAst = {
                        'TestCommand' | Should -Invoke 'TestCommand' -Times 5 `
                            -ParameterFilter { $_.Name -eq 'test' } `
                            -ModuleName 'TestModule' `
                            -Scope 'Global' `
                            -Exactly `
                            -Because 'ExtraBecause'
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $expected = 'Should-Invoke ''TestCommand'' 5 -Because ''ExtraBecause'' -Exactly -ModuleName ''TestModule'' -ParameterFilter { $_.Name -eq ''test'' } -Scope ''Global'''

                    $result = Convert-ShouldInvoke -CommandAst $mockCommandAst -Pester6 -UsePositionalParameters

                    $result | Should-BeString -CaseSensitive $expected
                }
            }
        }

        Context 'Negated command' {
            It 'Should convert extra parameters using default settings correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAst = {
                        'TestCommand' | Should -Not -Invoke 'TestCommand' -Times 4 `
                            -ParameterFilter { $_.Name -eq 'test' } `
                            -ModuleName 'TestModule' `
                            -Scope 'Local' `
                            -Exactly `
                            -Because 'ExtraBecauseNegated'
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $expected = 'Should-NotInvoke ''TestCommand'' -Because ''ExtraBecauseNegated'' -Exactly -ModuleName ''TestModule'' -ParameterFilter { $_.Name -eq ''test'' } -Scope ''Local'' -Times 4'

                    $result = Convert-ShouldInvoke -CommandAst $mockCommandAst -Pester6

                    $result | Should-BeString -CaseSensitive $expected
                }
            }
            It 'Should convert extra parameters using positional settings correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAst = {
                        'TestCommand' | Should -Not -Invoke 'TestCommand' -Times 4 `
                            -ParameterFilter { $_.Name -eq 'test' } `
                            -ModuleName 'TestModule' `
                            -Scope 'Local' `
                            -Exactly `
                            -Because 'ExtraBecauseNegated'
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $expected = 'Should-NotInvoke ''TestCommand'' 4 -Because ''ExtraBecauseNegated'' -Exactly -ModuleName ''TestModule'' -ParameterFilter { $_.Name -eq ''test'' } -Scope ''Local'''

                    $result = Convert-ShouldInvoke -CommandAst $mockCommandAst -Pester6 -UsePositionalParameters

                    $result | Should-BeString -CaseSensitive $expected
                }
            }

            It 'Should convert Exactly as last parameter correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAst = {
                        'TestCommand' | Should -Not -Invoke 'TestCommand' -Times 4 `
                            -ParameterFilter { $_.Name -eq 'test' } `
                            -ModuleName 'TestModule' `
                            -Scope 'Local' `
                            -Because 'ExtraBecauseNegated' `
                            -Exactly
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $expected = 'Should-NotInvoke ''TestCommand'' 4 -Because ''ExtraBecauseNegated'' -Exactly -ModuleName ''TestModule'' -ParameterFilter { $_.Name -eq ''test'' } -Scope ''Local'''

                    $result = Convert-ShouldInvoke -CommandAst $mockCommandAst -Pester6 -UsePositionalParameters

                    $result | Should-BeString -CaseSensitive $expected
                }
            }
        }
    }
}
