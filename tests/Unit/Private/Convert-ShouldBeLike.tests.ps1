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

Describe 'Convert-ShouldBeLike' {
    Context 'When converting Pester 5 syntax to Pester 6 syntax' {
        BeforeAll {
            InModuleScope -ScriptBlock {
                $PSDefaultParameterValues['Convert-ShouldBeLike:Pester6'] = $true
            }
        }

        AfterAll {
            InModuleScope -ScriptBlock {
                $PSDefaultParameterValues.Remove('Convert-ShouldBeLike:Pester6')
            }
        }

        Context 'When the tests are affirming' {
            It 'Should convert `Should -BeLike ''Test*''` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -BeLike 'Test*'
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeLike -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-BeLikeString ''Test*'''
                }
            }

            It 'Should convert `Should -BeLike "ExpectedString*"` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -BeLike "ExpectedString*"
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeLike -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-BeLikeString "ExpectedString*"'
                }
            }

            It 'Should convert `Should -BeLike ''ExpectedString*''` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -BeLike 'ExpectedString*'
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeLike -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-BeLikeString ''ExpectedString*'''
                }
            }

            It 'Should convert `Should -BeLike $anyValue` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -BeLike $anyValue
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeLike -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-BeLikeString $anyValue'
                }
            }

            It 'Should convert `Should -ActualValue ''ActualString'' -BeLike ''ExpectedString*''` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -ActualValue 'ActualString' -BeLike 'ExpectedString*'
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeLike -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-BeLikeString ''ExpectedString*'' -Actual ''ActualString'''
                }
            }

            It 'Should convert `Should -BeLike ''ExpectedString*'' -ActualValue ''ActualString''` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -BeLike 'ExpectedString*' -ActualValue 'ActualString'
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeLike -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-BeLikeString ''ExpectedString*'' -Actual ''ActualString'''
                }
            }

            It 'Should convert `Should -ActualValue ''ActualString'' -BeLike -ExpectedValue ''ExpectedString*''` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -ActualValue 'ActualString' -BeLike -ExpectedValue 'ExpectedString*'
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeLike -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-BeLikeString -Actual ''ActualString'' -Expected ''ExpectedString*'''
                }
            }

            It 'Should convert `Should -BeLike -ActualValue ''ActualString'' -ExpectedValue ''ExpectedString*''` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -BeLike -ActualValue 'ActualString' -ExpectedValue 'ExpectedString*'
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeLike -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-BeLikeString -Actual ''ActualString'' -Expected ''ExpectedString*'''
                }
            }

            It 'Should convert `Should -BeLike -ExpectedValue ''ExpectedString*'' -ActualValue ''ActualString''` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -BeLike -ExpectedValue 'ExpectedString*' -ActualValue 'ActualString'
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeLike -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-BeLikeString -Actual ''ActualString'' -Expected ''ExpectedString*'''
                }
            }

            It 'Should convert `Should -ExpectedValue ''ExpectedString*'' -BeLike -ActualValue ''ActualString''` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -ExpectedValue 'ExpectedString*' -BeLike -ActualValue 'ActualString'
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeLike -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-BeLikeString -Actual ''ActualString'' -Expected ''ExpectedString*'''
                }
            }

            It 'Should convert `Should -ExpectedValue ''ExpectedString*'' -ActualValue ''ActualString'' -BeLike` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -ExpectedValue 'ExpectedString*' -ActualValue 'ActualString' -BeLike
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeLike -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-BeLikeString -Actual ''ActualString'' -Expected ''ExpectedString*'''
                }
            }

            It 'Should convert `Should -Not:$false -BeLike ''ExpectedString*''` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        'TestValue' | Should -Not:$false -BeLike 'ExpectedString*'
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeLike -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-BeLikeString ''ExpectedString*'''
                }
            }

            It 'Should convert `Should -BeLike (Get-Something)` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        function Get-Something { return 'ExpectedString*' }
                        'ExpectedString*' | Should -BeLike (Get-Something)
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeLike -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-BeLikeString (Get-Something)'
                }
            }

            It 'Should convert `Should -BeLike ''ExpectedString*'' -Because ''mock should test correct value'' ''ActualString''` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -BeLike 'ExpectedString*' -Because 'mock should test correct value' 'ActualString*'
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeLike -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-BeLikeString ''ExpectedString*'' ''ActualString*'' -Because ''mock should test correct value'''
                }
            }

            It 'Should convert `Should -BeLike ''ExpectedString*'' ''mock should test correct value'' ''ActualString''` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -BeLike 'ExpectedString*' 'mock should test correct value' 'ActualString'
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeLike -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-BeLikeString ''ExpectedString*'' ''ActualString'' -Because ''mock should test correct value'''
                }
            }

            It 'Should convert `Should ''ExpectedString*'' ''mock should test correct value'' ''ActualString'' -BeLike` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should 'ExpectedString*' 'mock should test correct value' 'ActualString' -BeLike
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeLike -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-BeLikeString ''ExpectedString*'' ''ActualString'' -Because ''mock should test correct value'''
                }
            }
        }

        Context 'When the tests are negated' {
            It 'Should convert `Should -Not -BeLike ''ExpectedString*''` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -Not -BeLike 'ExpectedString*'
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeLike -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-NotBeLikeString ''ExpectedString*'''
                }
            }

            It 'Should convert `Should -BeLike ''Test*'' -Not` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -BeLike 'Test*' -Not
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeLike -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-NotBeLikeString ''Test*'''
                }
            }

            It 'Should convert `Should -Not -BeLike "ExpectedString*"` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -Not -BeLike "ExpectedString*"
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeLike -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-NotBeLikeString "ExpectedString*"'
                }
            }

            It 'Should convert `Should -Not -BeLike $anyValue` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -Not -BeLike $anyValue
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeLike -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-NotBeLikeString $anyValue'
                }
            }

            It 'Should convert `Should -BeLike $anyValue -Not` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -BeLike $anyValue -Not
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeLike -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-NotBeLikeString $anyValue'
                }
            }

            It 'Should convert `Should -Not:$true -BeLike ''ExpectedString*''` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        'TestValue' | Should -Not:$true -BeLike 'ExpectedString*'
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeLike -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-NotBeLikeString ''ExpectedString*'''
                }
            }

            It 'Should convert `Should -Not -ActualValue ''ActualString'' -BeLike ''ExpectedString*''` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -Not -ActualValue 'ActualString' -BeLike 'ExpectedString*'
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeLike -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-NotBeLikeString ''ExpectedString*'' -Actual ''ActualString'''
                }
            }

            It 'Should convert `Should -ActualValue ''ActualString'' -Not -BeLike ''ExpectedString*''` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -ActualValue 'ActualString' -Not -BeLike 'ExpectedString*'
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeLike -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-NotBeLikeString ''ExpectedString*'' -Actual ''ActualString'''
                }
            }

            It 'Should convert `Should -ActualValue ''ActualString'' -BeLike ''ExpectedString*'' -Not` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -ActualValue 'ActualString' -BeLike 'ExpectedString*' -Not
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeLike -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-NotBeLikeString ''ExpectedString*'' -Actual ''ActualString'''
                }
            }

            It 'Should convert `Should -BeLike ''ExpectedString*'' -ActualValue ''ActualString'' -Not` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -BeLike 'ExpectedString*' -ActualValue 'ActualString' -Not
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeLike -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-NotBeLikeString ''ExpectedString*'' -Actual ''ActualString'''
                }
            }

            It 'Should convert `Should -BeLike ''ExpectedString*'' -Not -ActualValue ''ActualString''` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -BeLike 'ExpectedString*' -Not -ActualValue 'ActualString'
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeLike -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-NotBeLikeString ''ExpectedString*'' -Actual ''ActualString'''
                }
            }

            It 'Should convert `Should -Not -BeLike ''ExpectedString*'' -ActualValue ''ActualString''` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -Not -BeLike 'ExpectedString*' -ActualValue 'ActualString'
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeLike -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-NotBeLikeString ''ExpectedString*'' -Actual ''ActualString'''
                }
            }

            It 'Should convert `Should -ActualValue ''ActualString'' -BeLike -Not -ExpectedValue ''ExpectedString*''` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -ActualValue 'ActualString' -BeLike -Not -ExpectedValue 'ExpectedString*'
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeLike -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-NotBeLikeString -Actual ''ActualString'' -Expected ''ExpectedString*'''
                }
            }

            It 'Should convert `Should -ActualValue ''ActualString'' -Not -BeLike -ExpectedValue ''ExpectedString*''` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -ActualValue 'ActualString' -Not -BeLike -ExpectedValue 'ExpectedString*'
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeLike -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-NotBeLikeString -Actual ''ActualString'' -Expected ''ExpectedString*'''
                }
            }

            It 'Should convert `Should -ActualValue ''ActualString'' -BeLike -ExpectedValue ''ExpectedString*'' -Not` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -ActualValue 'ActualString' -BeLike -ExpectedValue 'ExpectedString*' -Not
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeLike -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-NotBeLikeString -Actual ''ActualString'' -Expected ''ExpectedString*'''
                }
            }
        }

        Context 'When tests should always use named parameters' {
            It 'Should convert `Should -BeLike ''ExpectedString*'' -ActualValue ''ActualString''` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -BeLike 'ExpectedString*' -ActualValue 'ActualString'
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeLike -CommandAst $mockCommandAstPester5 -UseNamedParameters

                    $result | Should-BeString -CaseSensitive 'Should-BeLikeString -Actual ''ActualString'' -Expected ''ExpectedString*'''
                }
            }
        }

        Context 'When tests should always use positional parameters' {
            Context 'When the tests are affirming' {
                It 'Should convert `Should -BeLike ''ExpectedString*'' -ActualValue ''ActualString''` correctly' {
                    InModuleScope -ScriptBlock {
                        $mockCommandAstPester5 = {
                            Should -BeLike 'ExpectedString*' -ActualValue 'ActualString'
                        }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                        $result = Convert-ShouldBeLike -CommandAst $mockCommandAstPester5 -UsePositionalParameters

                        $result | Should-BeString -CaseSensitive 'Should-BeLikeString ''ExpectedString*'' ''ActualString'''
                    }
                }

                It 'Should convert `Should -BeLike ''ExpectedString*'' -ActualValue ''ActualString'' -Because "this must return true"` correctly' {
                    InModuleScope -ScriptBlock {
                        $mockCommandAstPester5 = {
                            Should -BeLike 'ExpectedString*' -ActualValue 'ActualString' -Because "this must return true"
                        }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                        $result = Convert-ShouldBeLike -CommandAst $mockCommandAstPester5 -UsePositionalParameters

                        $result | Should-BeString -CaseSensitive 'Should-BeLikeString ''ExpectedString*'' ''ActualString'' -Because "this must return true"'
                    }
                }

                It 'Should convert `Should -BeLike ''ExpectedString*'' -Because "this must return true" -ActualValue ''ActualString''` correctly' {
                    InModuleScope -ScriptBlock {
                        $mockCommandAstPester5 = {
                            Should -BeLike 'ExpectedString*' -Because "this must return true" -ActualValue 'ActualString'
                        }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                        $result = Convert-ShouldBeLike -CommandAst $mockCommandAstPester5 -UsePositionalParameters

                        $result | Should-BeString -CaseSensitive 'Should-BeLikeString ''ExpectedString*'' ''ActualString'' -Because "this must return true"'
                    }
                }

                It 'Should convert `Should -Because "this must return true" -ActualValue ''ActualString'' -BeLike ''ExpectedString*''` correctly' {
                    InModuleScope -ScriptBlock {
                        $mockCommandAstPester5 = {
                            Should -Because "this must return true" -ActualValue 'ActualString' -BeLike 'ExpectedString*'
                        }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                        $result = Convert-ShouldBeLike -CommandAst $mockCommandAstPester5 -UsePositionalParameters

                        $result | Should-BeString -CaseSensitive 'Should-BeLikeString ''ExpectedString*'' ''ActualString'' -Because "this must return true"'
                    }
                }
            }

            Context 'When the tests are negated' {
                It 'Should convert `Should -BeLike ''ExpectedString*'' -ActualValue ''ActualString'' -Because "this must return true" -Not` correctly' {
                    InModuleScope -ScriptBlock {
                        $mockCommandAstPester5 = {
                            Should -BeLike 'ExpectedString*' -ActualValue 'ActualString' -Because "this must return true" -Not
                        }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                        $result = Convert-ShouldBeLike -CommandAst $mockCommandAstPester5 -UsePositionalParameters

                        $result | Should-BeString -CaseSensitive 'Should-NotBeLikeString ''ExpectedString*'' ''ActualString'' -Because "this must return true"'
                    }
                }
            }
        }
    }
}
