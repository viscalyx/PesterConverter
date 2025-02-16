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
    Context 'When converting Assert-MockCalled to Should -Invoke' {

        Context 'When the tests are affirming' {
            It 'Should convert `Assert-MockCalled` using default settings correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAst = {
                        Assert-MockCalled -CommandName 'TestCommand' -Times 3 -Because 'BecauseString'
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-AssertMockCalled -CommandAst $mockCommandAst

                    $result | Should-BeString -CaseSensitive "Should-Invoke 'TestCommand' -Because 'BecauseString' -Times 3"
                }
            }

            It 'Should convert `Assert-MockCalled` using named parameters correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAst = {
                        Assert-MockCalled -CommandName 'TestCommand' -Times 3 -Because 'BecauseString'
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-AssertMockCalled -CommandAst $mockCommandAst -UseNamedParameters

                    $result | Should-BeString -CaseSensitive "Should-Invoke -Because 'BecauseString' -CommandName 'TestCommand' -Times 3"
                }
            }

            It 'Should convert `Assert-MockCalled` using positional parameters correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAst = {
                        Assert-MockCalled -CommandName 'TestCommand' -Times 3 -Because 'BecauseString'
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-AssertMockCalled -CommandAst $mockCommandAst -UsePositionalParameters

                    $result | Should-BeString -CaseSensitive "Should-Invoke 'TestCommand' 3 -Because 'BecauseString'"
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
                            -Exactly `
                            -Because 'ExtraBecause'
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $expected = 'Should-Invoke ''TestCommand'' -Because ''ExtraBecause'' -Exactly -ModuleName ''TestModule'' -ParameterFilter { $_.Name -eq ''test'' } -Scope ''Global'' -Times 5'

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
                            -Exactly `
                            -Because 'ExtraBecause'
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $expected = 'Should-Invoke ''TestCommand'' 5 -Because ''ExtraBecause'' -Exactly -ModuleName ''TestModule'' -ParameterFilter { $_.Name -eq ''test'' } -Scope ''Global'''

                    $result = Convert-AssertMockCalled -CommandAst $mockCommandAst -UsePositionalParameters

                    $result | Should-BeString -CaseSensitive $expected
                }
            }
        }
    }
}
