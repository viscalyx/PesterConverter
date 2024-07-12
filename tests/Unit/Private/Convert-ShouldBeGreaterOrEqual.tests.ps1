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

Describe 'Convert-ShouldBeGreaterOrEqual' {
    Context 'When converting Pester 5 syntax to Pester 6 syntax' {
        BeforeAll {
            InModuleScope -ScriptBlock {
                $PSDefaultParameterValues['Convert-ShouldBeGreaterOrEqual:Pester6'] = $true
            }
        }

        AfterAll {
            InModuleScope -ScriptBlock {
                $PSDefaultParameterValues.Remove('Convert-ShouldBeGreaterOrEqual:Pester6')
            }
        }

        Context 'When the tests are affirming' {
            It 'Should convert `Should -BeGreaterOrEqual 2` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -BeGreaterOrEqual 2
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeGreaterOrEqual -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-BeGreaterThanOrEqual 2'
                }
            }

            It 'Should convert `Should -BeGreaterOrEqual $numericValue` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -BeGreaterOrEqual $numericValue
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeGreaterOrEqual -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-BeGreaterThanOrEqual $numericValue'
                }
            }

            It 'Should convert `Should -ActualValue 2 -BeGreaterOrEqual 2` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -ActualValue 2 -BeGreaterOrEqual 2
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeGreaterOrEqual -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-BeGreaterThanOrEqual 2 -Actual 2'
                }
            }

            It 'Should convert `Should -BeGreaterOrEqual 2 -ActualValue 2` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -BeGreaterOrEqual 2 -ActualValue 2
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeGreaterOrEqual -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-BeGreaterThanOrEqual 2 -Actual 2'
                }
            }

            It 'Should convert `Should -ActualValue 2 -BeGreaterOrEqual -ExpectedValue 2` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -ActualValue 2 -BeGreaterOrEqual -ExpectedValue 2
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeGreaterOrEqual -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-BeGreaterThanOrEqual -Actual 2 -Expected 2'
                }
            }

            It 'Should convert `Should -BeGreaterOrEqual -ActualValue 2 -ExpectedValue 2` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -BeGreaterOrEqual -ActualValue 2 -ExpectedValue 2
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeGreaterOrEqual -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-BeGreaterThanOrEqual -Actual 2 -Expected 2'
                }
            }

            It 'Should convert `Should -BeGreaterOrEqual -ExpectedValue 2 -ActualValue 2` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -BeGreaterOrEqual -ExpectedValue 2 -ActualValue 2
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeGreaterOrEqual -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-BeGreaterThanOrEqual -Actual 2 -Expected 2'
                }
            }

            It 'Should convert `Should -ExpectedValue 2 -BeGreaterOrEqual -ActualValue 2` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -ExpectedValue 2 -BeGreaterOrEqual -ActualValue 2
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeGreaterOrEqual -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-BeGreaterThanOrEqual -Actual 2 -Expected 2'
                }
            }

            It 'Should convert `Should -ExpectedValue 2 -ActualValue 2 -BeGreaterOrEqual` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -ExpectedValue 2 -ActualValue 2 -BeGreaterOrEqual
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeGreaterOrEqual -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-BeGreaterThanOrEqual -Actual 2 -Expected 2'
                }
            }

            It 'Should convert `Should -Not:$false -BeGreaterOrEqual 2` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        $false | Should -Not:$false -BeGreaterOrEqual 2
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeGreaterOrEqual -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-BeGreaterThanOrEqual 2'
                }
            }

            It 'Should convert `Should -BeGreaterOrEqual (Get-Something)` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        function Get-Something { return 2 }
                        2 | Should -BeGreaterOrEqual (Get-Something)
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeGreaterOrEqual -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-BeGreaterThanOrEqual (Get-Something)'
                }
            }

            It 'Should convert `Should -BeGreaterOrEqual 2 -Because ''mock should test correct value'' 2` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -BeGreaterOrEqual 2 -Because 'mock should test correct value' 2
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeGreaterOrEqual -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-BeGreaterThanOrEqual 2 2 -Because ''mock should test correct value'''
                }
            }

            It 'Should convert `Should -BeGreaterOrEqual 2 ''mock should test correct value'' 3` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -BeGreaterOrEqual 2 'mock should test correct value' 3
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeGreaterOrEqual -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-BeGreaterThanOrEqual 2 3 -Because ''mock should test correct value'''
                }
            }

            It 'Should convert `Should 2 ''mock should test correct value'' 3 -BeGreaterOrEqual` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should 2 'mock should test correct value' 3 -BeGreaterOrEqual
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeGreaterOrEqual -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-BeGreaterThanOrEqual 2 3 -Because ''mock should test correct value'''
                }
            }
        }

        Context 'When the tests are negated' {
            It 'Should convert `Should -Not -BeGreaterOrEqual 2` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -Not -BeGreaterOrEqual 2
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeGreaterOrEqual -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-BeLessThanOrEqual 2'
                }
            }

            It 'Should convert `Should -BeGreaterOrEqual 2 -Not` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -BeGreaterOrEqual 2 -Not
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeGreaterOrEqual -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-BeLessThanOrEqual 2'
                }
            }

            It 'Should convert `Should -Not -BeGreaterOrEqual $anyValue` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -Not -BeGreaterOrEqual $anyValue
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeGreaterOrEqual -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-BeLessThanOrEqual $anyValue'
                }
            }

            It 'Should convert `Should -BeGreaterOrEqual $anyValue -Not` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -BeGreaterOrEqual $anyValue -Not
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeGreaterOrEqual -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-BeLessThanOrEqual $anyValue'
                }
            }

            It 'Should convert `Should -Not:$true -BeGreaterOrEqual 2` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        $false | Should -Not:$true -BeGreaterOrEqual 2
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeGreaterOrEqual -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-BeLessThanOrEqual 2'
                }
            }

            It 'Should convert `Should -Not -ActualValue 3 -BeGreaterOrEqual 2` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -Not -ActualValue 3 -BeGreaterOrEqual 2
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeGreaterOrEqual -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-BeLessThanOrEqual 2 -Actual 3'
                }
            }

            It 'Should convert `Should -ActualValue 3 -Not -BeGreaterOrEqual 2` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -ActualValue 3 -Not -BeGreaterOrEqual 2
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeGreaterOrEqual -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-BeLessThanOrEqual 2 -Actual 3'
                }
            }

            It 'Should convert `Should -ActualValue 3 -BeGreaterOrEqual 2 -Not` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -ActualValue 3 -BeGreaterOrEqual 2 -Not
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeGreaterOrEqual -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-BeLessThanOrEqual 2 -Actual 3'
                }
            }

            It 'Should convert `Should -BeGreaterOrEqual 2 -ActualValue 3 -Not` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -BeGreaterOrEqual 2 -ActualValue 3 -Not
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeGreaterOrEqual -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-BeLessThanOrEqual 2 -Actual 3'
                }
            }

            It 'Should convert `Should -BeGreaterOrEqual 2 -Not -ActualValue 3` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -BeGreaterOrEqual 2 -Not -ActualValue 3
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeGreaterOrEqual -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-BeLessThanOrEqual 2 -Actual 3'
                }
            }

            It 'Should convert `Should -Not -BeGreaterOrEqual 2 -ActualValue 3` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -Not -BeGreaterOrEqual 2 -ActualValue 3
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeGreaterOrEqual -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-BeLessThanOrEqual 2 -Actual 3'
                }
            }

            It 'Should convert `Should -ActualValue 3 -BeGreaterOrEqual -Not -ExpectedValue 2` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -ActualValue 3 -BeGreaterOrEqual -Not -ExpectedValue 2
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeGreaterOrEqual -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-BeLessThanOrEqual -Actual 3 -Expected 2'
                }
            }

            It 'Should convert `Should -ActualValue 3 -Not -BeGreaterOrEqual -ExpectedValue 2` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -ActualValue 3 -Not -BeGreaterOrEqual -ExpectedValue 2
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeGreaterOrEqual -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-BeLessThanOrEqual -Actual 3 -Expected 2'
                }
            }

            It 'Should convert `Should -ActualValue 3 -BeGreaterOrEqual -ExpectedValue 2 -Not` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -ActualValue 3 -BeGreaterOrEqual -ExpectedValue 2 -Not
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeGreaterOrEqual -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-BeLessThanOrEqual -Actual 3 -Expected 2'
                }
            }
        }

        Context 'When alias operator name is used' {
            It 'Should convert `Should -GE 2 -ActualValue 3` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -GE 2 -ActualValue 3
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeGreaterOrEqual -CommandAst $mockCommandAstPester5 -UseNamedParameters

                    $result | Should-BeString -CaseSensitive 'Should-BeGreaterThanOrEqual -Actual 3 -Expected 2'
                }
            }
        }

        Context 'When tests should always use named parameters' {
            It 'Should convert `Should -BeGreaterOrEqual 2 -ActualValue 3` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -BeGreaterOrEqual 2 -ActualValue 3
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeGreaterOrEqual -CommandAst $mockCommandAstPester5 -UseNamedParameters

                    $result | Should-BeString -CaseSensitive 'Should-BeGreaterThanOrEqual -Actual 3 -Expected 2'
                }
            }
        }

        Context 'When tests should always use positional parameters' {
            Context 'When the tests are affirming' {
                It 'Should convert `Should -BeGreaterOrEqual 2 -ActualValue 3` correctly' {
                    InModuleScope -ScriptBlock {
                        $mockCommandAstPester5 = {
                            Should -BeGreaterOrEqual 2 -ActualValue 3
                        }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                        $result = Convert-ShouldBeGreaterOrEqual -CommandAst $mockCommandAstPester5 -UsePositionalParameters

                        $result | Should-BeString -CaseSensitive 'Should-BeGreaterThanOrEqual 2 3'
                    }
                }

                It 'Should convert `Should -BeGreaterOrEqual 2 -ActualValue 3 -Because "this must return true"` correctly' {
                    InModuleScope -ScriptBlock {
                        $mockCommandAstPester5 = {
                            Should -BeGreaterOrEqual 2 -ActualValue 3 -Because "this must return true"
                        }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                        $result = Convert-ShouldBeGreaterOrEqual -CommandAst $mockCommandAstPester5 -UsePositionalParameters

                        $result | Should-BeString -CaseSensitive 'Should-BeGreaterThanOrEqual 2 3 -Because "this must return true"'
                    }
                }

                It 'Should convert `Should -BeGreaterOrEqual 2 -Because "this must return true" -ActualValue 3` correctly' {
                    InModuleScope -ScriptBlock {
                        $mockCommandAstPester5 = {
                            Should -BeGreaterOrEqual 2 -Because "this must return true" -ActualValue 3
                        }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                        $result = Convert-ShouldBeGreaterOrEqual -CommandAst $mockCommandAstPester5 -UsePositionalParameters

                        $result | Should-BeString -CaseSensitive 'Should-BeGreaterThanOrEqual 2 3 -Because "this must return true"'
                    }
                }

                It 'Should convert `Should -Because "this must return true" -ActualValue 3 -BeGreaterOrEqual 2` correctly' {
                    InModuleScope -ScriptBlock {
                        $mockCommandAstPester5 = {
                            Should -Because "this must return true" -ActualValue 3 -BeGreaterOrEqual 2
                        }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                        $result = Convert-ShouldBeGreaterOrEqual -CommandAst $mockCommandAstPester5 -UsePositionalParameters

                        $result | Should-BeString -CaseSensitive 'Should-BeGreaterThanOrEqual 2 3 -Because "this must return true"'
                    }
                }
            }

            Context 'When the tests are negated' {
                It 'Should convert `Should -BeGreaterOrEqual 2 -ActualValue 3 -Because "this must return true" -Not` correctly' {
                    InModuleScope -ScriptBlock {
                        $mockCommandAstPester5 = {
                            Should -BeGreaterOrEqual 2 -ActualValue 3 -Because "this must return true" -Not
                        }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                        $result = Convert-ShouldBeGreaterOrEqual -CommandAst $mockCommandAstPester5 -UsePositionalParameters

                        $result | Should-BeString -CaseSensitive 'Should-BeLessThanOrEqual 2 3 -Because "this must return true"'
                    }
                }
            }
        }
    }
}
