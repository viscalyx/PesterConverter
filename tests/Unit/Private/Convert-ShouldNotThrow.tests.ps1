[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
param ()

BeforeAll {
    $script:dscModuleName = 'PesterConverter'

    Import-Module -Name $script:dscModuleName

    $PSDefaultParameterValues['InModuleScope:ModuleName'] = $script:dscModuleName
    $PSDefaultParameterValues['Mock:ModuleName'] = $script:dscModuleName
    $PSDefaultParameterValues['Should-Invoke:ModuleName'] = $script:dscModuleName
    $PSDefaultParameterValues['Should-NotInvoke:ModuleName'] = $script:dscModuleName
}

AfterAll {
    $PSDefaultParameterValues.Remove('InModuleScope:ModuleName')
    $PSDefaultParameterValues.Remove('Mock:ModuleName')
    $PSDefaultParameterValues.Remove('Should-Invoke:ModuleName')
    $PSDefaultParameterValues.Remove('Should-NotInvoke:ModuleName')

    # Unload the module being tested so that it doesn't impact any other tests.
    Get-Module -Name $script:dscModuleName -All | Remove-Module -Force
}

Describe 'Convert-ShouldNotThrow' {
    Context 'When converting Pester 5 syntax to Pester 6 syntax' {
        BeforeAll {
            InModuleScope -ScriptBlock {
                $PSDefaultParameterValues['Convert-ShouldNotThrow:Pester6'] = $true
            }
        }

        AfterAll {
            InModuleScope -ScriptBlock {
                $PSDefaultParameterValues.Remove('Convert-ShouldNotThrow:Pester6')
            }
        }

        Context 'When the tests are negated' {
            It 'Should convert `Should -Not -Throw -ExceptionType ([System.Exception]) -ErrorId ''MockErrorId'' -Because ''BecauseString'' -ExceptionMessage ''MockErrorMessage'' -ActualValue { Write-Error -Message ''MockErrorMessage'' -ErrorId ''MockErrorId'' -Category ''InvalidOperation'' -TargetObject ''MockTargetObject'' -ErrorAction ''Stop'' }` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -Not -Throw -Because 'BecauseString' -ExceptionType ([System.Exception]) -ErrorId 'MockErrorId' -ExceptionMessage 'MockErrorMessage' -ActualValue {
                            Write-Error -Message 'MockErrorMessage' -ErrorId 'MockErrorId' -Category 'InvalidOperation' -TargetObject 'MockTargetObject' -ErrorAction 'Stop'
                        }
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldNotThrow -CommandAst $mockCommandAstPester5

                    # This need to have the blank space at the start of second and third row for it to match.
                    $result | Should-BeString -CaseSensitive "`$null = & ({
                            Write-Error -Message 'MockErrorMessage' -ErrorId 'MockErrorId' -Category 'InvalidOperation' -TargetObject 'MockTargetObject' -ErrorAction 'Stop'
                        })"
                }
            }

            It 'Should convert `{ Write-Error -Message ''MockErrorMessage'' -ErrorId ''MockErrorId'' -Category ''InvalidOperation'' -TargetObject ''MockTargetObject'' -ErrorAction ''Stop'' } | Should -Throw -Because ''BecauseString'' -ExceptionType ([System.Exception]) -ErrorId ''MockErrorId'' -ExpectedMessage ''MockErrorMessage''` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        {
                            Write-Error -Message 'MockErrorMessage' -ErrorId 'MockErrorId' -Category 'InvalidOperation' -TargetObject 'MockTargetObject' -ErrorAction 'Stop'
                        } | Should -Not -Throw -Because 'BecauseString' -ExceptionType ([System.Exception]) -ErrorId 'MockErrorId' -ExceptionMessage 'MockErrorMessage'
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldNotThrow -CommandAst $mockCommandAstPester5

                    # This need to have the blank space at the start of second and third row for it to match.
                    $result | Should-BeString -CaseSensitive "`$null = & ({
                            Write-Error -Message 'MockErrorMessage' -ErrorId 'MockErrorId' -Category 'InvalidOperation' -TargetObject 'MockTargetObject' -ErrorAction 'Stop'
                        })"
                }
            }

            It 'Should convert `$scriptBlock | Should -Not -Throw` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        $scriptBlock = { throw 'mock error' }
                        $scriptBlock | Should -Not -Throw
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldNotThrow -CommandAst $mockCommandAstPester5

                    # This need to have the blank space at the start of second and third row for it to match.
                    $result | Should-BeString -CaseSensitive '$null = & ($scriptBlock)'
                }
            }

            It 'Should convert `{ throw ''myMessage'' } | Should -Not -Throw -Because ''BecauseString''` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        { throw 'myMessage' } | Should -Not -Throw -Because 'BecauseString'
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldNotThrow -CommandAst $mockCommandAstPester5

                    # This need to have the blank space at the start of second and third row for it to match.
                    $result | Should-BeString -CaseSensitive '$null = & ({ throw ''myMessage'' })'
                }
            }

            It 'Should convert `{ throw ''myMessage'' } | Should -Not -Throw -Because ''BecauseString'' -ExpectedMessage ''ExpectedString''` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        { throw 'myMessage' } |
                            Should -Not -Throw -Because 'BecauseString' -ExpectedMessage 'ExpectedString'
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldNotThrow -CommandAst $mockCommandAstPester5

                    # This need to have the blank space at the start of second and third row for it to match.
                    $result | Should-BeString -CaseSensitive '$null = & ({ throw ''myMessage'' })'
                }
            }

            It 'Should convert `"throw ''five''" | ForEach-Object { [scriptblock]::Create($_) } | Should -Throw -Not` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        "throw 'five'" |
                            ForEach-Object { [scriptblock]::Create($_) } |
                                Should -Throw -Not
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    $result = Convert-ShouldNotThrow -CommandAst $mockCommandAstPester5

                    # This need to have the blank space at the start of second and third row for it to match.
                    $result | Should-BeString -CaseSensitive '$null = & ("throw ''five''" |
                            ForEach-Object { [scriptblock]::Create($_) })'
                }
            }
        }

        Context 'When the tests are affirming' {
            It 'Should convert `Should -Throw` correctly' {
                InModuleScope -ScriptBlock {
                    $mockCommandAstPester5 = {
                        Should -Throw
                    }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                    { Convert-ShouldNotThrow -CommandAst $mockCommandAstPester5 } | Should-Throw -ExceptionType ([System.Exception]) -ExceptionMessage 'Convert-ShouldNotThrow should not be called without a negation parameter. Call Convert-ShouldThrow instead.'
                }
            }
        }
    }
}
