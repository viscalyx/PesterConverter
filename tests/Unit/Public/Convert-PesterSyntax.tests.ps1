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

Describe 'Convert-PesterSyntax' {
    BeforeAll {
        # Save current ProgressPreference and then set it to SilentlyContinue
        $script:originalProgressPreference = $ProgressPreference
        $script:ProgressPreference = 'SilentlyContinue'
    }

    AfterAll {
        # Restore the original ProgressPreference
        $script:ProgressPreference = $script:originalProgressPreference
    }

    Context 'When converting v5 to v6' {
        Context 'When converting Should -Be' {
            BeforeAll {
                $mockAstExtentText = {
                    Describe 'Should -Be' {
                        It 'Should -Be' {
                            $true | Should -Be $true -Because 'BecauseString'
                        }
                    }
                }.Ast.GetScriptBlock().ToString()

                $mockScriptFilePath = Join-Path -Path $TestDrive -ChildPath 'Mock.Tests.ps1'

                Set-Content -Path $mockScriptFilePath -Value $mockAstExtentText -Encoding 'utf8'
            }

            It 'Should return the correct converted script' {
                $mockExpectedConvertedScript = {
                    Describe 'Should -Be' {
                        It 'Should -Be' {
                            $true | Should-Be $true -Because 'BecauseString'
                        }
                    }
                }.Ast.GetScriptBlock().ToString()

                $result = Convert-PesterSyntax -Path $mockScriptFilePath -PassThru

                $result | Should-BeString -CaseSensitive -Expected $mockExpectedConvertedScript -TrimWhitespace
            }

            It 'Should return the correct converted script using named parameters' {
                $mockExpectedConvertedScript = {
                    Describe 'Should -Be' {
                        It 'Should -Be' {
                            $true | Should-Be -Because 'BecauseString' -Expected $true
                        }
                    }
                }.Ast.GetScriptBlock().ToString()

                $result = Convert-PesterSyntax -Path $mockScriptFilePath -UseNamedParameters -PassThru

                $result | Should-BeString -CaseSensitive -Expected $mockExpectedConvertedScript -TrimWhitespace
            }

            It 'Should return the correct converted script using positional parameters' {
                $mockExpectedConvertedScript = {
                    Describe 'Should -Be' {
                        It 'Should -Be' {
                            $true | Should-Be $true -Because 'BecauseString'
                        }
                    }
                }.Ast.GetScriptBlock().ToString()

                $result = Convert-PesterSyntax -Path $mockScriptFilePath -UsePositionalParameters -PassThru

                $result | Should-BeString -CaseSensitive -Expected $mockExpectedConvertedScript -TrimWhitespace
            }
        }

        Context 'When converting Should -BeExactly' {
            BeforeAll {
                $mockAstExtentText = {
                    Describe 'Should -BeExactly' {
                        It 'Should -BeExactly' {
                            $true | Should -BeExactly $true -Because 'BecauseString'
                        }
                    }
                }.Ast.GetScriptBlock().ToString()

                $mockScriptFilePath = Join-Path -Path $TestDrive -ChildPath 'Mock.Tests.ps1'

                Set-Content -Path $mockScriptFilePath -Value $mockAstExtentText -Encoding 'utf8'
            }

            It 'Should return the correct converted script' {
                $mockExpectedConvertedScript = {
                    Describe 'Should -BeExactly' {
                        It 'Should -BeExactly' {
                            $true | Should-BeString -CaseSensitive $true -Because 'BecauseString'
                        }
                    }
                }.Ast.GetScriptBlock().ToString()

                $result = Convert-PesterSyntax -Path $mockScriptFilePath -PassThru

                $result | Should-BeString -CaseSensitive -Expected $mockExpectedConvertedScript -TrimWhitespace
            }

            It 'Should return the correct converted script using named parameters' {
                $mockExpectedConvertedScript = {
                    Describe 'Should -BeExactly' {
                        It 'Should -BeExactly' {
                            $true | Should-BeString -CaseSensitive -Because 'BecauseString' -Expected $true
                        }
                    }
                }.Ast.GetScriptBlock().ToString()

                $result = Convert-PesterSyntax -Path $mockScriptFilePath -UseNamedParameters -PassThru

                $result | Should-BeString -CaseSensitive -Expected $mockExpectedConvertedScript -TrimWhitespace
            }

            It 'Should return the correct converted script using positional parameters' {
                $mockExpectedConvertedScript = {

                    Describe 'Should -BeExactly' {
                        It 'Should -BeExactly' {
                            $true | Should-BeString -CaseSensitive $true -Because 'BecauseString'
                        }
                    }
                }.Ast.GetScriptBlock().ToString()

                $result = Convert-PesterSyntax -Path $mockScriptFilePath -UsePositionalParameters -PassThru

                $result | Should-BeString -CaseSensitive -Expected $mockExpectedConvertedScript -TrimWhitespace
            }
        }

        Context 'When converting Should -BeFalse' {
            BeforeAll {
                $mockAstExtentText = {
                    Describe 'Should -BeFalse' {
                        It 'Should -BeFalse' {
                            $true | Should -BeFalse -Because 'BecauseString'
                        }
                    }
                }.Ast.GetScriptBlock().ToString()

                $mockScriptFilePath = Join-Path -Path $TestDrive -ChildPath 'Mock.Tests.ps1'

                Set-Content -Path $mockScriptFilePath -Value $mockAstExtentText -Encoding 'utf8'
            }

            It 'Should return the correct converted script' {
                $mockExpectedConvertedScript = {
                    Describe 'Should -BeFalse' {
                        It 'Should -BeFalse' {
                            $true | Should-BeFalse -Because 'BecauseString'
                        }
                    }
                }.Ast.GetScriptBlock().ToString()

                $result = Convert-PesterSyntax -Path $mockScriptFilePath -PassThru

                $result | Should-BeString -CaseSensitive -Expected $mockExpectedConvertedScript -TrimWhitespace
            }

            It 'Should return the correct converted script using named parameters' {
                $mockExpectedConvertedScript = {
                    Describe 'Should -BeFalse' {
                        It 'Should -BeFalse' {
                            $true | Should-BeFalse -Because 'BecauseString'
                        }
                    }
                }.Ast.GetScriptBlock().ToString()

                $result = Convert-PesterSyntax -Path $mockScriptFilePath -UseNamedParameters -PassThru

                $result | Should-BeString -CaseSensitive -Expected $mockExpectedConvertedScript -TrimWhitespace
            }

            It 'Should return the correct converted script using positional parameters' {
                $mockExpectedConvertedScript = {
                    Describe 'Should -BeFalse' {
                        It 'Should -BeFalse' {
                            $true | Should-BeFalse -Because 'BecauseString'
                        }
                    }
                }.Ast.GetScriptBlock().ToString()

                $result = Convert-PesterSyntax -Path $mockScriptFilePath -UsePositionalParameters -PassThru

                $result | Should-BeString -CaseSensitive -Expected $mockExpectedConvertedScript -TrimWhitespace
            }
        }

        Context 'When converting Should -BeTrue' {
            BeforeAll {
                $mockAstExtentText = {
                    Describe 'Should -BeTrue' {
                        It 'Should -BeTrue' {
                            $true | Should -BeTrue -Because 'BecauseString'
                        }
                    }
                }.Ast.GetScriptBlock().ToString()

                $mockScriptFilePath = Join-Path -Path $TestDrive -ChildPath 'Mock.Tests.ps1'

                Set-Content -Path $mockScriptFilePath -Value $mockAstExtentText -Encoding 'utf8'
            }

            It 'Should return the correct converted script' {
                $mockExpectedConvertedScript = {
                    Describe 'Should -BeTrue' {
                        It 'Should -BeTrue' {
                            $true | Should-BeTrue -Because 'BecauseString'
                        }
                    }
                }.Ast.GetScriptBlock().ToString()

                $result = Convert-PesterSyntax -Path $mockScriptFilePath -PassThru

                $result | Should-BeString -CaseSensitive -Expected $mockExpectedConvertedScript -TrimWhitespace
            }

            It 'Should return the correct converted script using named parameters' {
                $mockExpectedConvertedScript = {
                    Describe 'Should -BeTrue' {
                        It 'Should -BeTrue' {
                            $true | Should-BeTrue -Because 'BecauseString'
                        }
                    }
                }.Ast.GetScriptBlock().ToString()

                $result = Convert-PesterSyntax -Path $mockScriptFilePath -UseNamedParameters -PassThru

                $result | Should-BeString -CaseSensitive -Expected $mockExpectedConvertedScript -TrimWhitespace
            }

            It 'Should return the correct converted script using positional parameters' {
                $mockExpectedConvertedScript = {
                    Describe 'Should -BeTrue' {
                        It 'Should -BeTrue' {
                            $true | Should-BeTrue -Because 'BecauseString'
                        }
                    }
                }.Ast.GetScriptBlock().ToString()

                $result = Convert-PesterSyntax -Path $mockScriptFilePath -UsePositionalParameters -PassThru

                $result | Should-BeString -CaseSensitive -Expected $mockExpectedConvertedScript -TrimWhitespace
            }
        }

        Context 'When converting Should -BeNullOrEmpty' {
            BeforeAll {
                $mockAstExtentText = {

                    Describe 'Should -BeNullOrEmpty' {
                        It 'Should -BeNullOrEmpty' {
                            'ActualValue' | Should -BeNullOrEmpty -Because 'BecauseString'
                        }
                    }
                }.Ast.GetScriptBlock().ToString()

                $mockScriptFilePath = Join-Path -Path $TestDrive -ChildPath 'Mock.Tests.ps1'

                Set-Content -Path $mockScriptFilePath -Value $mockAstExtentText -Encoding 'utf8'
            }

            It 'Should return the correct converted script' {
                $mockExpectedConvertedScript = {

                    Describe 'Should -BeNullOrEmpty' {
                        It 'Should -BeNullOrEmpty' {
                            'ActualValue' | Should-BeFalsy -Because 'BecauseString'
                        }
                    }
                }.Ast.GetScriptBlock().ToString()

                $result = Convert-PesterSyntax -Path $mockScriptFilePath -PassThru

                $result | Should-BeString -CaseSensitive -Expected $mockExpectedConvertedScript -TrimWhitespace
            }

            It 'Should return the correct converted script using named parameters' {
                $mockExpectedConvertedScript = {
                    Describe 'Should -BeNullOrEmpty' {
                        It 'Should -BeNullOrEmpty' {
                            'ActualValue' | Should-BeFalsy -Because 'BecauseString'
                        }
                    }
                }.Ast.GetScriptBlock().ToString()

                $result = Convert-PesterSyntax -Path $mockScriptFilePath -UseNamedParameters -PassThru

                $result | Should-BeString -CaseSensitive -Expected $mockExpectedConvertedScript -TrimWhitespace
            }

            It 'Should return the correct converted script using positional parameters' {
                $mockExpectedConvertedScript = {
                    Describe 'Should -BeNullOrEmpty' {
                        It 'Should -BeNullOrEmpty' {
                            'ActualValue' | Should-BeFalsy -Because 'BecauseString'
                        }
                    }
                }.Ast.GetScriptBlock().ToString()

                $result = Convert-PesterSyntax -Path $mockScriptFilePath -UsePositionalParameters -PassThru

                $result | Should-BeString -CaseSensitive -Expected $mockExpectedConvertedScript -TrimWhitespace
            }
        }

        Context 'When converting Should -BeOfType' {
            BeforeAll {
                $mockAstExtentText = {
                    Describe 'Should -BeOfType' {
                        It 'Should -BeOfType' {
                            'ActualValue' | Should -BeOfType [System.String] -Because 'BecauseString'
                        }
                    }
                }.Ast.GetScriptBlock().ToString()

                $mockScriptFilePath = Join-Path -Path $TestDrive -ChildPath 'Mock.Tests.ps1'

                Set-Content -Path $mockScriptFilePath -Value $mockAstExtentText -Encoding 'utf8'
            }

            It 'Should return the correct converted script' {
                $mockExpectedConvertedScript = {

                    Describe 'Should -BeOfType' {
                        It 'Should -BeOfType' {
                            'ActualValue' | Should-HaveType ([System.String]) -Because 'BecauseString'
                        }
                    }
                }.Ast.GetScriptBlock().ToString()

                $result = Convert-PesterSyntax -Path $mockScriptFilePath -PassThru

                $result | Should-BeString -CaseSensitive -Expected $mockExpectedConvertedScript -TrimWhitespace
            }

            It 'Should return the correct converted script using named parameters' {
                $mockExpectedConvertedScript = {
                    Describe 'Should -BeOfType' {
                        It 'Should -BeOfType' {
                            'ActualValue' | Should-HaveType -Because 'BecauseString' -Expected ([System.String])
                        }
                    }
                }.Ast.GetScriptBlock().ToString()

                $result = Convert-PesterSyntax -Path $mockScriptFilePath -UseNamedParameters -PassThru

                $result | Should-BeString -CaseSensitive -Expected $mockExpectedConvertedScript -TrimWhitespace
            }

            It 'Should return the correct converted script using positional parameters' {
                $mockExpectedConvertedScript = {
                    Describe 'Should -BeOfType' {
                        It 'Should -BeOfType' {
                            'ActualValue' | Should-HaveType ([System.String]) -Because 'BecauseString'
                        }
                    }
                }.Ast.GetScriptBlock().ToString()

                $result = Convert-PesterSyntax -Path $mockScriptFilePath -UsePositionalParameters -PassThru

                $result | Should-BeString -CaseSensitive -Expected $mockExpectedConvertedScript -TrimWhitespace
            }
        }

        Context 'When converting Should -Contain' {
            BeforeAll {
                $mockAstExtentText = {
                    Describe 'Should -Contain' {
                        It 'Should -Contain' {
                            @('a','b') | Should -Contain 'a' -Because 'BecauseString'
                        }
                    }
                }.Ast.GetScriptBlock().ToString()

                $mockScriptFilePath = Join-Path -Path $TestDrive -ChildPath 'Mock.Tests.ps1'

                Set-Content -Path $mockScriptFilePath -Value $mockAstExtentText -Encoding 'utf8'
            }

            It 'Should return the correct converted script' {
                $mockExpectedConvertedScript = {

                    Describe 'Should -Contain' {
                        It 'Should -Contain' {
                            @('a','b') | Should-ContainCollection 'a' -Because 'BecauseString'
                        }
                    }
                }.Ast.GetScriptBlock().ToString()

                $result = Convert-PesterSyntax -Path $mockScriptFilePath -PassThru

                $result | Should-BeString -CaseSensitive -Expected $mockExpectedConvertedScript -TrimWhitespace
            }

            It 'Should return the correct converted script using named parameters' {
                $mockExpectedConvertedScript = {
                    Describe 'Should -Contain' {
                        It 'Should -Contain' {
                            @('a','b') | Should-ContainCollection -Because 'BecauseString' -Expected 'a'
                        }
                    }
                }.Ast.GetScriptBlock().ToString()

                $result = Convert-PesterSyntax -Path $mockScriptFilePath -UseNamedParameters -PassThru

                $result | Should-BeString -CaseSensitive -Expected $mockExpectedConvertedScript -TrimWhitespace
            }

            It 'Should return the correct converted script using positional parameters' {
                $mockExpectedConvertedScript = {
                    Describe 'Should -Contain' {
                        It 'Should -Contain' {
                            @('a','b') | Should-ContainCollection 'a' -Because 'BecauseString'
                        }
                    }
                }.Ast.GetScriptBlock().ToString()

                $result = Convert-PesterSyntax -Path $mockScriptFilePath -UsePositionalParameters -PassThru

                $result | Should-BeString -CaseSensitive -Expected $mockExpectedConvertedScript -TrimWhitespace
            }
        }

        Context 'When converting Should -Match' {
            BeforeAll {
                $mockAstExtentText = {
                    Describe 'Should -Match' {
                        It 'Should -Match' {
                            '[Value]' | Should -Match '^\[.+\]$' -Because 'BecauseString'
                        }
                    }
                }.Ast.GetScriptBlock().ToString()

                $mockScriptFilePath = Join-Path -Path $TestDrive -ChildPath 'Mock.Tests.ps1'

                Set-Content -Path $mockScriptFilePath -Value $mockAstExtentText -Encoding 'utf8'
            }

            It 'Should return the correct converted script' {
                $mockExpectedConvertedScript = {

                    Describe 'Should -Match' {
                        It 'Should -Match' {
                            '[Value]' | Should-MatchString '^\[.+\]$' -Because 'BecauseString'
                        }
                    }
                }.Ast.GetScriptBlock().ToString()

                $result = Convert-PesterSyntax -Path $mockScriptFilePath -PassThru

                $result | Should-BeString -CaseSensitive -Expected $mockExpectedConvertedScript -TrimWhitespace
            }

            It 'Should return the correct converted script using named parameters' {
                $mockExpectedConvertedScript = {
                    Describe 'Should -Match' {
                        It 'Should -Match' {
                            '[Value]' | Should-MatchString -Because 'BecauseString' -Expected '^\[.+\]$'
                        }
                    }
                }.Ast.GetScriptBlock().ToString()

                $result = Convert-PesterSyntax -Path $mockScriptFilePath -UseNamedParameters -PassThru

                $result | Should-BeString -CaseSensitive -Expected $mockExpectedConvertedScript -TrimWhitespace
            }

            It 'Should return the correct converted script using positional parameters' {
                $mockExpectedConvertedScript = {
                    Describe 'Should -Match' {
                        It 'Should -Match' {
                            '[Value]' | Should-MatchString '^\[.+\]$' -Because 'BecauseString'
                        }
                    }
                }.Ast.GetScriptBlock().ToString()

                $result = Convert-PesterSyntax -Path $mockScriptFilePath -UsePositionalParameters -PassThru

                $result | Should-BeString -CaseSensitive -Expected $mockExpectedConvertedScript -TrimWhitespace
            }
        }

        Context 'When converting Should -MatchExactly' {
            BeforeAll {
                $mockAstExtentText = {
                    Describe 'Should -MatchExactly' {
                        It 'Should -MatchExactly' {
                            '[Value]' | Should -MatchExactly '^\[.+\]$' -Because 'BecauseString'
                        }
                    }
                }.Ast.GetScriptBlock().ToString()

                $mockScriptFilePath = Join-Path -Path $TestDrive -ChildPath 'Mock.Tests.ps1'

                Set-Content -Path $mockScriptFilePath -Value $mockAstExtentText -Encoding 'utf8'
            }

            It 'Should return the correct converted script' {
                $mockExpectedConvertedScript = {

                    Describe 'Should -MatchExactly' {
                        It 'Should -MatchExactly' {
                            '[Value]' | Should-MatchString -CaseSensitive '^\[.+\]$' -Because 'BecauseString'
                        }
                    }
                }.Ast.GetScriptBlock().ToString()

                $result = Convert-PesterSyntax -Path $mockScriptFilePath -PassThru

                $result | Should-BeString -CaseSensitive -Expected $mockExpectedConvertedScript -TrimWhitespace
            }

            It 'Should return the correct converted script using named parameters' {
                $mockExpectedConvertedScript = {
                    Describe 'Should -MatchExactly' {
                        It 'Should -MatchExactly' {
                            '[Value]' | Should-MatchString -CaseSensitive -Because 'BecauseString' -Expected '^\[.+\]$'
                        }
                    }
                }.Ast.GetScriptBlock().ToString()

                $result = Convert-PesterSyntax -Path $mockScriptFilePath -UseNamedParameters -PassThru

                $result | Should-BeString -CaseSensitive -Expected $mockExpectedConvertedScript -TrimWhitespace
            }

            It 'Should return the correct converted script using positional parameters' {
                $mockExpectedConvertedScript = {
                    Describe 'Should -MatchExactly' {
                        It 'Should -MatchExactly' {
                            '[Value]' | Should-MatchString -CaseSensitive '^\[.+\]$' -Because 'BecauseString'
                        }
                    }
                }.Ast.GetScriptBlock().ToString()

                $result = Convert-PesterSyntax -Path $mockScriptFilePath -UsePositionalParameters -PassThru

                $result | Should-BeString -CaseSensitive -Expected $mockExpectedConvertedScript -TrimWhitespace
            }
        }

        Context 'When converting Should -Not -Throw' {
            BeforeAll {
                $mockAstExtentText = {
                    Describe 'Should -Not -Throw' {
                        It 'Should -Not -Throw' {
                            {
                                throw
                            } | Should -Not -Throw -Because 'BecauseString'
                        }
                    }
                }.Ast.GetScriptBlock().ToString()

                $mockScriptFilePath = Join-Path -Path $TestDrive -ChildPath 'Mock.Tests.ps1'

                Set-Content -Path $mockScriptFilePath -Value $mockAstExtentText -Encoding 'utf8'
            }

            It 'Should return the correct converted script' {
                $mockExpectedConvertedScript = {
                    Describe 'Should -Not -Throw' {
                        It 'Should -Not -Throw' {
                            $null = & ({
                                throw
                            })
                        }
                    }
                }.Ast.GetScriptBlock().ToString()

                $result = Convert-PesterSyntax -Path $mockScriptFilePath -PassThru

                $result | Should-BeString -CaseSensitive -Expected $mockExpectedConvertedScript -TrimWhitespace
            }

            It 'Should return the correct converted script using named parameters' {
                $mockExpectedConvertedScript = {
                    Describe 'Should -Not -Throw' {
                        It 'Should -Not -Throw' {
                            $null = & ({
                                throw
                            })
                        }
                    }
                }.Ast.GetScriptBlock().ToString()

                $result = Convert-PesterSyntax -Path $mockScriptFilePath -UseNamedParameters -PassThru

                $result | Should-BeString -CaseSensitive -Expected $mockExpectedConvertedScript -TrimWhitespace
            }

            It 'Should return the correct converted script using positional parameters' {
                $mockExpectedConvertedScript = {
                    Describe 'Should -Not -Throw' {
                        It 'Should -Not -Throw' {
                            $null = & ({
                                throw
                            })
                        }
                    }
                }.Ast.GetScriptBlock().ToString()

                $result = Convert-PesterSyntax -Path $mockScriptFilePath -UsePositionalParameters -PassThru

                $result | Should-BeString -CaseSensitive -Expected $mockExpectedConvertedScript -TrimWhitespace
            }
        }

        Context 'When converting Should -Throw' {
            BeforeAll {
                $mockAstExtentText = {
                    Describe 'Should -Throw' {
                        It 'Should -Throw' {
                            {
                                throw
                            } | Should -Throw 'ExpectedMessage' -Because 'BecauseString'
                        }
                    }
                }.Ast.GetScriptBlock().ToString()

                $mockScriptFilePath = Join-Path -Path $TestDrive -ChildPath 'Mock.Tests.ps1'

                Set-Content -Path $mockScriptFilePath -Value $mockAstExtentText -Encoding 'utf8'
            }

            It 'Should return the correct converted script' {
                $mockExpectedConvertedScript = {
                    Describe 'Should -Throw' {
                        It 'Should -Throw' {
                            {
                                throw
                            } | Should-Throw 'ExpectedMessage' -Because 'BecauseString'
                        }
                    }
                }.Ast.GetScriptBlock().ToString()

                $result = Convert-PesterSyntax -Path $mockScriptFilePath -PassThru

                $result | Should-BeString -CaseSensitive -Expected $mockExpectedConvertedScript -TrimWhitespace
            }

            It 'Should return the correct converted script using named parameters' {
                $mockExpectedConvertedScript = {
                    Describe 'Should -Throw' {
                        It 'Should -Throw' {
                            {
                                throw
                            } | Should-Throw -Because 'BecauseString' -ExceptionMessage 'ExpectedMessage'
                        }
                    }
                }.Ast.GetScriptBlock().ToString()

                $result = Convert-PesterSyntax -Path $mockScriptFilePath -UseNamedParameters -PassThru

                $result | Should-BeString -CaseSensitive -Expected $mockExpectedConvertedScript -TrimWhitespace
            }

            It 'Should return the correct converted script using positional parameters' {
                $mockExpectedConvertedScript = {
                    Describe 'Should -Throw' {
                        It 'Should -Throw' {
                            {
                                throw
                            } | Should-Throw 'ExpectedMessage' -Because 'BecauseString'
                        }
                    }
                }.Ast.GetScriptBlock().ToString()

                $result = Convert-PesterSyntax -Path $mockScriptFilePath -UsePositionalParameters -PassThru

                $result | Should-BeString -CaseSensitive -Expected $mockExpectedConvertedScript -TrimWhitespace
            }
        }

        Context 'When converting Should -BeGreaterThan' {
            BeforeAll {
                $mockAstExtentText = {
                    Describe 'Should -BeGreaterThan' {
                        It 'Should -BeGreaterThan' {
                            3 | Should -BeGreaterThan 2 -Because 'BecauseString'
                        }
                    }
                }.Ast.GetScriptBlock().ToString()

                $mockScriptFilePath = Join-Path -Path $TestDrive -ChildPath 'Mock.Tests.ps1'

                Set-Content -Path $mockScriptFilePath -Value $mockAstExtentText -Encoding 'utf8'
            }

            It 'Should return the correct converted script' {
                $mockExpectedConvertedScript = {

                    Describe 'Should -BeGreaterThan' {
                        It 'Should -BeGreaterThan' {
                            3 | Should-BeGreaterThan 2 -Because 'BecauseString'
                        }
                    }
                }.Ast.GetScriptBlock().ToString()

                $result = Convert-PesterSyntax -Path $mockScriptFilePath -PassThru

                $result | Should-BeString -CaseSensitive -Expected $mockExpectedConvertedScript -TrimWhitespace
            }

            It 'Should return the correct converted script using named parameters' {
                $mockExpectedConvertedScript = {
                    Describe 'Should -BeGreaterThan' {
                        It 'Should -BeGreaterThan' {
                            3 | Should-BeGreaterThan -Because 'BecauseString' -Expected 2
                        }
                    }
                }.Ast.GetScriptBlock().ToString()

                $result = Convert-PesterSyntax -Path $mockScriptFilePath -UseNamedParameters -PassThru

                $result | Should-BeString -CaseSensitive -Expected $mockExpectedConvertedScript -TrimWhitespace
            }

            It 'Should return the correct converted script using positional parameters' {
                $mockExpectedConvertedScript = {
                    Describe 'Should -BeGreaterThan' {
                        It 'Should -BeGreaterThan' {
                            3 | Should-BeGreaterThan 2 -Because 'BecauseString'
                        }
                    }
                }.Ast.GetScriptBlock().ToString()

                $result = Convert-PesterSyntax -Path $mockScriptFilePath -UsePositionalParameters -PassThru

                $result | Should-BeString -CaseSensitive -Expected $mockExpectedConvertedScript -TrimWhitespace
            }
        }

        Context 'When converting Should -BeLessThan' {
            BeforeAll {
                $mockAstExtentText = {
                    Describe 'Should -BeLessThan' {
                        It 'Should -BeLessThan' {
                            3 | Should -BeLessThan 2 -Because 'BecauseString'
                        }
                    }
                }.Ast.GetScriptBlock().ToString()

                $mockScriptFilePath = Join-Path -Path $TestDrive -ChildPath 'Mock.Tests.ps1'

                Set-Content -Path $mockScriptFilePath -Value $mockAstExtentText -Encoding 'utf8'
            }

            It 'Should return the correct converted script' {
                $mockExpectedConvertedScript = {

                    Describe 'Should -BeLessThan' {
                        It 'Should -BeLessThan' {
                            3 | Should-BeLessThan 2 -Because 'BecauseString'
                        }
                    }
                }.Ast.GetScriptBlock().ToString()

                $result = Convert-PesterSyntax -Path $mockScriptFilePath -PassThru

                $result | Should-BeString -CaseSensitive -Expected $mockExpectedConvertedScript -TrimWhitespace
            }

            It 'Should return the correct converted script using named parameters' {
                $mockExpectedConvertedScript = {
                    Describe 'Should -BeLessThan' {
                        It 'Should -BeLessThan' {
                            3 | Should-BeLessThan -Because 'BecauseString' -Expected 2
                        }
                    }
                }.Ast.GetScriptBlock().ToString()

                $result = Convert-PesterSyntax -Path $mockScriptFilePath -UseNamedParameters -PassThru

                $result | Should-BeString -CaseSensitive -Expected $mockExpectedConvertedScript -TrimWhitespace
            }

            It 'Should return the correct converted script using positional parameters' {
                $mockExpectedConvertedScript = {
                    Describe 'Should -BeLessThan' {
                        It 'Should -BeLessThan' {
                            3 | Should-BeLessThan 2 -Because 'BecauseString'
                        }
                    }
                }.Ast.GetScriptBlock().ToString()

                $result = Convert-PesterSyntax -Path $mockScriptFilePath -UsePositionalParameters -PassThru

                $result | Should-BeString -CaseSensitive -Expected $mockExpectedConvertedScript -TrimWhitespace
            }
        }

        Context 'When converting Should -BeGreaterOrEqual' {
            BeforeAll {
                $mockAstExtentText = {
                    Describe 'Should -BeGreaterOrEqual' {
                        It 'Should -BeGreaterOrEqual' {
                            3 | Should -BeGreaterOrEqual 2 -Because 'BecauseString'
                        }
                    }
                }.Ast.GetScriptBlock().ToString()

                $mockScriptFilePath = Join-Path -Path $TestDrive -ChildPath 'Mock.Tests.ps1'

                Set-Content -Path $mockScriptFilePath -Value $mockAstExtentText -Encoding 'utf8'
            }

            It 'Should return the correct converted script' {
                $mockExpectedConvertedScript = {

                    Describe 'Should -BeGreaterOrEqual' {
                        It 'Should -BeGreaterOrEqual' {
                            3 | Should-BeGreaterThanOrEqual 2 -Because 'BecauseString'
                        }
                    }
                }.Ast.GetScriptBlock().ToString()

                $result = Convert-PesterSyntax -Path $mockScriptFilePath -PassThru

                $result | Should-BeString -CaseSensitive -Expected $mockExpectedConvertedScript -TrimWhitespace
            }

            It 'Should return the correct converted script using named parameters' {
                $mockExpectedConvertedScript = {
                    Describe 'Should -BeGreaterOrEqual' {
                        It 'Should -BeGreaterOrEqual' {
                            3 | Should-BeGreaterThanOrEqual -Because 'BecauseString' -Expected 2
                        }
                    }
                }.Ast.GetScriptBlock().ToString()

                $result = Convert-PesterSyntax -Path $mockScriptFilePath -UseNamedParameters -PassThru

                $result | Should-BeString -CaseSensitive -Expected $mockExpectedConvertedScript -TrimWhitespace
            }

            It 'Should return the correct converted script using positional parameters' {
                $mockExpectedConvertedScript = {
                    Describe 'Should -BeGreaterOrEqual' {
                        It 'Should -BeGreaterOrEqual' {
                            3 | Should-BeGreaterThanOrEqual 2 -Because 'BecauseString'
                        }
                    }
                }.Ast.GetScriptBlock().ToString()

                $result = Convert-PesterSyntax -Path $mockScriptFilePath -UsePositionalParameters -PassThru

                $result | Should-BeString -CaseSensitive -Expected $mockExpectedConvertedScript -TrimWhitespace
            }
        }

        Context 'When converting Should -BeLessOrEqual' {
            BeforeAll {
                $mockAstExtentText = {
                    Describe 'Should -BeLessOrEqual' {
                        It 'Should -BeLessOrEqual' {
                            3 | Should -BeLessOrEqual 2 -Because 'BecauseString'
                        }
                    }
                }.Ast.GetScriptBlock().ToString()

                $mockScriptFilePath = Join-Path -Path $TestDrive -ChildPath 'Mock.Tests.ps1'

                Set-Content -Path $mockScriptFilePath -Value $mockAstExtentText -Encoding 'utf8'
            }

            It 'Should return the correct converted script' {
                $mockExpectedConvertedScript = {

                    Describe 'Should -BeLessOrEqual' {
                        It 'Should -BeLessOrEqual' {
                            3 | Should-BeLessThanOrEqual 2 -Because 'BecauseString'
                        }
                    }
                }.Ast.GetScriptBlock().ToString()

                $result = Convert-PesterSyntax -Path $mockScriptFilePath -PassThru

                $result | Should-BeString -CaseSensitive -Expected $mockExpectedConvertedScript -TrimWhitespace
            }

            It 'Should return the correct converted script using named parameters' {
                $mockExpectedConvertedScript = {
                    Describe 'Should -BeLessOrEqual' {
                        It 'Should -BeLessOrEqual' {
                            3 | Should-BeLessThanOrEqual -Because 'BecauseString' -Expected 2
                        }
                    }
                }.Ast.GetScriptBlock().ToString()

                $result = Convert-PesterSyntax -Path $mockScriptFilePath -UseNamedParameters -PassThru

                $result | Should-BeString -CaseSensitive -Expected $mockExpectedConvertedScript -TrimWhitespace
            }

            It 'Should return the correct converted script using positional parameters' {
                $mockExpectedConvertedScript = {
                    Describe 'Should -BeLessOrEqual' {
                        It 'Should -BeLessOrEqual' {
                            3 | Should-BeLessThanOrEqual 2 -Because 'BecauseString'
                        }
                    }
                }.Ast.GetScriptBlock().ToString()

                $result = Convert-PesterSyntax -Path $mockScriptFilePath -UsePositionalParameters -PassThru

                $result | Should-BeString -CaseSensitive -Expected $mockExpectedConvertedScript -TrimWhitespace
            }
        }

        Context 'When converting Should -BeLike' {
            BeforeAll {
                $mockAstExtentText = {
                    Describe 'Should -BeLike' {
                        It 'Should -BeLike' {
                            'ExpectedString' | Should -BeLike 'Expected*' -Because 'BecauseString'
                        }
                    }
                }.Ast.GetScriptBlock().ToString()

                $mockScriptFilePath = Join-Path -Path $TestDrive -ChildPath 'Mock.Tests.ps1'

                Set-Content -Path $mockScriptFilePath -Value $mockAstExtentText -Encoding 'utf8'
            }

            It 'Should return the correct converted script' {
                $mockExpectedConvertedScript = {

                    Describe 'Should -BeLike' {
                        It 'Should -BeLike' {
                            'ExpectedString' | Should-BeLikeString 'Expected*' -Because 'BecauseString'
                        }
                    }
                }.Ast.GetScriptBlock().ToString()

                $result = Convert-PesterSyntax -Path $mockScriptFilePath -PassThru

                $result | Should-BeString -CaseSensitive -Expected $mockExpectedConvertedScript -TrimWhitespace
            }

            It 'Should return the correct converted script using named parameters' {
                $mockExpectedConvertedScript = {
                    Describe 'Should -BeLike' {
                        It 'Should -BeLike' {
                            'ExpectedString' | Should-BeLikeString -Because 'BecauseString' -Expected 'Expected*'
                        }
                    }
                }.Ast.GetScriptBlock().ToString()

                $result = Convert-PesterSyntax -Path $mockScriptFilePath -UseNamedParameters -PassThru

                $result | Should-BeString -CaseSensitive -Expected $mockExpectedConvertedScript -TrimWhitespace
            }

            It 'Should return the correct converted script using positional parameters' {
                $mockExpectedConvertedScript = {
                    Describe 'Should -BeLike' {
                        It 'Should -BeLike' {
                            'ExpectedString' | Should-BeLikeString 'Expected*' -Because 'BecauseString'
                        }
                    }
                }.Ast.GetScriptBlock().ToString()

                $result = Convert-PesterSyntax -Path $mockScriptFilePath -UsePositionalParameters -PassThru

                $result | Should-BeString -CaseSensitive -Expected $mockExpectedConvertedScript -TrimWhitespace
            }
        }

        Context 'When converting Should -BeLikeExactly' {
            BeforeAll {
                $mockAstExtentText = {
                    Describe 'Should -BeLikeExactly' {
                        It 'Should -BeLikeExactly' {
                            'ExpectedString' | Should -BeLikeExactly 'Expected*' -Because 'BecauseString'
                        }
                    }
                }.Ast.GetScriptBlock().ToString()

                $mockScriptFilePath = Join-Path -Path $TestDrive -ChildPath 'Mock.Tests.ps1'

                Set-Content -Path $mockScriptFilePath -Value $mockAstExtentText -Encoding 'utf8'
            }

            It 'Should return the correct converted script' {
                $mockExpectedConvertedScript = {

                    Describe 'Should -BeLikeExactly' {
                        It 'Should -BeLikeExactly' {
                            'ExpectedString' | Should-BeLikeString -CaseSensitive 'Expected*' -Because 'BecauseString'
                        }
                    }
                }.Ast.GetScriptBlock().ToString()

                $result = Convert-PesterSyntax -Path $mockScriptFilePath -PassThru

                $result | Should-BeString -CaseSensitive -Expected $mockExpectedConvertedScript -TrimWhitespace
            }

            It 'Should return the correct converted script using named parameters' {
                $mockExpectedConvertedScript = {
                    Describe 'Should -BeLikeExactly' {
                        It 'Should -BeLikeExactly' {
                            'ExpectedString' | Should-BeLikeString -CaseSensitive -Because 'BecauseString' -Expected 'Expected*'
                        }
                    }
                }.Ast.GetScriptBlock().ToString()

                $result = Convert-PesterSyntax -Path $mockScriptFilePath -UseNamedParameters -PassThru

                $result | Should-BeString -CaseSensitive -Expected $mockExpectedConvertedScript -TrimWhitespace
            }

            It 'Should return the correct converted script using positional parameters' {
                $mockExpectedConvertedScript = {
                    Describe 'Should -BeLikeExactly' {
                        It 'Should -BeLikeExactly' {
                            'ExpectedString' | Should-BeLikeString -CaseSensitive 'Expected*' -Because 'BecauseString'
                        }
                    }
                }.Ast.GetScriptBlock().ToString()

                $result = Convert-PesterSyntax -Path $mockScriptFilePath -UsePositionalParameters -PassThru

                $result | Should-BeString -CaseSensitive -Expected $mockExpectedConvertedScript -TrimWhitespace
            }
        }

        Context 'When converting Should -BeIn without a pipeline' {
            BeforeAll {
                $mockAstExtentText = {
                    Describe 'Should -BeIn' {
                        It 'Should -BeIn' {
                            Should -BeIn @('a', 'b') -Because 'BecauseString' -ActualValue $resultValue
                        }
                    }
                }.Ast.GetScriptBlock().ToString()

                $mockScriptFilePath = Join-Path -Path $TestDrive -ChildPath 'Mock.Tests.ps1'

                Set-Content -Path $mockScriptFilePath -Value $mockAstExtentText -Encoding 'utf8'
            }

            It 'Should return the correct converted script' {
                $mockExpectedConvertedScript = {
                    Describe 'Should -BeIn' {
                        It 'Should -BeIn' {
                            Should-ContainCollection @('a', 'b') -Because 'BecauseString' -Expected $resultValue
                        }
                    }
                }.Ast.GetScriptBlock().ToString()

                $result = Convert-PesterSyntax -Path $mockScriptFilePath -PassThru

                $result | Should-BeString -CaseSensitive -Expected $mockExpectedConvertedScript -TrimWhitespace
            }

            It 'Should return the correct converted script using named parameters' {
                $mockExpectedConvertedScript = {
                    Describe 'Should -BeIn' {
                        It 'Should -BeIn' {
                            Should-ContainCollection -Actual @('a', 'b') -Because 'BecauseString' -Expected $resultValue
                        }
                    }
                }.Ast.GetScriptBlock().ToString()

                $result = Convert-PesterSyntax -Path $mockScriptFilePath -UseNamedParameters -PassThru

                $result | Should-BeString -CaseSensitive -Expected $mockExpectedConvertedScript -TrimWhitespace
            }

            It 'Should return the correct converted script using positional parameters' {
                $mockExpectedConvertedScript = {
                    Describe 'Should -BeIn' {
                        It 'Should -BeIn' {
                            Should-ContainCollection $resultValue @('a', 'b') -Because 'BecauseString'
                        }
                    }
                }.Ast.GetScriptBlock().ToString()

                $result = Convert-PesterSyntax -Path $mockScriptFilePath -UsePositionalParameters -PassThru

                $result | Should-BeString -CaseSensitive -Expected $mockExpectedConvertedScript -TrimWhitespace
            }
        }

        Context 'When converting Should -BeIn with a pipeline' {
            BeforeAll {
                $mockAstExtentText = {
                    Describe 'Should -BeIn' {
                        It 'Should -BeIn' {
                            $resultValue | Get-Something | Should -BeIn @('a', 'b') -Because 'BecauseString'
                        }
                    }
                }.Ast.GetScriptBlock().ToString()

                $mockScriptFilePath = Join-Path -Path $TestDrive -ChildPath 'Mock.Tests.ps1'

                Set-Content -Path $mockScriptFilePath -Value $mockAstExtentText -Encoding 'utf8'
            }

            It 'Should return the correct converted script' {
                $mockExpectedConvertedScript = {

                    Describe 'Should -BeIn' {
                        It 'Should -BeIn' {
                            @('a', 'b') | Should-ContainCollection ($resultValue | Get-Something) -Because 'BecauseString'
                        }
                    }
                }.Ast.GetScriptBlock().ToString()

                $result = Convert-PesterSyntax -Path $mockScriptFilePath -PassThru

                $result | Should-BeString -CaseSensitive -Expected $mockExpectedConvertedScript -TrimWhitespace
            }

            It 'Should return the correct converted script using named parameters' {
                $mockExpectedConvertedScript = {
                    Describe 'Should -BeIn' {
                        It 'Should -BeIn' {
                            @('a', 'b') | Should-ContainCollection -Because 'BecauseString' -Expected ($resultValue | Get-Something)
                        }
                    }
                }.Ast.GetScriptBlock().ToString()

                $result = Convert-PesterSyntax -Path $mockScriptFilePath -UseNamedParameters -PassThru

                $result | Should-BeString -CaseSensitive -Expected $mockExpectedConvertedScript -TrimWhitespace
            }

            It 'Should return the correct converted script using positional parameters' {
                $mockExpectedConvertedScript = {
                    Describe 'Should -BeIn' {
                        It 'Should -BeIn' {
                            @('a', 'b') | Should-ContainCollection ($resultValue | Get-Something) -Because 'BecauseString'
                        }
                    }
                }.Ast.GetScriptBlock().ToString()

                $result = Convert-PesterSyntax -Path $mockScriptFilePath -UsePositionalParameters -PassThru

                $result | Should-BeString -CaseSensitive -Expected $mockExpectedConvertedScript -TrimWhitespace
            }
        }

        Context 'When converting Should -Invoke' {
            BeforeAll {
                $mockAstExtentText = {
                    Describe 'Should -Invoke' {
                        It 'Should -Invoke' {
                            'TestCommand' | Should -Invoke 'TestCommand' -Times 3 -Because 'BecauseString'
                        }
                    }
                }.Ast.GetScriptBlock().ToString()

                $mockScriptFilePath = Join-Path -Path $TestDrive -ChildPath 'Mock.Tests.ps1'

                Set-Content -Path $mockScriptFilePath -Value $mockAstExtentText -Encoding 'utf8'
            }

            It 'Should return the correct converted script' {
                $mockExpectedConvertedScript = {
                    Describe 'Should -Invoke' {
                        It 'Should -Invoke' {
                            'TestCommand' | Should-Invoke 'TestCommand' -Because 'BecauseString' -Times 3
                        }
                    }
                }.Ast.GetScriptBlock().ToString()

                $result = Convert-PesterSyntax -Path $mockScriptFilePath -PassThru

                $result | Should-BeString -CaseSensitive -Expected $mockExpectedConvertedScript -TrimWhitespace
            }

            It 'Should return the correct converted script using named parameters' {
                $mockExpectedConvertedScript = {
                    Describe 'Should -Invoke' {
                        It 'Should -Invoke' {
                            'TestCommand' | Should-Invoke -Because 'BecauseString' -CommandName 'TestCommand' -Times 3
                        }
                    }
                }.Ast.GetScriptBlock().ToString()

                $result = Convert-PesterSyntax -Path $mockScriptFilePath -UseNamedParameters -PassThru

                $result | Should-BeString -CaseSensitive -Expected $mockExpectedConvertedScript -TrimWhitespace
            }

            It 'Should return the correct converted script using positional parameters' {
                $mockExpectedConvertedScript = {
                    Describe 'Should -Invoke' {
                        It 'Should -Invoke' {
                            'TestCommand' | Should-Invoke 'TestCommand' 3 -Because 'BecauseString'
                        }
                    }
                }.Ast.GetScriptBlock().ToString()

                $result = Convert-PesterSyntax -Path $mockScriptFilePath -UsePositionalParameters -PassThru

                $result | Should-BeString -CaseSensitive -Expected $mockExpectedConvertedScript -TrimWhitespace
            }
        }

        Context 'When converting Should -HaveCount' {
            BeforeAll {
                $mockAstExtentText = {
                    Describe 'Should -HaveCount' {
                        It 'Should -HaveCount' {
                            $array | Should -HaveCount 3 -Because 'BecauseString'
                        }
                    }
                }.Ast.GetScriptBlock().ToString()

                $mockScriptFilePath = Join-Path -Path $TestDrive -ChildPath 'Mock.Tests.ps1'

                Set-Content -Path $mockScriptFilePath -Value $mockAstExtentText -Encoding 'utf8'
            }

            It 'Should convert the syntax correctly' {
                $mockExpectedConvertedScript = {
                    Describe 'Should -HaveCount' {
                        It 'Should -HaveCount' {
                            $array | Should-BeCollection -Because 'BecauseString' -Count 3
                        }
                    }
                }.Ast.GetScriptBlock().ToString()

                $result = Convert-PesterSyntax -Path $mockScriptFilePath -PassThru

                $result | Should-BeString -CaseSensitive -Expected $mockExpectedConvertedScript -TrimWhitespace
            }

            It 'Should convert using named parameters correctly' {
                $mockExpectedConvertedScript = {
                    Describe 'Should -HaveCount' {
                        It 'Should -HaveCount' {
                            $array | Should-BeCollection -Because 'BecauseString' -Count 3
                        }
                    }
                }.Ast.GetScriptBlock().ToString()

                $result = Convert-PesterSyntax -Path $mockScriptFilePath -UseNamedParameters -PassThru

                $result | Should-BeString -CaseSensitive -Expected $mockExpectedConvertedScript -TrimWhitespace
            }

            It 'Should convert using positional parameters correctly' {
                $mockExpectedConvertedScript = {
                    Describe 'Should -HaveCount' {
                        It 'Should -HaveCount' {
                            $array | Should-BeCollection -Because 'BecauseString' -Count 3
                        }
                    }
                }.Ast.GetScriptBlock().ToString()

                $result = Convert-PesterSyntax -Path $mockScriptFilePath -UsePositionalParameters -PassThru

                $result | Should-BeString -CaseSensitive -Expected $mockExpectedConvertedScript -TrimWhitespace
            }
        }

        Context 'When converting several files' {
            BeforeAll {
                $mockAstExtentText = {
                    Describe 'Should -Be' {
                        It 'Should -Be' {
                            $true | Should -Be $true -Because 'BecauseString'
                        }
                    }
                }.Ast.GetScriptBlock().ToString()

                $mockScriptFilePath1 = Join-Path -Path $TestDrive -ChildPath 'Mock1.Tests.ps1'

                Set-Content -Path $mockScriptFilePath1 -Value $mockAstExtentText -Encoding 'utf8'

                $mockScriptFilePath2 = Join-Path -Path $TestDrive -ChildPath 'Mock2.Tests.ps1'

                Set-Content -Path $mockScriptFilePath2 -Value $mockAstExtentText -Encoding 'utf8'
            }

            Context 'When passing files through parameter' {
                It 'Should not throw an exception' {
                    $null = Convert-PesterSyntax -Path $mockScriptFilePath1, $mockScriptFilePath2 -PassThru
                }
            }

            Context 'When passing files through pipeline' {
                It 'Should not throw an exception' {
                    $null = $mockScriptFilePath1, $mockScriptFilePath2 | Convert-PesterSyntax -PassThru
                }
            }
        }

        Context 'When passing unknown operator for Should command' {
            BeforeAll {
                $mockAstExtentText = {
                    Describe 'Unknown operator' {
                        It 'Should -Unknown' {
                            Should -Unknown
                        }
                    }
                }.Ast.GetScriptBlock().ToString()

                $mockScriptFilePath = Join-Path -Path $TestDrive -ChildPath 'Mock.Tests.ps1'

                Set-Content -Path $mockScriptFilePath -Value $mockAstExtentText -Encoding 'utf8'

                Mock -CommandName Write-Warning
            }

            It 'Should not throw an exception' {
                $null = Convert-PesterSyntax -Path $mockScriptFilePath -PassThru

                Should -Invoke -CommandName Write-Warning -Exactly -Times 1 -Scope It -ParameterFilter { $Message -like '*not found*supported command operators*' }
            }
        }

        Context 'When there are no Pester commands' {
            BeforeAll {
                $mockAstExtentText = {
                    $a = 1 + 1
                }.Ast.GetScriptBlock().ToString()

                $mockScriptFilePath = Join-Path -Path $TestDrive -ChildPath 'Mock.Tests.ps1'

                Set-Content -Path $mockScriptFilePath -Value $mockAstExtentText -Encoding 'utf8'
            }

            It 'Should not throw an exception' {
                $result = Convert-PesterSyntax -Path $mockScriptFilePath -PassThru

                $result | Should-BeString -CaseSensitive -Expected $mockAstExtentText -TrimWhitespace
            }
        }

        Context 'When saving the converted script back to the original file' {
            BeforeAll {
                $mockAstExtentText = {
                    Describe 'Should -Be' {
                        It 'Should -Be' {
                            Should -Be 1
                        }
                    }
                }.Ast.GetScriptBlock().ToString()

                $mockScriptFilePath = Join-Path -Path $TestDrive -ChildPath 'Mock.Tests.ps1'

                Set-Content -Path $mockScriptFilePath -Value $mockAstExtentText -Encoding 'utf8'

                Mock -CommandName Write-Warning
            }

            It 'Should not throw an exception' {
                $mockExpectedConvertedScript = {
                    Describe 'Should -Be' {
                        It 'Should -Be' {
                            Should-Be 1
                        }
                    }
                }.Ast.GetScriptBlock().ToString()

                Convert-PesterSyntax -Path $mockScriptFilePath -Force

                Get-Content -Raw -Path $mockScriptFilePath | Should-BeString -CaseSensitive -Expected $mockExpectedConvertedScript -TrimWhitespace
            }
        }

        Context 'When saving the converted script to a different output path' {
            BeforeAll {
                $mockAstExtentText = {
                    Describe 'Should -Be' {
                        It 'Should -Be' {
                            Should -Be 1
                        }
                    }
                }.Ast.GetScriptBlock().ToString()

                $mockScriptFilePath = Join-Path -Path $TestDrive -ChildPath 'Mock.Tests.ps1'

                Set-Content -Path $mockScriptFilePath -Value $mockAstExtentText -Encoding 'utf8'

                # Mock paths for testing
                $mockNonExistentPath = Join-Path -Path $TestDrive -ChildPath 'NonExistentPath'
                $mockFilePath = Join-Path -Path $TestDrive -ChildPath 'MockFile.txt'
                $mockOutputPath = Join-Path -Path $TestDrive -ChildPath 'MockDirectory'

                # Create a mock file
                New-Item -Path $mockFilePath -ItemType 'File' -Force | Out-Null

                # Create a mock directory
                New-Item -Path $mockOutputPath -ItemType 'Directory' -Force | Out-Null
            }

            It 'Should throw an error when the output path does not exist' {
                {
                    Convert-PesterSyntax -Path $mockScriptFilePath -OutputPath $mockNonExistentPath -Force
                } | Should -Throw -ErrorId 'CPS0002,Convert-PesterSyntax'
            }

            It 'Should throw an error when the output path is not a directory' {
                {
                    Convert-PesterSyntax -Path $mockScriptFilePath -OutputPath $mockFilePath -Force
                } | Should-Throw -FullyQualifiedErrorId 'CPS0003,Convert-PesterSyntax'
            }

            It 'Should work correctly when the output path is a valid directory' {
                $result = Convert-PesterSyntax -Path $mockScriptFilePath -OutputPath $mockOutputPath -Force

                Should-BeNull -Actual $result -Because 'The function should not return anything when saving the converted script to a different output path'
            }
        }
    }
}
