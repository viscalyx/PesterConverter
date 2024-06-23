[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
param ()

BeforeDiscovery {
    try
    {
        if (-not (Get-Module -Name 'DscResource.Test'))
        {
            # Assumes dependencies has been resolved, so if this module is not available, run 'noop' task.
            if (-not (Get-Module -Name 'DscResource.Test' -ListAvailable))
            {
                # Redirect all streams to $null, except the error stream (stream 2)
                & "$PSScriptRoot/../../../build.ps1" -Tasks 'noop' 2>&1 4>&1 5>&1 6>&1 > $null
            }

            # If the dependencies has not been resolved, this will throw an error.
            Import-Module -Name 'DscResource.Test' -Force -ErrorAction 'Stop'
        }
    }
    catch [System.IO.FileNotFoundException]
    {
        throw 'DscResource.Test module dependency not found. Please run ".\build.ps1 -ResolveDependency -Tasks build" first.'
    }
}

BeforeAll {
    $script:dscModuleName = 'PesterConverter'

    Import-Module -Name $script:dscModuleName

    $PSDefaultParameterValues['InModuleScope:ModuleName'] = $script:dscModuleName
    $PSDefaultParameterValues['Mock:ModuleName'] = $script:dscModuleName
    $PSDefaultParameterValues['Should:ModuleName'] = $script:dscModuleName
}

AfterAll {
    $PSDefaultParameterValues.Remove('InModuleScope:ModuleName')
    $PSDefaultParameterValues.Remove('Mock:ModuleName')
    $PSDefaultParameterValues.Remove('Should:ModuleName')

    # Unload the module being tested so that it doesn't impact any other tests.
    Get-Module -Name $script:dscModuleName -All | Remove-Module -Force
}

Describe 'Switch-ShouldBe' {
    Context 'When converting Pester 5 syntax to Pester 6 syntax' {
        BeforeAll {
            InModuleScope -ScriptBlock {
                $PSDefaultParameterValues['Switch-ShouldBe:Pester6'] = $true
            }
        }

        AfterAll {
            InModuleScope -ScriptBlock {
                $PSDefaultParameterValues.Remove('Switch-ShouldBe:Pester6')
            }
        }

        It 'Should convert to Pester 6 syntax without using command aliases' {
            InModuleScope -ScriptBlock {
                $mockCommandAstPester5 = {
                    Should -Be 1
                }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                $result = Switch-ShouldBe -CommandAst $mockCommandAstPester5 -NoCommandAlias

                $result | Should -BeExactly 'Assert-Equal 1'
            }
        }

        It 'Should convert to Pester 6 syntax using command aliases' {
            InModuleScope -ScriptBlock {
                $mockCommandAstPester5 = {
                    Should -Be 1
                }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                $result = Switch-ShouldBe -CommandAst $mockCommandAstPester5

                $result | Should -BeExactly 'Should-Be 1'
            }
        }

        Context 'When the tests are affirming' {
            It 'Should convert `Should -Be 1` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -Be 1
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Switch-ShouldBe -CommandAst $mockCommandAstPester5

                    $result | Should -BeExactly 'Should-Be 1'
                }
            }

            It 'Should convert `Should -Be "AnyString"` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -Be "AnyString"
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Switch-ShouldBe -CommandAst $mockCommandAstPester5

                    $result | Should -BeExactly 'Should-Be "AnyString"'
                }
            }

            It "Should convert ``Should -Be 'AnyString'`` correctly" {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -Be 'AnyString'
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Switch-ShouldBe -CommandAst $mockCommandAstPester5

                    $result | Should -BeExactly "Should-Be 'AnyString'"
                }
            }

            It 'Should convert `Should -Be $true` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -Be $true
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Switch-ShouldBe -CommandAst $mockCommandAstPester5

                    $result | Should -BeExactly 'Should-Be $true'
                }
            }

            It 'Should convert `Should -Be $anyValue` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -Be $anyValue
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Switch-ShouldBe -CommandAst $mockCommandAstPester5

                    $result | Should -BeExactly 'Should-Be $anyValue'
                }
            }

            It 'Should convert `Should -ActualValue $true -Be $true` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -ActualValue $true -Be $true
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Switch-ShouldBe -CommandAst $mockCommandAstPester5

                    $result | Should -BeExactly 'Should-Be -Actual $true $true'
                }
            }

            It 'Should convert `Should -Be $true -ActualValue $true` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -Be $true -ActualValue $true
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Switch-ShouldBe -CommandAst $mockCommandAstPester5

                    $result | Should -BeExactly 'Should-Be -Actual $true $true'
                }
            }

            It 'Should convert `Should -ActualValue $true -Be -ExpectedValue $false` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -ActualValue $true -Be -ExpectedValue $false
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Switch-ShouldBe -CommandAst $mockCommandAstPester5

                    $result | Should -BeExactly 'Should-Be -Actual $true -Expected $false'
                }
            }

            It 'Should convert `Should -Be -ActualValue $true -ExpectedValue $false` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -Be -ActualValue $true -ExpectedValue $false
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Switch-ShouldBe -CommandAst $mockCommandAstPester5

                    $result | Should -BeExactly 'Should-Be -Actual $true -Expected $false'
                }
            }

            It 'Should convert `Should -Be -ExpectedValue $false -ActualValue $true` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -Be -ExpectedValue $false -ActualValue $true
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Switch-ShouldBe -CommandAst $mockCommandAstPester5

                    $result | Should -BeExactly 'Should-Be -Actual $true -Expected $false'
                }
            }

            It 'Should convert `Should -ExpectedValue $false -Be -ActualValue $true` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -ExpectedValue $false -Be -ActualValue $true
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Switch-ShouldBe -CommandAst $mockCommandAstPester5

                    $result | Should -BeExactly 'Should-Be -Actual $true -Expected $false'
                }
            }

            It 'Should convert `Should -ExpectedValue $false -ActualValue $true -Be` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -ExpectedValue $false -ActualValue $true -Be
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Switch-ShouldBe -CommandAst $mockCommandAstPester5

                    $result | Should -BeExactly 'Should-Be -Actual $true -Expected $false'
                }
            }
        }

        Context 'When the tests are negated' {
            It 'Should convert `Should -Not -Be 1` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -Not -Be 1
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Switch-ShouldBe -CommandAst $mockCommandAstPester5

                    $result | Should -BeExactly 'Should-NotBe 1'
                }
            }

            It 'Should convert `Should -Be 1 -Not` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -Be 1 -Not
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Switch-ShouldBe -CommandAst $mockCommandAstPester5

                    $result | Should -BeExactly 'Should-NotBe 1'
                }
            }

            It 'Should convert `Should -Not -Be "AnyString"` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -Not -Be "AnyString"
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Switch-ShouldBe -CommandAst $mockCommandAstPester5

                    $result | Should -BeExactly 'Should-NotBe "AnyString"'
                }
            }

            It "Should convert ``Should -Not -Be 'AnyString'`` correctly" {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -Not -Be 'AnyString'
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Switch-ShouldBe -CommandAst $mockCommandAstPester5

                    $result | Should -BeExactly "Should-NotBe 'AnyString'"
                }
            }

            It 'Should convert `Should -Not -Be $true` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -Not -Be $true
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Switch-ShouldBe -CommandAst $mockCommandAstPester5

                    $result | Should -BeExactly 'Should-NotBe $true'
                }
            }

            It 'Should convert `Should -Not -Be $anyValue` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -Not -Be $anyValue
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Switch-ShouldBe -CommandAst $mockCommandAstPester5

                    $result | Should -BeExactly 'Should-NotBe $anyValue'
                }
            }

            It 'Should convert `Should -Be $true -Not` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        $false | Should -Be $true -Not
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Switch-ShouldBe -CommandAst $mockCommandAstPester5

                    $result | Should -BeExactly 'Should-NotBe $true'
                }
            }

            It 'Should convert `Should -Not:$true -Be $true` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        $false | Should -Not:$true -Be $true
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Switch-ShouldBe -CommandAst $mockCommandAstPester5

                    $result | Should -BeExactly 'Should-NotBe $true'
                }
            }

            It 'Should convert `Should -Not:$false -Be $false` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        $false | Should -Not:$false -Be $false
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Switch-ShouldBe -CommandAst $mockCommandAstPester5

                    $result | Should -BeExactly 'Should-Be $false'
                }
            }

            # Should -Not -ActualValue $true -Be $false
            It 'Should convert `Should -Not -ActualValue $true -Be $false` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -Not -ActualValue $true -Be $false
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Switch-ShouldBe -CommandAst $mockCommandAstPester5

                    $result | Should -BeExactly 'Should-NotBe -Actual $true $false'
                }
            }

            It 'Should convert `Should -ActualValue $true -Not -Be $false` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -ActualValue $true -Not -Be $false
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Switch-ShouldBe -CommandAst $mockCommandAstPester5

                    $result | Should -BeExactly 'Should-NotBe -Actual $true $false'
                }
            }

            It 'Should convert `Should -ActualValue $true -Be $false -Not` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -ActualValue $true -Be $false -Not
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Switch-ShouldBe -CommandAst $mockCommandAstPester5

                    $result | Should -BeExactly 'Should-NotBe -Actual $true $false'
                }
            }

            It 'Should convert `Should -Be $false -ActualValue $true -Not` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -Be $false -ActualValue $true -Not
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Switch-ShouldBe -CommandAst $mockCommandAstPester5

                    $result | Should -BeExactly 'Should-NotBe -Actual $true $false'
                }
            }

            It 'Should convert `Should -Be $false -Not -ActualValue $true` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -Be $false -Not -ActualValue $true
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Switch-ShouldBe -CommandAst $mockCommandAstPester5

                    $result | Should -BeExactly 'Should-NotBe -Actual $true $false'
                }
            }

            It 'Should convert `Should -Not -Be $false -ActualValue $true` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -Not -Be $false -ActualValue $true
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Switch-ShouldBe -CommandAst $mockCommandAstPester5

                    $result | Should -BeExactly 'Should-NotBe -Actual $true $false'
                }
            }

            It 'Should convert `Should -ActualValue $true -Be -Not -ExpectedValue $false` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -ActualValue $true -Be -Not -ExpectedValue $false
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Switch-ShouldBe -CommandAst $mockCommandAstPester5

                    $result | Should -BeExactly 'Should-NotBe -Actual $true -Expected $false'
                }
            }

            It 'Should convert `Should -ActualValue $true -Not -Be -ExpectedValue $false` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -ActualValue $true -Not -Be -ExpectedValue $false
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Switch-ShouldBe -CommandAst $mockCommandAstPester5

                    $result | Should -BeExactly 'Should-NotBe -Actual $true -Expected $false'
                }
            }

            It 'Should convert `Should -ActualValue $true -Be -ExpectedValue $false -Not` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -ActualValue $true -Be -ExpectedValue $false -Not
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Switch-ShouldBe -CommandAst $mockCommandAstPester5

                    $result | Should -BeExactly 'Should-NotBe -Actual $true -Expected $false'
                }
            }
        }

        # It 'Should handle positional parameters correctly' {
        #     InModuleScope -ScriptBlock {
        #         # Assuming Test-CommandElementIsPositional and Switch-ShouldBe are updated to handle positional parameters
        #         $mockCommandAstPositionalPester5 = {
        #             Should -Be 1
        #         }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

        #         $result = Switch-ShouldBe -CommandAst $mockCommandAstPositionalPester5

        #         $result | Should -BeExactly 'Should-Be 1'
        #     }
        # }
    }
}
