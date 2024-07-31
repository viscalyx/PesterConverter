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

Describe 'Convert-ShouldBeLikeExactly' {
    Context 'When converting Pester 5 syntax to Pester 6 syntax' {
        BeforeAll {
            InModuleScope -ScriptBlock {
                $PSDefaultParameterValues['Convert-ShouldBeLikeExactly:Pester6'] = $true
            }
        }

        AfterAll {
            InModuleScope -ScriptBlock {
                $PSDefaultParameterValues.Remove('Convert-ShouldBeLikeExactly:Pester6')
            }
        }

        Context 'When the tests are affirming' {
            It 'Should convert `Should -BeLikeExactly ''Test*''` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -BeLikeExactly 'Test*'
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeLikeExactly -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-BeLikeString -CaseSensitive ''Test*'''
                }
            }

            It 'Should convert `Should -BeLikeExactly "ExpectedString*"` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -BeLikeExactly "ExpectedString*"
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeLikeExactly -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-BeLikeString -CaseSensitive "ExpectedString*"'
                }
            }

            It 'Should convert `Should -BeLikeExactly ''ExpectedString*''` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -BeLikeExactly 'ExpectedString*'
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeLikeExactly -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-BeLikeString -CaseSensitive ''ExpectedString*'''
                }
            }

            It 'Should convert `Should -BeLikeExactly $anyValue` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -BeLikeExactly $anyValue
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeLikeExactly -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-BeLikeString -CaseSensitive $anyValue'
                }
            }

            It 'Should convert `Should -ActualValue ''ActualString'' -BeLikeExactly ''ExpectedString*''` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -ActualValue 'ActualString' -BeLikeExactly 'ExpectedString*'
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeLikeExactly -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-BeLikeString -CaseSensitive ''ExpectedString*'' -Actual ''ActualString'''
                }
            }

            It 'Should convert `Should -BeLikeExactly ''ExpectedString*'' -ActualValue ''ActualString''` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -BeLikeExactly 'ExpectedString*' -ActualValue 'ActualString'
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeLikeExactly -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-BeLikeString -CaseSensitive ''ExpectedString*'' -Actual ''ActualString'''
                }
            }

            It 'Should convert `Should -ActualValue ''ActualString'' -BeLikeExactly -ExpectedValue ''ExpectedString*''` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -ActualValue 'ActualString' -BeLikeExactly -ExpectedValue 'ExpectedString*'
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeLikeExactly -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-BeLikeString -CaseSensitive -Actual ''ActualString'' -Expected ''ExpectedString*'''
                }
            }

            It 'Should convert `Should -BeLikeExactly -ActualValue ''ActualString'' -ExpectedValue ''ExpectedString*''` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -BeLikeExactly -ActualValue 'ActualString' -ExpectedValue 'ExpectedString*'
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeLikeExactly -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-BeLikeString -CaseSensitive -Actual ''ActualString'' -Expected ''ExpectedString*'''
                }
            }

            It 'Should convert `Should -BeLikeExactly -ExpectedValue ''ExpectedString*'' -ActualValue ''ActualString''` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -BeLikeExactly -ExpectedValue 'ExpectedString*' -ActualValue 'ActualString'
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeLikeExactly -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-BeLikeString -CaseSensitive -Actual ''ActualString'' -Expected ''ExpectedString*'''
                }
            }

            It 'Should convert `Should -ExpectedValue ''ExpectedString*'' -BeLikeExactly -ActualValue ''ActualString''` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -ExpectedValue 'ExpectedString*' -BeLikeExactly -ActualValue 'ActualString'
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeLikeExactly -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-BeLikeString -CaseSensitive -Actual ''ActualString'' -Expected ''ExpectedString*'''
                }
            }

            It 'Should convert `Should -ExpectedValue ''ExpectedString*'' -ActualValue ''ActualString'' -BeLikeExactly` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -ExpectedValue 'ExpectedString*' -ActualValue 'ActualString' -BeLikeExactly
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeLikeExactly -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-BeLikeString -CaseSensitive -Actual ''ActualString'' -Expected ''ExpectedString*'''
                }
            }

            It 'Should convert `Should -Not:$false -BeLikeExactly ''ExpectedString*''` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        'TestValue' | Should -Not:$false -BeLikeExactly 'ExpectedString*'
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeLikeExactly -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-BeLikeString -CaseSensitive ''ExpectedString*'''
                }
            }

            It 'Should convert `Should -BeLikeExactly (Get-Something)` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        function Get-Something { return 'ExpectedString*' }
                        'ExpectedString*' | Should -BeLikeExactly (Get-Something)
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeLikeExactly -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-BeLikeString -CaseSensitive (Get-Something)'
                }
            }

            It 'Should convert `Should -BeLikeExactly ''ExpectedString*'' -Because ''mock should test correct value'' ''ActualString''` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -BeLikeExactly 'ExpectedString*' -Because 'mock should test correct value' 'ActualString*'
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeLikeExactly -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-BeLikeString -CaseSensitive ''ExpectedString*'' ''ActualString*'' -Because ''mock should test correct value'''
                }
            }

            It 'Should convert `Should -BeLikeExactly ''ExpectedString*'' ''mock should test correct value'' ''ActualString''` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -BeLikeExactly 'ExpectedString*' 'mock should test correct value' 'ActualString'
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeLikeExactly -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-BeLikeString -CaseSensitive ''ExpectedString*'' ''ActualString'' -Because ''mock should test correct value'''
                }
            }

            It 'Should convert `Should ''ExpectedString*'' ''mock should test correct value'' ''ActualString'' -BeLikeExactly` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should 'ExpectedString*' 'mock should test correct value' 'ActualString' -BeLikeExactly
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeLikeExactly -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-BeLikeString -CaseSensitive ''ExpectedString*'' ''ActualString'' -Because ''mock should test correct value'''
                }
            }
        }

        Context 'When the tests are negated' {
            It 'Should convert `Should -Not -BeLikeExactly ''ExpectedString*''` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -Not -BeLikeExactly 'ExpectedString*'
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeLikeExactly -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-NotBeLikeString -CaseSensitive ''ExpectedString*'''
                }
            }

            It 'Should convert `Should -BeLikeExactly ''Test*'' -Not` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -BeLikeExactly 'Test*' -Not
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeLikeExactly -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-NotBeLikeString -CaseSensitive ''Test*'''
                }
            }

            It 'Should convert `Should -Not -BeLikeExactly "ExpectedString*"` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -Not -BeLikeExactly "ExpectedString*"
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeLikeExactly -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-NotBeLikeString -CaseSensitive "ExpectedString*"'
                }
            }

            It 'Should convert `Should -Not -BeLikeExactly $anyValue` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -Not -BeLikeExactly $anyValue
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeLikeExactly -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-NotBeLikeString -CaseSensitive $anyValue'
                }
            }

            It 'Should convert `Should -BeLikeExactly $anyValue -Not` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -BeLikeExactly $anyValue -Not
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeLikeExactly -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-NotBeLikeString -CaseSensitive $anyValue'
                }
            }

            It 'Should convert `Should -Not:$true -BeLikeExactly ''ExpectedString*''` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        'TestValue' | Should -Not:$true -BeLikeExactly 'ExpectedString*'
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeLikeExactly -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-NotBeLikeString -CaseSensitive ''ExpectedString*'''
                }
            }

            It 'Should convert `Should -Not -ActualValue ''ActualString'' -BeLikeExactly ''ExpectedString*''` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -Not -ActualValue 'ActualString' -BeLikeExactly 'ExpectedString*'
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeLikeExactly -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-NotBeLikeString -CaseSensitive ''ExpectedString*'' -Actual ''ActualString'''
                }
            }

            It 'Should convert `Should -ActualValue ''ActualString'' -Not -BeLikeExactly ''ExpectedString*''` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -ActualValue 'ActualString' -Not -BeLikeExactly 'ExpectedString*'
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeLikeExactly -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-NotBeLikeString -CaseSensitive ''ExpectedString*'' -Actual ''ActualString'''
                }
            }

            It 'Should convert `Should -ActualValue ''ActualString'' -BeLikeExactly ''ExpectedString*'' -Not` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -ActualValue 'ActualString' -BeLikeExactly 'ExpectedString*' -Not
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeLikeExactly -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-NotBeLikeString -CaseSensitive ''ExpectedString*'' -Actual ''ActualString'''
                }
            }

            It 'Should convert `Should -BeLikeExactly ''ExpectedString*'' -ActualValue ''ActualString'' -Not` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -BeLikeExactly 'ExpectedString*' -ActualValue 'ActualString' -Not
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeLikeExactly -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-NotBeLikeString -CaseSensitive ''ExpectedString*'' -Actual ''ActualString'''
                }
            }

            It 'Should convert `Should -BeLikeExactly ''ExpectedString*'' -Not -ActualValue ''ActualString''` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -BeLikeExactly 'ExpectedString*' -Not -ActualValue 'ActualString'
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeLikeExactly -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-NotBeLikeString -CaseSensitive ''ExpectedString*'' -Actual ''ActualString'''
                }
            }

            It 'Should convert `Should -Not -BeLikeExactly ''ExpectedString*'' -ActualValue ''ActualString''` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -Not -BeLikeExactly 'ExpectedString*' -ActualValue 'ActualString'
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeLikeExactly -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-NotBeLikeString -CaseSensitive ''ExpectedString*'' -Actual ''ActualString'''
                }
            }

            It 'Should convert `Should -ActualValue ''ActualString'' -BeLikeExactly -Not -ExpectedValue ''ExpectedString*''` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -ActualValue 'ActualString' -BeLikeExactly -Not -ExpectedValue 'ExpectedString*'
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeLikeExactly -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-NotBeLikeString -CaseSensitive -Actual ''ActualString'' -Expected ''ExpectedString*'''
                }
            }

            It 'Should convert `Should -ActualValue ''ActualString'' -Not -BeLikeExactly -ExpectedValue ''ExpectedString*''` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -ActualValue 'ActualString' -Not -BeLikeExactly -ExpectedValue 'ExpectedString*'
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeLikeExactly -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-NotBeLikeString -CaseSensitive -Actual ''ActualString'' -Expected ''ExpectedString*'''
                }
            }

            It 'Should convert `Should -ActualValue ''ActualString'' -BeLikeExactly -ExpectedValue ''ExpectedString*'' -Not` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -ActualValue 'ActualString' -BeLikeExactly -ExpectedValue 'ExpectedString*' -Not
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeLikeExactly -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-NotBeLikeString -CaseSensitive -Actual ''ActualString'' -Expected ''ExpectedString*'''
                }
            }
        }

        Context 'When tests should always use named parameters' {
            It 'Should convert `Should -BeLikeExactly ''ExpectedString*'' -ActualValue ''ActualString''` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -BeLikeExactly 'ExpectedString*' -ActualValue 'ActualString'
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeLikeExactly -CommandAst $mockCommandAstPester5 -UseNamedParameters

                    $result | Should-BeString -CaseSensitive 'Should-BeLikeString -CaseSensitive -Actual ''ActualString'' -Expected ''ExpectedString*'''
                }
            }
        }

        Context 'When tests should always use positional parameters' {
            Context 'When the tests are affirming' {
                It 'Should convert `Should -BeLikeExactly ''ExpectedString*'' -ActualValue ''ActualString''` correctly' {
                    InModuleScope -ScriptBlock {
                        $mockCommandAstPester5 = {
                            Should -BeLikeExactly 'ExpectedString*' -ActualValue 'ActualString'
                        }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                        $result = Convert-ShouldBeLikeExactly -CommandAst $mockCommandAstPester5 -UsePositionalParameters

                        $result | Should-BeString -CaseSensitive 'Should-BeLikeString -CaseSensitive ''ExpectedString*'' ''ActualString'''
                    }
                }

                It 'Should convert `Should -BeLikeExactly ''ExpectedString*'' -ActualValue ''ActualString'' -Because "this must return true"` correctly' {
                    InModuleScope -ScriptBlock {
                        $mockCommandAstPester5 = {
                            Should -BeLikeExactly 'ExpectedString*' -ActualValue 'ActualString' -Because "this must return true"
                        }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                        $result = Convert-ShouldBeLikeExactly -CommandAst $mockCommandAstPester5 -UsePositionalParameters

                        $result | Should-BeString -CaseSensitive 'Should-BeLikeString -CaseSensitive ''ExpectedString*'' ''ActualString'' -Because "this must return true"'
                    }
                }

                It 'Should convert `Should -BeLikeExactly ''ExpectedString*'' -Because "this must return true" -ActualValue ''ActualString''` correctly' {
                    InModuleScope -ScriptBlock {
                        $mockCommandAstPester5 = {
                            Should -BeLikeExactly 'ExpectedString*' -Because "this must return true" -ActualValue 'ActualString'
                        }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                        $result = Convert-ShouldBeLikeExactly -CommandAst $mockCommandAstPester5 -UsePositionalParameters

                        $result | Should-BeString -CaseSensitive 'Should-BeLikeString -CaseSensitive ''ExpectedString*'' ''ActualString'' -Because "this must return true"'
                    }
                }

                It 'Should convert `Should -Because "this must return true" -ActualValue ''ActualString'' -BeLikeExactly ''ExpectedString*''` correctly' {
                    InModuleScope -ScriptBlock {
                        $mockCommandAstPester5 = {
                            Should -Because "this must return true" -ActualValue 'ActualString' -BeLikeExactly 'ExpectedString*'
                        }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                        $result = Convert-ShouldBeLikeExactly -CommandAst $mockCommandAstPester5 -UsePositionalParameters

                        $result | Should-BeString -CaseSensitive 'Should-BeLikeString -CaseSensitive ''ExpectedString*'' ''ActualString'' -Because "this must return true"'
                    }
                }
            }

            Context 'When the tests are negated' {
                It 'Should convert `Should -BeLikeExactly ''ExpectedString*'' -ActualValue ''ActualString'' -Because "this must return true" -Not` correctly' {
                    InModuleScope -ScriptBlock {
                        $mockCommandAstPester5 = {
                            Should -BeLikeExactly 'ExpectedString*' -ActualValue 'ActualString' -Because "this must return true" -Not
                        }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                        $result = Convert-ShouldBeLikeExactly -CommandAst $mockCommandAstPester5 -UsePositionalParameters

                        $result | Should-BeString -CaseSensitive 'Should-NotBeLikeString -CaseSensitive ''ExpectedString*'' ''ActualString'' -Because "this must return true"'
                    }
                }
            }
        }
    }
}
