Describe 'Should -BeGreaterOrEqual' {
    Context 'When the tests are affirming' {
        It 'Should convert `Should -BeGreaterOrEqual 2` correctly' {
            3 | Should -BeGreaterOrEqual 2
        }

        It 'Should convert `Should -BeGreaterOrEqual $numericValue` correctly' {
            $numericValue = 3

            3 | Should -BeGreaterOrEqual $numericValue
        }

        It 'Should convert `Should -ActualValue 2 -BeGreaterOrEqual 2` correctly' {
            Should -ActualValue 2 -BeGreaterOrEqual 2
        }

        It 'Should convert `Should -BeGreaterOrEqual 2 -ActualValue 2` correctly' {
            Should -BeGreaterOrEqual 2 -ActualValue 2
        }

        It 'Should convert `Should -ActualValue 2 -BeGreaterOrEqual -ExpectedValue 2` correctly' {
            Should -ActualValue 2 -BeGreaterOrEqual -ExpectedValue 2
        }

        It 'Should convert `Should -BeGreaterOrEqual -ActualValue 2 -ExpectedValue 2` correctly' {
            Should -BeGreaterOrEqual -ActualValue 2 -ExpectedValue 2
        }

        It 'Should convert `Should -BeGreaterOrEqual -ExpectedValue 2 -ActualValue 2` correctly' {
            Should -BeGreaterOrEqual -ExpectedValue 2 -ActualValue 2
        }

        It 'Should convert `Should -ExpectedValue 2 -BeGreaterOrEqual -ActualValue 2` correctly' {
            Should -ExpectedValue 2 -BeGreaterOrEqual -ActualValue 2
        }

        It 'Should convert `Should -ExpectedValue 2 -ActualValue 2 -BeGreaterOrEqual` correctly' {
            Should -ExpectedValue 2 -ActualValue 2 -BeGreaterOrEqual
        }

        It 'Should convert `Should -Not:$false -BeGreaterOrEqual 2` correctly' {
            3 | Should -Not:$false -BeGreaterOrEqual 2
        }

        It 'Should convert `Should -BeGreaterOrEqual (Get-Something)` correctly' {
            function Get-Something
            {
                return 2
            }

            2 | Should -BeGreaterOrEqual (Get-Something)
        }

        It 'Should convert `Should -BeGreaterOrEqual 2 -Because ''mock should test correct value'' 2` correctly' {
            Should -BeGreaterOrEqual 2 -Because 'mock should test correct value' 2
        }

        It 'Should convert `Should -BeGreaterOrEqual 2 ''mock should test correct value'' 3` correctly' {
            Should -BeGreaterOrEqual 2 'mock should test correct value' 3
        }

        <#
            This was not supported in Pester 5.6.1. There it gave the error message:

            RuntimeException: Legacy Should syntax (without dashes) is not supported in Pester 5.Please refer to migration guide at: https://pester.dev/docs/migrations/v3-to-v4
            ParameterBindingException: Cannot retrieve the dynamic parameters for the cmdlet. Legacy Should syntax (without dashes) is not supported in Pester 5. Please refer to migration guide at: https://pester.dev/docs/migrations/v3-to-v4
        #>
        # It 'Should convert `Should 2 ''mock should test correct value'' 3 -BeGreaterOrEqual` correctly' {
        #     Should 2 'mock should test correct value' 3 -BeGreaterOrEqual
        # }
    }

    Context 'When the tests are negated' {
        It 'Should convert `Should -Not -BeGreaterOrEqual 2` correctly' {
            1 | Should -Not -BeGreaterOrEqual 2
        }

        It 'Should convert `Should -BeGreaterOrEqual 2 -Not` correctly' {
            1 | Should -BeGreaterOrEqual 2 -Not
        }

        It 'Should convert `Should -Not -BeGreaterOrEqual $anyValue` correctly' {
            $anyValue = 2

            1 | Should -Not -BeGreaterOrEqual $anyValue
        }

        It 'Should convert `Should -BeGreaterOrEqual $anyValue -Not` correctly' {
            $anyValue = 2

            1 | Should -BeGreaterOrEqual $anyValue -Not
        }

        It 'Should convert `Should -Not:$true -BeGreaterOrEqual 2` correctly' {
            1 | Should -Not:$true -BeGreaterOrEqual 2
        }

        It 'Should convert `Should -Not -ActualValue 3 -BeGreaterOrEqual 2` correctly' {
            Should -Not -ActualValue 1 -BeGreaterOrEqual 2
        }

        It 'Should convert `Should -ActualValue 3 -Not -BeGreaterOrEqual 2` correctly' {
            Should -ActualValue 1 -Not -BeGreaterOrEqual 2
        }

        It 'Should convert `Should -ActualValue 3 -BeGreaterOrEqual 2 -Not` correctly' {
            Should -ActualValue 1 -BeGreaterOrEqual 2 -Not
        }

        It 'Should convert `Should -BeGreaterOrEqual 2 -ActualValue 3 -Not` correctly' {
            Should -BeGreaterOrEqual 2 -ActualValue 1 -Not
        }

        It 'Should convert `Should -BeGreaterOrEqual 2 -Not -ActualValue 3` correctly' {
            Should -BeGreaterOrEqual 2 -Not -ActualValue 1
        }

        It 'Should convert `Should -Not -BeGreaterOrEqual 2 -ActualValue 3` correctly' {
            Should -Not -BeGreaterOrEqual 2 -ActualValue 1
        }

        It 'Should convert `Should -ActualValue 3 -BeGreaterOrEqual -Not -ExpectedValue 2` correctly' {
            Should -ActualValue 1 -BeGreaterOrEqual -Not -ExpectedValue 2
        }

        It 'Should convert `Should -ActualValue 3 -Not -BeGreaterOrEqual -ExpectedValue 2` correctly' {
            Should -ActualValue 1 -Not -BeGreaterOrEqual -ExpectedValue 2
        }

        It 'Should convert `Should -ActualValue 3 -BeGreaterOrEqual -ExpectedValue 2 -Not` correctly' {
            Should -ActualValue 1 -BeGreaterOrEqual -ExpectedValue 2 -Not
        }
    }

    Context 'When alias operator name is used' {
        It 'Should convert `Should -GE 2 -ActualValue 3` correctly' {
            Should -GE 2 -ActualValue 3
        }
    }

    Context 'When tests should always use named parameters' {
        It 'Should convert `Should -BeGreaterOrEqual 2 -ActualValue 3` correctly' {
            Should -BeGreaterOrEqual 2 -ActualValue 3
        }
    }

    Context 'When tests should always use positional parameters' {
        Context 'When the tests are affirming' {
            It 'Should convert `Should -BeGreaterOrEqual 2 -ActualValue 3` correctly' {
                Should -BeGreaterOrEqual 2 -ActualValue 3
            }

            It 'Should convert `Should -BeGreaterOrEqual 2 -ActualValue 3 -Because "this must return true"` correctly' {
                Should -BeGreaterOrEqual 2 -ActualValue 3 -Because 'this must return true'
            }

            It 'Should convert `Should -BeGreaterOrEqual 2 -Because "this must return true" -ActualValue 3` correctly' {
                Should -BeGreaterOrEqual 2 -Because 'this must return true' -ActualValue 3
            }

            It 'Should convert `Should -Because "this must return true" -ActualValue 3 -BeGreaterOrEqual 2` correctly' {
                Should -Because 'this must return true' -ActualValue 3 -BeGreaterOrEqual 2
            }
        }

        Context 'When the tests are negated' {
            It 'Should convert `Should -BeGreaterOrEqual 2 -ActualValue 3 -Because "this must return true" -Not` correctly' {
                Should -BeGreaterOrEqual 2 -ActualValue 1 -Because 'this must return true' -Not
            }
        }
    }
}
