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

Describe 'Convert-ShouldHaveCount' {
    Context 'When converting Pester 5 syntax to Pester 6 syntax' {
        BeforeAll {
            InModuleScope -ScriptBlock {
                $PSDefaultParameterValues['Convert-ShouldHaveCount:Pester6'] = $true
            }
        }

        AfterAll {
            InModuleScope -ScriptBlock {
                $PSDefaultParameterValues.Remove('Convert-ShouldHaveCount:Pester6')
            }
        }

        Context 'When the tests are affirming' {
            It 'Should convert `Should -HaveCount 3` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAst = {
                        Should -HaveCount 3
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldHaveCount -CommandAst $mockCommandAst

                    $result | Should-BeString -CaseSensitive 'Should-BeCollection -Count 3'
                }
            }

            It 'Should convert `Should -ActualValue $true -HaveCount 5` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAst = {
                        Should -ActualValue $true -HaveCount 5
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldHaveCount -CommandAst $mockCommandAst

                    $result | Should-BeString -CaseSensitive 'Should-BeCollection -Actual $true -Count 5'
                }
            }

            It 'Should convert `Should -HaveCount 5 -ActualValue $true` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAst = {
                        Should -HaveCount 5 -ActualValue $true
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldHaveCount -CommandAst $mockCommandAst

                    $result | Should-BeString -CaseSensitive 'Should-BeCollection -Actual $true -Count 5'
                }
            }

            It 'Should convert `Should -HaveCount 5 -Because ''reason''` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAst = {
                        Should -HaveCount 5 -Because 'reason'
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldHaveCount -CommandAst $mockCommandAst

                    $result | Should-BeString -CaseSensitive 'Should-BeCollection -Because ''reason'' -Count 5'
                }
            }
        }

        Context 'When the tests are negated' {
            It 'Should leave negated tests unchanged' {
                InModuleScope -ScriptBlock {
                    $mockCommandAst = {
                        Should -HaveCount 3 -Not
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldHaveCount -CommandAst $mockCommandAst

                    # Negated tests are not supported, so the command remains unchanged.
                    $result | Should-BeString -CaseSensitive $mockCommandAst.Extent.Text
                }
            }
        }

        Context 'When tests should always use named parameters' {
            It 'Should convert with named parameters for `Should -HaveCount 3 -ActualValue $true` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAst = {
                        Should -HaveCount 3 -ActualValue $true
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldHaveCount -CommandAst $mockCommandAst -UseNamedParameters

                    $result | Should-BeString -CaseSensitive 'Should-BeCollection -Actual $true -Count 3'
                }
            }
        }

        Context 'When tests should always use positional parameters' {
            It 'Should convert with positional parameters for `Should -HaveCount 3 -ActualValue $true` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAst = {
                        Should -HaveCount 3 -ActualValue $true
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldHaveCount -CommandAst $mockCommandAst -UsePositionalParameters

                    $result | Should-BeString -CaseSensitive 'Should-BeCollection $true -Count 3'
                }
            }
        }
    }
}
