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

Describe 'Convert-ShouldBeLessThan' {
    Context 'When converting Pester 5 syntax to Pester 6 syntax' {
        BeforeAll {
            InModuleScope -ScriptBlock {
                $PSDefaultParameterValues['Convert-ShouldBeLessThan:Pester6'] = $true
            }
        }

        AfterAll {
            InModuleScope -ScriptBlock {
                $PSDefaultParameterValues.Remove('Convert-ShouldBeLessThan:Pester6')
            }
        }

        Context 'When the tests are affirming' {
            It 'Should convert `Should -BeLessThan 2` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -BeLessThan 2
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeLessThan -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-BeLessThan 2'
                }
            }

            It 'Should convert `Should -BeLessThan $numericValue` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -BeLessThan $numericValue
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeLessThan -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-BeLessThan $numericValue'
                }
            }

            It 'Should convert `Should -ActualValue 2 -BeLessThan 2` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -ActualValue 2 -BeLessThan 2
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeLessThan -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-BeLessThan 2 -Actual 2'
                }
            }

            It 'Should convert `Should -BeLessThan 2 -ActualValue 2` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -BeLessThan 2 -ActualValue 2
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeLessThan -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-BeLessThan 2 -Actual 2'
                }
            }

            It 'Should convert `Should -ActualValue 2 -BeLessThan -ExpectedValue 2` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -ActualValue 2 -BeLessThan -ExpectedValue 2
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeLessThan -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-BeLessThan -Actual 2 -Expected 2'
                }
            }

            It 'Should convert `Should -BeLessThan -ActualValue 2 -ExpectedValue 2` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -BeLessThan -ActualValue 2 -ExpectedValue 2
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeLessThan -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-BeLessThan -Actual 2 -Expected 2'
                }
            }

            It 'Should convert `Should -BeLessThan -ExpectedValue 2 -ActualValue 2` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -BeLessThan -ExpectedValue 2 -ActualValue 2
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeLessThan -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-BeLessThan -Actual 2 -Expected 2'
                }
            }

            It 'Should convert `Should -ExpectedValue 2 -BeLessThan -ActualValue 2` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -ExpectedValue 2 -BeLessThan -ActualValue 2
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeLessThan -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-BeLessThan -Actual 2 -Expected 2'
                }
            }

            It 'Should convert `Should -ExpectedValue 2 -ActualValue 2 -BeLessThan` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -ExpectedValue 2 -ActualValue 2 -BeLessThan
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeLessThan -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-BeLessThan -Actual 2 -Expected 2'
                }
            }

            It 'Should convert `Should -Not:$false -BeLessThan 2` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        $false | Should -Not:$false -BeLessThan 2
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeLessThan -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-BeLessThan 2'
                }
            }

            It 'Should convert `Should -BeLessThan (Get-Something)` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        function Get-Something { return 2 }
                        2 | Should -BeLessThan (Get-Something)
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeLessThan -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-BeLessThan (Get-Something)'
                }
            }

            It 'Should convert `Should -BeLessThan 2 -Because ''mock should test correct value'' 2` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -BeLessThan 2 -Because 'mock should test correct value' 2
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeLessThan -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-BeLessThan 2 2 -Because ''mock should test correct value'''
                }
            }

            It 'Should convert `Should -BeLessThan 2 ''mock should test correct value'' 3` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -BeLessThan 2 'mock should test correct value' 3
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeLessThan -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-BeLessThan 2 3 -Because ''mock should test correct value'''
                }
            }

            It 'Should convert `Should 2 ''mock should test correct value'' 3 -BeLessThan` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should 2 'mock should test correct value' 3 -BeLessThan
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeLessThan -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-BeLessThan 2 3 -Because ''mock should test correct value'''
                }
            }
        }

        Context 'When the tests are negated' {
            It 'Should convert `Should -Not -BeLessThan 2` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -Not -BeLessThan 2
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeLessThan -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-BeGreaterThanOrEqual 2'
                }
            }

            It 'Should convert `Should -BeLessThan 2 -Not` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -BeLessThan 2 -Not
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeLessThan -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-BeGreaterThanOrEqual 2'
                }
            }

            It 'Should convert `Should -Not -BeLessThan $anyValue` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -Not -BeLessThan $anyValue
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeLessThan -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-BeGreaterThanOrEqual $anyValue'
                }
            }

            It 'Should convert `Should -BeLessThan $anyValue -Not` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -BeLessThan $anyValue -Not
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeLessThan -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-BeGreaterThanOrEqual $anyValue'
                }
            }

            It 'Should convert `Should -Not:$true -BeLessThan 2` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        $false | Should -Not:$true -BeLessThan 2
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeLessThan -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-BeGreaterThanOrEqual 2'
                }
            }

            It 'Should convert `Should -Not -ActualValue 3 -BeLessThan 2` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -Not -ActualValue 3 -BeLessThan 2
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeLessThan -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-BeGreaterThanOrEqual 2 -Actual 3'
                }
            }

            It 'Should convert `Should -ActualValue 3 -Not -BeLessThan 2` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -ActualValue 3 -Not -BeLessThan 2
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeLessThan -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-BeGreaterThanOrEqual 2 -Actual 3'
                }
            }

            It 'Should convert `Should -ActualValue 3 -BeLessThan 2 -Not` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -ActualValue 3 -BeLessThan 2 -Not
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeLessThan -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-BeGreaterThanOrEqual 2 -Actual 3'
                }
            }

            It 'Should convert `Should -BeLessThan 2 -ActualValue 3 -Not` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -BeLessThan 2 -ActualValue 3 -Not
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeLessThan -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-BeGreaterThanOrEqual 2 -Actual 3'
                }
            }

            It 'Should convert `Should -BeLessThan 2 -Not -ActualValue 3` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -BeLessThan 2 -Not -ActualValue 3
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeLessThan -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-BeGreaterThanOrEqual 2 -Actual 3'
                }
            }

            It 'Should convert `Should -Not -BeLessThan 2 -ActualValue 3` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -Not -BeLessThan 2 -ActualValue 3
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeLessThan -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-BeGreaterThanOrEqual 2 -Actual 3'
                }
            }

            It 'Should convert `Should -ActualValue 3 -BeLessThan -Not -ExpectedValue 2` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -ActualValue 3 -BeLessThan -Not -ExpectedValue 2
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeLessThan -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-BeGreaterThanOrEqual -Actual 3 -Expected 2'
                }
            }

            It 'Should convert `Should -ActualValue 3 -Not -BeLessThan -ExpectedValue 2` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -ActualValue 3 -Not -BeLessThan -ExpectedValue 2
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeLessThan -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-BeGreaterThanOrEqual -Actual 3 -Expected 2'
                }
            }

            It 'Should convert `Should -ActualValue 3 -BeLessThan -ExpectedValue 2 -Not` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -ActualValue 3 -BeLessThan -ExpectedValue 2 -Not
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeLessThan -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-BeGreaterThanOrEqual -Actual 3 -Expected 2'
                }
            }
        }

        Context 'When alias operator name is used' {
            It 'Should convert `Should -LT 3 -ActualValue 2` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -LT 3 -ActualValue 2
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeLessThan -CommandAst $mockCommandAstPester5 -UseNamedParameters

                    $result | Should-BeString -CaseSensitive 'Should-BeLessThan -Actual 2 -Expected 3'
                }
            }
        }

        Context 'When tests should always use named parameters' {
            It 'Should convert `Should -BeLessThan 2 -ActualValue 3` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -BeLessThan 2 -ActualValue 3
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeLessThan -CommandAst $mockCommandAstPester5 -UseNamedParameters

                    $result | Should-BeString -CaseSensitive 'Should-BeLessThan -Actual 3 -Expected 2'
                }
            }
        }

        Context 'When tests should always use positional parameters' {
            Context 'When the tests are affirming' {
                It 'Should convert `Should -BeLessThan 2 -ActualValue 3` correctly' {
                    InModuleScope -ScriptBlock {
                        $mockCommandAstPester5 = {
                            Should -BeLessThan 2 -ActualValue 3
                        }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                        $result = Convert-ShouldBeLessThan -CommandAst $mockCommandAstPester5 -UsePositionalParameters

                        $result | Should-BeString -CaseSensitive 'Should-BeLessThan 2 3'
                    }
                }

                It 'Should convert `Should -BeLessThan 2 -ActualValue 3 -Because "this must return true"` correctly' {
                    InModuleScope -ScriptBlock {
                        $mockCommandAstPester5 = {
                            Should -BeLessThan 2 -ActualValue 3 -Because "this must return true"
                        }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                        $result = Convert-ShouldBeLessThan -CommandAst $mockCommandAstPester5 -UsePositionalParameters

                        $result | Should-BeString -CaseSensitive 'Should-BeLessThan 2 3 -Because "this must return true"'
                    }
                }

                It 'Should convert `Should -BeLessThan 2 -Because "this must return true" -ActualValue 3` correctly' {
                    InModuleScope -ScriptBlock {
                        $mockCommandAstPester5 = {
                            Should -BeLessThan 2 -Because "this must return true" -ActualValue 3
                        }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                        $result = Convert-ShouldBeLessThan -CommandAst $mockCommandAstPester5 -UsePositionalParameters

                        $result | Should-BeString -CaseSensitive 'Should-BeLessThan 2 3 -Because "this must return true"'
                    }
                }

                It 'Should convert `Should -Because "this must return true" -ActualValue 3 -BeLessThan 2` correctly' {
                    InModuleScope -ScriptBlock {
                        $mockCommandAstPester5 = {
                            Should -Because "this must return true" -ActualValue 3 -BeLessThan 2
                        }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                        $result = Convert-ShouldBeLessThan -CommandAst $mockCommandAstPester5 -UsePositionalParameters

                        $result | Should-BeString -CaseSensitive 'Should-BeLessThan 2 3 -Because "this must return true"'
                    }
                }
            }

            Context 'When the tests are negated' {
                It 'Should convert `Should -BeLessThan 2 -ActualValue 3 -Because "this must return true" -Not` correctly' {
                    InModuleScope -ScriptBlock {
                        $mockCommandAstPester5 = {
                            Should -BeLessThan 2 -ActualValue 3 -Because "this must return true" -Not
                        }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                        $result = Convert-ShouldBeLessThan -CommandAst $mockCommandAstPester5 -UsePositionalParameters

                        $result | Should-BeString -CaseSensitive 'Should-BeGreaterThanOrEqual 2 3 -Because "this must return true"'
                    }
                }
            }
        }
    }
}
