Describe 'Should -BeLessThan' {
    Context 'When the tests are affirming' {
        It 'Should convert `Should -BeLessThan 2` correctly' {
            1 | Should -BeLessThan 2
        }

        It 'Should convert `Should -BeLessThan $numericValue` correctly' {
            $numericValue = 2

            1 | Should -BeLessThan $numericValue
        }

        It 'Should convert `Should -ActualValue 1 -BeLessThan 2` correctly' {
            Should -ActualValue 1 -BeLessThan 2
        }

        It 'Should convert `Should -BeLessThan 2 -ActualValue 1` correctly' {
            Should -BeLessThan 2 -ActualValue 1
        }

        It 'Should convert `Should -ActualValue 1 -BeLessThan -ExpectedValue 2` correctly' {
            Should -ActualValue 1 -BeLessThan -ExpectedValue 2
        }

        It 'Should convert `Should -BeLessThan -ActualValue 1 -ExpectedValue 2` correctly' {
            Should -BeLessThan -ActualValue 1 -ExpectedValue 2
        }

        It 'Should convert `Should -BeLessThan -ExpectedValue 2 -ActualValue 1` correctly' {
            Should -BeLessThan -ExpectedValue 2 -ActualValue 1
        }

        It 'Should convert `Should -ExpectedValue 2 -BeLessThan -ActualValue 1` correctly' {
            Should -ExpectedValue 2 -BeLessThan -ActualValue 1
        }

        It 'Should convert `Should -ExpectedValue 2 -ActualValue 1 -BeLessThan` correctly' {
            Should -ExpectedValue 2 -ActualValue 1 -BeLessThan
        }

        It 'Should convert `Should -Not:$false -BeLessThan 2` correctly' {
            1 | Should -Not:$false -BeLessThan 2
        }

        It 'Should convert `Should -BeLessThan (Get-Something)` correctly' {
            function Get-Something
            {
                return 2
            }

            1 | Should -BeLessThan (Get-Something)
        }

        It 'Should convert `Should -BeLessThan 2 -Because ''mock should test correct value'' 1` correctly' {
            Should -BeLessThan 2 -Because 'mock should test correct value' 1
        }

        It 'Should convert `Should -BeLessThan 2 ''mock should test correct value'' 1` correctly' {
            Should -BeLessThan 2 'mock should test correct value' 1
        }

        <#
            This was not supported in Pester 5.6.1. There it gave the error message:

            RuntimeException: Legacy Should syntax (without dashes) is not supported in Pester 5.Please refer to migration guide at: https://pester.dev/docs/migrations/v3-to-v4
            ParameterBindingException: Cannot retrieve the dynamic parameters for the cmdlet. Legacy Should syntax (without dashes) is not supported in Pester 5. Please refer to migration guide at: https://pester.dev/docs/migrations/v3-to-v4
        #>
        # It 'Should convert `Should 2 ''mock should test correct value'' 1 -BeLessThan` correctly' {
        #     Should 2 'mock should test correct value' 1 -BeLessThan
        # }
    }

    Context 'When the tests are negated' {
        It 'Should convert `Should -Not -BeLessThan 2` correctly' {
            3 | Should -Not -BeLessThan 2
        }

        It 'Should convert `Should -BeLessThan 2 -Not` correctly' {
            3 | Should -BeLessThan 2 -Not
        }

        It 'Should convert `Should -Not -BeLessThan $anyValue` correctly' {
            $anyValue = 2

            3 | Should -Not -BeLessThan $anyValue
        }

        It 'Should convert `Should -BeLessThan $anyValue -Not` correctly' {
            $anyValue = 2

            3 | Should -BeLessThan $anyValue -Not
        }

        It 'Should convert `Should -Not:$true -BeLessThan 2` correctly' {
            2 | Should -Not:$true -BeLessThan 2
        }

        It 'Should convert `Should -Not -ActualValue 3 -BeLessThan 2` correctly' {
            Should -Not -ActualValue 3 -BeLessThan 2
        }

        It 'Should convert `Should -ActualValue 3 -Not -BeLessThan 2` correctly' {
            Should -ActualValue 3 -Not -BeLessThan 2
        }

        It 'Should convert `Should -ActualValue 3 -BeLessThan 2 -Not` correctly' {
            Should -ActualValue 3 -BeLessThan 2 -Not
        }

        It 'Should convert `Should -BeLessThan 2 -ActualValue 3 -Not` correctly' {
            Should -BeLessThan 2 -ActualValue 3 -Not
        }

        It 'Should convert `Should -BeLessThan 2 -Not -ActualValue 3` correctly' {
            Should -BeLessThan 2 -Not -ActualValue 3
        }

        It 'Should convert `Should -Not -BeLessThan 2 -ActualValue 3` correctly' {
            Should -Not -BeLessThan 2 -ActualValue 3
        }

        It 'Should convert `Should -ActualValue 3 -BeLessThan -Not -ExpectedValue 2` correctly' {
            Should -ActualValue 3 -BeLessThan -Not -ExpectedValue 2
        }

        It 'Should convert `Should -ActualValue 3 -Not -BeLessThan -ExpectedValue 2` correctly' {
            Should -ActualValue 3 -Not -BeLessThan -ExpectedValue 2
        }

        It 'Should convert `Should -ActualValue 3 -BeLessThan -ExpectedValue 2 -Not` correctly' {
            Should -ActualValue 3 -BeLessThan -ExpectedValue 2 -Not
        }
    }

    Context 'When alias operator name is used' {
        It 'Should convert `Should -LT 3 -ActualValue 2` correctly' {
            Should -LT 3 -ActualValue 2
        }
    }

    Context 'When tests should always use named parameters' {
        It 'Should convert `Should -BeLessThan 2 -ActualValue 1` correctly' {
            Should -BeLessThan 2 -ActualValue 1
        }
    }

    Context 'When tests should always use positional parameters' {
        Context 'When the tests are affirming' {
            It 'Should convert `Should -BeLessThan 2 -ActualValue 1` correctly' {
                Should -BeLessThan 2 -ActualValue 1
            }

            It 'Should convert `Should -BeLessThan 2 -ActualValue 1 -Because "this must return true"` correctly' {
                Should -BeLessThan 2 -ActualValue 1 -Because 'this must return true'
            }

            It 'Should convert `Should -BeLessThan 2 -Because "this must return true" -ActualValue 1` correctly' {
                Should -BeLessThan 2 -Because 'this must return true' -ActualValue 1
            }

            It 'Should convert `Should -Because "this must return true" -ActualValue 1 -BeLessThan 2` correctly' {
                Should -Because 'this must return true' -ActualValue 1 -BeLessThan 2
            }
        }

        Context 'When the tests are negated' {
            It 'Should convert `Should -BeLessThan 2 -ActualValue 3 -Because "this must return true" -Not` correctly' {
                Should -BeLessThan 2 -ActualValue 3 -Because 'this must return true' -Not
            }
        }
    }
}
