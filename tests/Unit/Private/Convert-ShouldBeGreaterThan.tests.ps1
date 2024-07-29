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

Describe 'Convert-ShouldBeGreaterThan' {
    Context 'When converting Pester 5 syntax to Pester 6 syntax' {
        BeforeAll {
            InModuleScope -ScriptBlock {
                $PSDefaultParameterValues['Convert-ShouldBeGreaterThan:Pester6'] = $true
            }
        }

        AfterAll {
            InModuleScope -ScriptBlock {
                $PSDefaultParameterValues.Remove('Convert-ShouldBeGreaterThan:Pester6')
            }
        }

        Context 'When the tests are affirming' {
            It 'Should convert `Should -BeGreaterThan 2` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -BeGreaterThan 2
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeGreaterThan -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-BeGreaterThan 2'
                }
            }

            It 'Should convert `Should -BeGreaterThan $numericValue` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -BeGreaterThan $numericValue
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeGreaterThan -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-BeGreaterThan $numericValue'
                }
            }

            It 'Should convert `Should -ActualValue 2 -BeGreaterThan 2` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -ActualValue 2 -BeGreaterThan 2
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeGreaterThan -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-BeGreaterThan 2 -Actual 2'
                }
            }

            It 'Should convert `Should -BeGreaterThan 2 -ActualValue 2` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -BeGreaterThan 2 -ActualValue 2
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeGreaterThan -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-BeGreaterThan 2 -Actual 2'
                }
            }

            It 'Should convert `Should -ActualValue 2 -BeGreaterThan -ExpectedValue 2` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -ActualValue 2 -BeGreaterThan -ExpectedValue 2
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeGreaterThan -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-BeGreaterThan -Actual 2 -Expected 2'
                }
            }

            It 'Should convert `Should -BeGreaterThan -ActualValue 2 -ExpectedValue 2` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -BeGreaterThan -ActualValue 2 -ExpectedValue 2
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeGreaterThan -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-BeGreaterThan -Actual 2 -Expected 2'
                }
            }

            It 'Should convert `Should -BeGreaterThan -ExpectedValue 2 -ActualValue 2` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -BeGreaterThan -ExpectedValue 2 -ActualValue 2
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeGreaterThan -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-BeGreaterThan -Actual 2 -Expected 2'
                }
            }

            It 'Should convert `Should -ExpectedValue 2 -BeGreaterThan -ActualValue 2` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -ExpectedValue 2 -BeGreaterThan -ActualValue 2
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeGreaterThan -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-BeGreaterThan -Actual 2 -Expected 2'
                }
            }

            It 'Should convert `Should -ExpectedValue 2 -ActualValue 2 -BeGreaterThan` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -ExpectedValue 2 -ActualValue 2 -BeGreaterThan
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeGreaterThan -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-BeGreaterThan -Actual 2 -Expected 2'
                }
            }

            It 'Should convert `Should -Not:$false -BeGreaterThan 2` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        3 | Should -Not:$false -BeGreaterThan 2
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeGreaterThan -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-BeGreaterThan 2'
                }
            }

            It 'Should convert `Should -BeGreaterThan (Get-Something)` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        function Get-Something { return 2 }
                        2 | Should -BeGreaterThan (Get-Something)
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeGreaterThan -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-BeGreaterThan (Get-Something)'
                }
            }

            It 'Should convert `Should -BeGreaterThan 2 -Because ''mock should test correct value'' 2` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -BeGreaterThan 2 -Because 'mock should test correct value' 2
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeGreaterThan -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-BeGreaterThan 2 2 -Because ''mock should test correct value'''
                }
            }

            It 'Should convert `Should -BeGreaterThan 2 ''mock should test correct value'' 3` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -BeGreaterThan 2 'mock should test correct value' 3
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeGreaterThan -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-BeGreaterThan 2 3 -Because ''mock should test correct value'''
                }
            }

            It 'Should convert `Should 2 ''mock should test correct value'' 3 -BeGreaterThan` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should 2 'mock should test correct value' 3 -BeGreaterThan
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeGreaterThan -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-BeGreaterThan 2 3 -Because ''mock should test correct value'''
                }
            }
        }

        Context 'When the tests are negated' {
            It 'Should convert `Should -Not -BeGreaterThan 2` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -Not -BeGreaterThan 2
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeGreaterThan -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-BeLessThanOrEqual 2'
                }
            }

            It 'Should convert `Should -BeGreaterThan 2 -Not` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -BeGreaterThan 2 -Not
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeGreaterThan -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-BeLessThanOrEqual 2'
                }
            }

            It 'Should convert `Should -Not -BeGreaterThan $anyValue` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -Not -BeGreaterThan $anyValue
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeGreaterThan -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-BeLessThanOrEqual $anyValue'
                }
            }

            It 'Should convert `Should -BeGreaterThan $anyValue -Not` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -BeGreaterThan $anyValue -Not
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeGreaterThan -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-BeLessThanOrEqual $anyValue'
                }
            }

            It 'Should convert `Should -Not:$true -BeGreaterThan 2` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        3 | Should -Not:$true -BeGreaterThan 2
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeGreaterThan -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-BeLessThanOrEqual 2'
                }
            }

            It 'Should convert `Should -Not -ActualValue 3 -BeGreaterThan 2` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -Not -ActualValue 3 -BeGreaterThan 2
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeGreaterThan -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-BeLessThanOrEqual 2 -Actual 3'
                }
            }

            It 'Should convert `Should -ActualValue 3 -Not -BeGreaterThan 2` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -ActualValue 3 -Not -BeGreaterThan 2
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeGreaterThan -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-BeLessThanOrEqual 2 -Actual 3'
                }
            }

            It 'Should convert `Should -ActualValue 3 -BeGreaterThan 2 -Not` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -ActualValue 3 -BeGreaterThan 2 -Not
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeGreaterThan -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-BeLessThanOrEqual 2 -Actual 3'
                }
            }

            It 'Should convert `Should -BeGreaterThan 2 -ActualValue 3 -Not` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -BeGreaterThan 2 -ActualValue 3 -Not
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeGreaterThan -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-BeLessThanOrEqual 2 -Actual 3'
                }
            }

            It 'Should convert `Should -BeGreaterThan 2 -Not -ActualValue 3` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -BeGreaterThan 2 -Not -ActualValue 3
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeGreaterThan -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-BeLessThanOrEqual 2 -Actual 3'
                }
            }

            It 'Should convert `Should -Not -BeGreaterThan 2 -ActualValue 3` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -Not -BeGreaterThan 2 -ActualValue 3
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeGreaterThan -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-BeLessThanOrEqual 2 -Actual 3'
                }
            }

            It 'Should convert `Should -ActualValue 3 -BeGreaterThan -Not -ExpectedValue 2` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -ActualValue 3 -BeGreaterThan -Not -ExpectedValue 2
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeGreaterThan -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-BeLessThanOrEqual -Actual 3 -Expected 2'
                }
            }

            It 'Should convert `Should -ActualValue 3 -Not -BeGreaterThan -ExpectedValue 2` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -ActualValue 3 -Not -BeGreaterThan -ExpectedValue 2
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeGreaterThan -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-BeLessThanOrEqual -Actual 3 -Expected 2'
                }
            }

            It 'Should convert `Should -ActualValue 3 -BeGreaterThan -ExpectedValue 2 -Not` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -ActualValue 3 -BeGreaterThan -ExpectedValue 2 -Not
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeGreaterThan -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-BeLessThanOrEqual -Actual 3 -Expected 2'
                }
            }
        }

        Context 'When alias operator name is used' {
            It 'Should convert `Should -GT 2 -ActualValue 3` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -GT 2 -ActualValue 3
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeGreaterThan -CommandAst $mockCommandAstPester5 -UseNamedParameters

                    $result | Should-BeString -CaseSensitive 'Should-BeGreaterThan -Actual 3 -Expected 2'
                }
            }
        }

        Context 'When tests should always use named parameters' {
            It 'Should convert `Should -BeGreaterThan 2 -ActualValue 3` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -BeGreaterThan 2 -ActualValue 3
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeGreaterThan -CommandAst $mockCommandAstPester5 -UseNamedParameters

                    $result | Should-BeString -CaseSensitive 'Should-BeGreaterThan -Actual 3 -Expected 2'
                }
            }
        }

        Context 'When tests should always use positional parameters' {
            Context 'When the tests are affirming' {
                It 'Should convert `Should -BeGreaterThan 2 -ActualValue 3` correctly' {
                    InModuleScope -ScriptBlock {
                        $mockCommandAstPester5 = {
                            Should -BeGreaterThan 2 -ActualValue 3
                        }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                        $result = Convert-ShouldBeGreaterThan -CommandAst $mockCommandAstPester5 -UsePositionalParameters

                        $result | Should-BeString -CaseSensitive 'Should-BeGreaterThan 2 3'
                    }
                }

                It 'Should convert `Should -BeGreaterThan 2 -ActualValue 3 -Because "this must return true"` correctly' {
                    InModuleScope -ScriptBlock {
                        $mockCommandAstPester5 = {
                            Should -BeGreaterThan 2 -ActualValue 3 -Because "this must return true"
                        }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                        $result = Convert-ShouldBeGreaterThan -CommandAst $mockCommandAstPester5 -UsePositionalParameters

                        $result | Should-BeString -CaseSensitive 'Should-BeGreaterThan 2 3 -Because "this must return true"'
                    }
                }

                It 'Should convert `Should -BeGreaterThan 2 -Because "this must return true" -ActualValue 3` correctly' {
                    InModuleScope -ScriptBlock {
                        $mockCommandAstPester5 = {
                            Should -BeGreaterThan 2 -Because "this must return true" -ActualValue 3
                        }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                        $result = Convert-ShouldBeGreaterThan -CommandAst $mockCommandAstPester5 -UsePositionalParameters

                        $result | Should-BeString -CaseSensitive 'Should-BeGreaterThan 2 3 -Because "this must return true"'
                    }
                }

                It 'Should convert `Should -Because "this must return true" -ActualValue 3 -BeGreaterThan 2` correctly' {
                    InModuleScope -ScriptBlock {
                        $mockCommandAstPester5 = {
                            Should -Because "this must return true" -ActualValue 3 -BeGreaterThan 2
                        }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                        $result = Convert-ShouldBeGreaterThan -CommandAst $mockCommandAstPester5 -UsePositionalParameters

                        $result | Should-BeString -CaseSensitive 'Should-BeGreaterThan 2 3 -Because "this must return true"'
                    }
                }
            }

            Context 'When the tests are negated' {
                It 'Should convert `Should -BeGreaterThan 2 -ActualValue 3 -Because "this must return true" -Not` correctly' {
                    InModuleScope -ScriptBlock {
                        $mockCommandAstPester5 = {
                            Should -BeGreaterThan 2 -ActualValue 3 -Because "this must return true" -Not
                        }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                        $result = Convert-ShouldBeGreaterThan -CommandAst $mockCommandAstPester5 -UsePositionalParameters

                        $result | Should-BeString -CaseSensitive 'Should-BeLessThanOrEqual 2 3 -Because "this must return true"'
                    }
                }
            }
        }
    }
}
