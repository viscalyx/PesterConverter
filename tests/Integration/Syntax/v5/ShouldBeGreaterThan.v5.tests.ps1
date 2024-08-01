Describe 'Should -BeGreaterThan' {
    Context 'When the tests are affirming' {
        It 'Should convert `Should -BeGreaterThan 2` correctly' {
            3 | Should -BeGreaterThan 2
        }

        It 'Should convert `Should -BeGreaterThan $numericValue` correctly' {
            $numericValue = 2

            3 | Should -BeGreaterThan $numericValue
        }

        It 'Should convert `Should -ActualValue 3 -BeGreaterThan 2` correctly' {
            Should -ActualValue 3 -BeGreaterThan 2
        }

        It 'Should convert `Should -BeGreaterThan 2 -ActualValue 3` correctly' {
            Should -BeGreaterThan 2 -ActualValue 3
        }

        It 'Should convert `Should -ActualValue 3 -BeGreaterThan -ExpectedValue 2` correctly' {
            Should -ActualValue 3 -BeGreaterThan -ExpectedValue 2
        }

        It 'Should convert `Should -BeGreaterThan -ActualValue 3 -ExpectedValue 2` correctly' {
            Should -BeGreaterThan -ActualValue 3 -ExpectedValue 2
        }

        It 'Should convert `Should -BeGreaterThan -ExpectedValue 2 -ActualValue 3` correctly' {
            Should -BeGreaterThan -ExpectedValue 2 -ActualValue 3
        }

        It 'Should convert `Should -ExpectedValue 2 -BeGreaterThan -ActualValue 3` correctly' {
            Should -ExpectedValue 2 -BeGreaterThan -ActualValue 3
        }

        It 'Should convert `Should -ExpectedValue 2 -ActualValue 3 -BeGreaterThan` correctly' {
            Should -ExpectedValue 2 -ActualValue 3 -BeGreaterThan
        }

        It 'Should convert `Should -Not:$false -BeGreaterThan 2` correctly' {
            3 | Should -Not:$false -BeGreaterThan 2
        }

        It 'Should convert `Should -BeGreaterThan (Get-Something)` correctly' {
            function Get-Something
            {
                return 2
            }

            3 | Should -BeGreaterThan (Get-Something)
        }

        It 'Should convert `Should -BeGreaterThan 2 -Because ''mock should test correct value'' 2` correctly' {
            Should -BeGreaterThan 2 -Because 'mock should test correct value' 3
        }

        It 'Should convert `Should -BeGreaterThan 2 ''mock should test correct value'' 3` correctly' {
            Should -BeGreaterThan 2 'mock should test correct value' 3
        }

        <#
            This was not supported in Pester 5.6.1. There it gave the error message:

            RuntimeException: Legacy Should syntax (without dashes) is not supported in Pester 5.Please refer to migration guide at: https://pester.dev/docs/migrations/v3-to-v4
            ParameterBindingException: Cannot retrieve the dynamic parameters for the cmdlet. Legacy Should syntax (without dashes) is not supported in Pester 5. Please refer to migration guide at: https://pester.dev/docs/migrations/v3-to-v4
        #>
        # It 'Should convert `Should 2 ''mock should test correct value'' 3 -BeGreaterThan` correctly' {
        #     Should 2 'mock should test correct value' 3 -BeGreaterThan
        # }
    }

    Context 'When the tests are negated' {
        It 'Should convert `Should -Not -BeGreaterThan 2` correctly' {
            1 | Should -Not -BeGreaterThan 2
        }

        It 'Should convert `Should -BeGreaterThan 2 -Not` correctly' {
            1 | Should -BeGreaterThan 2 -Not
        }

        It 'Should convert `Should -Not -BeGreaterThan $anyValue` correctly' {
            $anyValue = 2

            1 | Should -Not -BeGreaterThan $anyValue
        }

        It 'Should convert `Should -BeGreaterThan $anyValue -Not` correctly' {
            $anyValue = 2

            1 | Should -BeGreaterThan $anyValue -Not
        }

        It 'Should convert `Should -Not:$true -BeGreaterThan 2` correctly' {
            2 | Should -Not:$true -BeGreaterThan 2
        }

        It 'Should convert `Should -Not -ActualValue 1 -BeGreaterThan 2` correctly' {
            Should -Not -ActualValue 1 -BeGreaterThan 2
        }

        It 'Should convert `Should -ActualValue 1 -Not -BeGreaterThan 2` correctly' {
            Should -ActualValue 1 -Not -BeGreaterThan 2
        }

        It 'Should convert `Should -ActualValue 1 -BeGreaterThan 2 -Not` correctly' {
            Should -ActualValue 1 -BeGreaterThan 2 -Not
        }

        It 'Should convert `Should -BeGreaterThan 2 -ActualValue 1 -Not` correctly' {
            Should -BeGreaterThan 2 -ActualValue 1 -Not
        }

        It 'Should convert `Should -BeGreaterThan 2 -Not -ActualValue 1` correctly' {
            Should -BeGreaterThan 2 -Not -ActualValue 1
        }

        It 'Should convert `Should -Not -BeGreaterThan 2 -ActualValue 1` correctly' {
            Should -Not -BeGreaterThan 2 -ActualValue 1
        }

        It 'Should convert `Should -ActualValue 1 -BeGreaterThan -Not -ExpectedValue 2` correctly' {
            Should -ActualValue 1 -BeGreaterThan -Not -ExpectedValue 2
        }

        It 'Should convert `Should -ActualValue 1 -Not -BeGreaterThan -ExpectedValue 2` correctly' {
            Should -ActualValue 1 -Not -BeGreaterThan -ExpectedValue 2
        }

        It 'Should convert `Should -ActualValue 1 -BeGreaterThan -ExpectedValue 2 -Not` correctly' {
            Should -ActualValue 1 -BeGreaterThan -ExpectedValue 2 -Not
        }
    }

    Context 'When alias operator name is used' {
        It 'Should convert `Should -GT 2 -ActualValue 3` correctly' {
            Should -GT 2 -ActualValue 3
        }
    }
}
