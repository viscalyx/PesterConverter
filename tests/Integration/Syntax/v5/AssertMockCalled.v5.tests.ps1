Describe 'Convert-AssertMockCalled' {
    Context 'When converting Assert-MockCalled to Should -Invoke' {

        Context 'When the tests are affirming' {
            It 'Should convert `Assert-MockCalled` using default settings correctly' {
                $mockCommandAst = {
                    Assert-MockCalled -CommandName 'TestCommand' -Times 3 -Because 'BecauseString'
                }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                $result = Convert-AssertMockCalled -CommandAst $mockCommandAst

                $result | Should -Be 'Should-Invoke -CommandName ''TestCommand'' -Times 3 -Because ''BecauseString'''
            }

            It 'Should convert `Assert-MockCalled` using named parameters correctly' {
                $mockCommandAst = {
                    Assert-MockCalled -CommandName 'TestCommand' -Times 3 -Because 'BecauseString'
                }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                $result = Convert-AssertMockCalled -CommandAst $mockCommandAst -UseNamedParameters

                $result | Should -Be 'Should-Invoke -CommandName ''TestCommand'' -Times 3 -Because ''BecauseString'''
            }

            It 'Should convert `Assert-MockCalled` using positional parameters correctly' {
                $mockCommandAst = {
                    Assert-MockCalled -CommandName 'TestCommand' -Times 3 -Because 'BecauseString'
                }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                $result = Convert-AssertMockCalled -CommandAst $mockCommandAst -UsePositionalParameters

                $result | Should -Be 'Should-Invoke ''TestCommand'' 3 -Because ''BecauseString'''
            }
        }

        Context 'When additional parameters are provided' {
            It 'Should convert extra parameters using default settings correctly' {
                $mockCommandAst = {
                    Assert-MockCalled -CommandName 'TestCommand' -Times 5 `
                        -ParameterFilter { $_.Name -eq 'test' } `
                        -ModuleName 'TestModule' `
                        -Scope 'Global' `
                        -Exactly `
                        -Because 'ExtraBecause'
                }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                $expected = 'Should-Invoke -CommandName ''TestCommand'' -Times 5 -ParameterFilter { $_.Name -eq ''test'' } -ModuleName ''TestModule'' -Scope ''Global'' -Exactly -Because ''ExtraBecause'''

                $result = Convert-AssertMockCalled -CommandAst $mockCommandAst

                $result | Should -Be $expected
            }

            It 'Should convert extra parameters using positional settings correctly' {
                $mockCommandAst = {
                    Assert-MockCalled -CommandName 'TestCommand' -Times 5 `
                        -ParameterFilter { $_.Name -eq 'test' } `
                        -ModuleName 'TestModule' `
                        -Scope 'Global' `
                        -Exactly `
                        -Because 'ExtraBecause'
                }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                $expected = 'Should-Invoke ''TestCommand'' 5 -ParameterFilter { $_.Name -eq ''test'' } -ModuleName ''TestModule'' -Scope ''Global'' -Exactly -Because ''ExtraBecause'''

                $result = Convert-AssertMockCalled -CommandAst $mockCommandAst -UsePositionalParameters

                $result | Should -Be $expected
            }
        }
    }
}
