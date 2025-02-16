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

Describe 'Convert-AssertMockCalled' {
    Context 'When converting Pester 5 syntax to Pester 6 syntax' {
        BeforeAll {
            InModuleScope -ScriptBlock {
                $PSDefaultParameterValues['Convert-AssertMockCalled:Pester6'] = $true
            }
        }

        AfterAll {
            InModuleScope -ScriptBlock {
                $PSDefaultParameterValues.Remove('Convert-AssertMockCalled:Pester6')
            }
        }

        Context 'When the tests are affirming' {
            It 'Should convert `Assert-MockCalled` using default settings correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAst = {
                        Assert-MockCalled -CommandName 'TestCommand' -Exactly -Times 3
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-AssertMockCalled -CommandAst $mockCommandAst

                    $result | Should-BeString -CaseSensitive "Should-Invoke -CommandName 'TestCommand' -Exactly -Times 3"
                }
            }

            It 'Should convert `Assert-MockCalled` using named parameters correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAst = {
                        Assert-MockCalled -CommandName 'TestCommand' -Times 3 -Exactly
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-AssertMockCalled -CommandAst $mockCommandAst -UseNamedParameters

                    $result | Should-BeString -CaseSensitive "Should-Invoke -CommandName 'TestCommand' -Exactly -Times 3"
                }
            }

            It 'Should convert `Assert-MockCalled` using positional parameters correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAst = {
                        Assert-MockCalled -CommandName 'TestCommand' -Times 3 { $Name -eq $true }
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-AssertMockCalled -CommandAst $mockCommandAst -UsePositionalParameters

                    $result | Should-BeString -CaseSensitive 'Should-Invoke ''TestCommand'' 3 -ParameterFilter { $Name -eq $true }'
                }
            }
        }

        Context 'When additional parameters are provided' {
            It 'Should convert extra parameters using default settings correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAst = {
                        Assert-MockCalled -CommandName 'TestCommand' -Times 5 `
                            -ParameterFilter { $_.Name -eq 'test' } `
                            -ModuleName 'TestModule' `
                            -Scope 'Global' `
                            -Exactly
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $expected = 'Should-Invoke -CommandName ''TestCommand'' -Exactly -ModuleName ''TestModule'' -ParameterFilter { $_.Name -eq ''test'' } -Scope ''Global'' -Times 5'

                    $result = Convert-AssertMockCalled -CommandAst $mockCommandAst

                    $result | Should-BeString -CaseSensitive $expected
                }
            }

            It 'Should convert extra parameters using positional settings correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAst = {
                        Assert-MockCalled -CommandName 'TestCommand' -Times 5 `
                            -ParameterFilter { $_.Name -eq 'test' } `
                            -ModuleName 'TestModule' `
                            -Scope 'Global' `
                            -Exactly
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $expected = 'Should-Invoke ''TestCommand'' 5 -Exactly -ModuleName ''TestModule'' -ParameterFilter { $_.Name -eq ''test'' } -Scope ''Global'''

                    $result = Convert-AssertMockCalled -CommandAst $mockCommandAst -UsePositionalParameters

                    $result | Should-BeString -CaseSensitive $expected
                }
            }
        }
    }

    Context 'When converting Pester 4 syntax to Pester 5 syntax' {
        BeforeAll {
            InModuleScope -ScriptBlock {
                $PSDefaultParameterValues['Convert-AssertMockCalled:Pester5'] = $true
            }
        }

        AfterAll {
            InModuleScope -ScriptBlock {
                $PSDefaultParameterValues.Remove('Convert-AssertMockCalled:Pester5')
            }
        }

        Context 'When the tests are affirming' {
            It 'Should convert `Assert-MockCalled` using default settings correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAst = {
                        Assert-MockCalled -CommandName 'TestCommand' -Exactly -Times 3
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-AssertMockCalled -CommandAst $mockCommandAst

                    $result | Should-BeString -CaseSensitive "Should -Invoke -CommandName 'TestCommand' -Exactly -Times 3"
                }
            }

            It 'Should convert `Assert-MockCalled` using named parameters correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAst = {
                        Assert-MockCalled -CommandName 'TestCommand' -Times 3 -Exactly
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-AssertMockCalled -CommandAst $mockCommandAst -UseNamedParameters

                    $result | Should-BeString -CaseSensitive "Should -Invoke -CommandName 'TestCommand' -Exactly -Times 3"
                }
            }

            It 'Should convert `Assert-MockCalled` using positional parameters correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAst = {
                        Assert-MockCalled -CommandName 'TestCommand' -Times 3 { $Name -eq $true }
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-AssertMockCalled -CommandAst $mockCommandAst -UsePositionalParameters

                    $result | Should-BeString -CaseSensitive 'Should -Invoke ''TestCommand'' 3 -ParameterFilter { $Name -eq $true }'
                }
            }
        }

        Context 'When additional parameters are provided' {
            It 'Should convert extra parameters using default settings correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAst = {
                        Assert-MockCalled -CommandName 'TestCommand' -Times 5 `
                            -ParameterFilter { $_.Name -eq 'test' } `
                            -ModuleName 'TestModule' `
                            -Scope 'Global' `
                            -Exactly
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $expected = 'Should -Invoke -CommandName ''TestCommand'' -Exactly -ModuleName ''TestModule'' -ParameterFilter { $_.Name -eq ''test'' } -Scope ''Global'' -Times 5'

                    $result = Convert-AssertMockCalled -CommandAst $mockCommandAst

                    $result | Should-BeString -CaseSensitive $expected
                }
            }

            It 'Should convert extra parameters using positional settings correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAst = {
                        Assert-MockCalled -CommandName 'TestCommand' -Times 5 `
                            -ParameterFilter { $_.Name -eq 'test' } `
                            -ModuleName 'TestModule' `
                            -Scope 'Global' `
                            -Exactly
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $expected = 'Should -Invoke ''TestCommand'' 5 -Exactly -ModuleName ''TestModule'' -ParameterFilter { $_.Name -eq ''test'' } -Scope ''Global'''

                    $result = Convert-AssertMockCalled -CommandAst $mockCommandAst -UsePositionalParameters

                    $result | Should-BeString -CaseSensitive $expected
                }
            }
        }
    }
}
