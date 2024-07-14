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

Describe 'Convert-ShouldBeIn' {
    Context 'When converting Pester 5 syntax to Pester 6 syntax' {
        BeforeAll {
            InModuleScope -ScriptBlock {
                $PSDefaultParameterValues['Convert-ShouldBeIn:Pester6'] = $true
            }
        }

        AfterAll {
            InModuleScope -ScriptBlock {
                $PSDefaultParameterValues.Remove('Convert-ShouldBeIn:Pester6')
            }
        }

        Context 'When the tests are affirming' {
            It 'Should convert `Should -BeIn @(''ExpectedValue1'', ''ExpectedValue2'') ''BecauseString'' ''ActualValue''` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -BeIn @('ExpectedValue1', 'ExpectedValue2') 'BecauseString' 'ActualValue'
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeIn -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-ContainCollection ''ActualValue'' @(''ExpectedValue1'', ''ExpectedValue2'') -Because ''BecauseString'''
                }
            }

            It 'Should convert `Should -BeIn @(''ExpectedValue1'', ''ExpectedValue2'') -Because ''BecauseString'' ''ActualValue''` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -BeIn @('ExpectedValue1', 'ExpectedValue2') -Because 'BecauseString' 'ActualValue'
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeIn -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-ContainCollection ''ActualValue'' @(''ExpectedValue1'', ''ExpectedValue2'') -Because ''BecauseString'''
                }
            }

            It 'Should convert `Should -BeIn -ExpectedValue @(''ExpectedValue1'', ''ExpectedValue2'') -Because ''BecauseString'' ''ActualValue''` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -BeIn -ExpectedValue @('ExpectedValue1', 'ExpectedValue2') -Because 'BecauseString' 'ActualValue'
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeIn -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-ContainCollection ''ActualValue'' -Actual @(''ExpectedValue1'', ''ExpectedValue2'') -Because ''BecauseString'''
                }
            }

            It 'Should convert `Should -BeIn -ExpectedValue @(''ExpectedValue1'', ''ExpectedValue2'') -Because ''BecauseString'' -ActualValue ''ActualValue''` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -BeIn -ExpectedValue @('ExpectedValue1', 'ExpectedValue2') -Because 'BecauseString' -ActualValue 'ActualValue'
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeIn -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-ContainCollection -Actual @(''ExpectedValue1'', ''ExpectedValue2'') -Because ''BecauseString'' -Expected ''ActualValue'''
                }
            }

            It 'Should convert `''ActualValue'' | Should -BeIn @(''ExpectedValue1'', ''ExpectedValue2'') -Because ''BecauseString''` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        'ActualValue' | Should -BeIn @('ExpectedValue1', 'ExpectedValue2') -Because 'BecauseString'
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeIn -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive '@(''ExpectedValue1'', ''ExpectedValue2'') | Should-ContainCollection (''ActualValue'') -Because ''BecauseString'''
                }
            }

            It 'Should convert `''ActualValue'' | Should -BeIn -Because ''BecauseString'' -ExpectedValue @(''ExpectedValue1'', ''ExpectedValue2'')` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        'ActualValue' | Should -BeIn -Because 'BecauseString' -ExpectedValue @('ExpectedValue1', 'ExpectedValue2')
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeIn -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive '@(''ExpectedValue1'', ''ExpectedValue2'') | Should-ContainCollection -Because ''BecauseString'' -Expected (''ActualValue'')'
                }
            }
        }

        Context 'When the tests are negated' {
            It 'Should convert `Should -Not -BeIn @(''ExpectedValue1'', ''ExpectedValue2'') ''BecauseString'' ''ActualValue''` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -Not -BeIn @('ExpectedValue1', 'ExpectedValue2') 'BecauseString' 'ActualValue'
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeIn -CommandAst $mockCommandAstPester5

                    $result | Should-BeString -CaseSensitive 'Should-NotContainCollection ''ActualValue'' @(''ExpectedValue1'', ''ExpectedValue2'') -Because ''BecauseString'''
                }
            }
        }

        Context 'When tests should always use named parameters' {
            It 'Should convert `Should -BeIn @(''ExpectedValue1'', ''ExpectedValue2'') ''BecauseString'' ''ActualValue''` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -BeIn @('ExpectedValue1', 'ExpectedValue2') 'BecauseString' 'ActualValue'
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeIn -CommandAst $mockCommandAstPester5 -UseNamedParameters

                    $result | Should-BeString -CaseSensitive 'Should-ContainCollection -Actual @(''ExpectedValue1'', ''ExpectedValue2'') -Because ''BecauseString'' -Expected ''ActualValue'''
                }
            }

            It 'Should convert `''ActualValue'' | Should -BeIn @(''ExpectedValue1'', ''ExpectedValue2'') ''BecauseString''` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        'ActualValue' | Should -BeIn @('ExpectedValue1', 'ExpectedValue2') 'BecauseString'
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeIn -CommandAst $mockCommandAstPester5 -UseNamedParameters

                    $result | Should-BeString -CaseSensitive '@(''ExpectedValue1'', ''ExpectedValue2'') | Should-ContainCollection -Because ''BecauseString'' -Expected (''ActualValue'')'
                }
            }

            It 'Should convert `''ActualValue'' | Get-Something | Should -BeIn @(''ExpectedValue1'', ''ExpectedValue2'') ''BecauseString''` correctly' {
                InModuleScope -ScriptBlock {
                    # Using FindAll() to get the correct AST element we need to pass.
                    $mockCommandAstPester5 = {
                        'ActualValue' | Get-Something | Should -BeIn @('ExpectedValue1', 'ExpectedValue2') 'BecauseString'
                    }.Ast.FindAll({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldBeIn -CommandAst $mockCommandAstPester5[1] -UseNamedParameters

                    $result | Should-BeString -CaseSensitive '@(''ExpectedValue1'', ''ExpectedValue2'') | Should-ContainCollection -Because ''BecauseString'' -Expected (''ActualValue'' | Get-Something)'
                }
            }
        }

        Context 'When tests should always use positional parameters' {
            Context 'When the tests are affirming' {
                It 'Should convert `Should -BeIn -ExpectedValue @(''ExpectedValue1'', ''ExpectedValue2'') -Because ''BecauseString'' -ActualValue ''ActualValue''` correctly' {
                    InModuleScope -ScriptBlock {
                        $mockCommandAstPester5 = {
                            Should -BeIn -ExpectedValue @('ExpectedValue1', 'ExpectedValue2') -Because 'BecauseString' -ActualValue 'ActualValue'
                        }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                        $result = Convert-ShouldBeIn -CommandAst $mockCommandAstPester5 -UsePositionalParameters

                        $result | Should-BeString -CaseSensitive 'Should-ContainCollection ''ActualValue'' @(''ExpectedValue1'', ''ExpectedValue2'') -Because ''BecauseString'''
                    }
                }

                It 'Should convert `''ActualValue'' | Should -BeIn -Because ''BecauseString'' -ExpectedValue @(''ExpectedValue1'', ''ExpectedValue2'')` correctly' {
                    InModuleScope -ScriptBlock {
                        $mockCommandAstPester5 = {
                            'ActualValue' | Should -BeIn -Because 'BecauseString' -ExpectedValue @('ExpectedValue1', 'ExpectedValue2')
                        }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                        $result = Convert-ShouldBeIn -CommandAst $mockCommandAstPester5 -UsePositionalParameters

                        $result | Should-BeString -CaseSensitive '@(''ExpectedValue1'', ''ExpectedValue2'') | Should-ContainCollection (''ActualValue'') -Because ''BecauseString'''
                    }
                }
            }

            Context 'When the tests are negated' {
                It 'Should convert `Should -Not -BeIn -ExpectedValue @(''ExpectedValue1'', ''ExpectedValue2'') -Because ''BecauseString'' -ActualValue ''ActualValue''` correctly' {
                    InModuleScope -ScriptBlock {
                        $mockCommandAstPester5 = {
                            Should -Not -BeIn -ExpectedValue @('ExpectedValue1', 'ExpectedValue2') -Because 'BecauseString' -ActualValue 'ActualValue'
                        }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                        $result = Convert-ShouldBeIn -CommandAst $mockCommandAstPester5 -UsePositionalParameters

                        $result | Should-BeString -CaseSensitive 'Should-NotContainCollection ''ActualValue'' @(''ExpectedValue1'', ''ExpectedValue2'') -Because ''BecauseString'''
                    }
                }

                It 'Should convert `''ActualValue'' | Should -Not -BeIn -Because ''BecauseString'' -ExpectedValue @(''ExpectedValue1'', ''ExpectedValue2'')` correctly' {
                    InModuleScope -ScriptBlock {
                        $mockCommandAstPester5 = {
                            'ActualValue' | Should -Not -BeIn -Because 'BecauseString' -ExpectedValue @('ExpectedValue1', 'ExpectedValue2')
                        }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                        $result = Convert-ShouldBeIn -CommandAst $mockCommandAstPester5 -UsePositionalParameters

                        $result | Should-BeString -CaseSensitive '@(''ExpectedValue1'', ''ExpectedValue2'') | Should-NotContainCollection (''ActualValue'') -Because ''BecauseString'''
                    }
                }
            }
        }
    }
}
