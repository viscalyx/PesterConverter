Describe 'Should -BeLessOrEqual' {
    Context 'When the tests are affirming' {
        It 'Should convert `Should -BeLessOrEqual 2` correctly' {
            1 | Should -BeLessOrEqual 2
        }

        It 'Should convert `Should -BeLessOrEqual $numericValue` correctly' {
            $numericValue = 2

            1 | Should -BeLessOrEqual $numericValue
        }

        It 'Should convert `Should -ActualValue 2 -BeLessOrEqual 2` correctly' {
            Should -ActualValue 2 -BeLessOrEqual 2
        }

        It 'Should convert `Should -BeLessOrEqual 2 -ActualValue 2` correctly' {
            Should -BeLessOrEqual 2 -ActualValue 2
        }

        It 'Should convert `Should -ActualValue 2 -BeLessOrEqual -ExpectedValue 2` correctly' {
            Should -ActualValue 2 -BeLessOrEqual -ExpectedValue 2
        }

        It 'Should convert `Should -BeLessOrEqual -ActualValue 2 -ExpectedValue 2` correctly' {
            Should -BeLessOrEqual -ActualValue 2 -ExpectedValue 2
        }

        It 'Should convert `Should -BeLessOrEqual -ExpectedValue 2 -ActualValue 2` correctly' {
            Should -BeLessOrEqual -ExpectedValue 2 -ActualValue 2
        }

        It 'Should convert `Should -ExpectedValue 2 -BeLessOrEqual -ActualValue 2` correctly' {
            Should -ExpectedValue 2 -BeLessOrEqual -ActualValue 2
        }

        It 'Should convert `Should -ExpectedValue 2 -ActualValue 2 -BeLessOrEqual` correctly' {
            Should -ExpectedValue 2 -ActualValue 2 -BeLessOrEqual
        }

        It 'Should convert `Should -Not:$false -BeLessOrEqual 2` correctly' {
            2 | Should -Not:$false -BeLessOrEqual 2
        }

        It 'Should convert `Should -BeLessOrEqual (Get-Something)` correctly' {
            function Get-Something
            {
                return 2
            }

            2 | Should -BeLessOrEqual (Get-Something)
        }

        It 'Should convert `Should -BeLessOrEqual 2 -Because ''mock should test correct value'' 2` correctly' {
            Should -BeLessOrEqual 2 -Because 'mock should test correct value' 2
        }

        It 'Should convert `Should -BeLessOrEqual 2 ''mock should test correct value'' 1` correctly' {
            Should -BeLessOrEqual 2 'mock should test correct value' 1
        }

        <#
            This was not supported in Pester 5.6.1. There it gave the error message:

            RuntimeException: Legacy Should syntax (without dashes) is not supported in Pester 5.Please refer to migration guide at: https://pester.dev/docs/migrations/v3-to-v4
            ParameterBindingException: Cannot retrieve the dynamic parameters for the cmdlet. Legacy Should syntax (without dashes) is not supported in Pester 5. Please refer to migration guide at: https://pester.dev/docs/migrations/v3-to-v4
        #>
        # It 'Should convert `Should 2 ''mock should test correct value'' 1 -BeLessOrEqual` correctly' {
        #     Should 2 'mock should test correct value' 1 -BeLessOrEqual
        # }
    }

    Context 'When the tests are negated' {
        It 'Should convert `Should -Not -BeLessOrEqual 2` correctly' {
            3 | Should -Not -BeLessOrEqual 2
        }

        It 'Should convert `Should -BeLessOrEqual 2 -Not` correctly' {
            3 | Should -BeLessOrEqual 2 -Not
        }

        It 'Should convert `Should -Not -BeLessOrEqual $anyValue` correctly' {
            $anyValue = 2

            3 | Should -Not -BeLessOrEqual $anyValue
        }

        It 'Should convert `Should -BeLessOrEqual $anyValue -Not` correctly' {
            $anyValue = 2

            3 | Should -BeLessOrEqual $anyValue -Not
        }

        It 'Should convert `Should -Not:$true -BeLessOrEqual 2` correctly' {
            3 | Should -Not:$true -BeLessOrEqual 2
        }

        It 'Should convert `Should -Not -ActualValue 3 -BeLessOrEqual 2` correctly' {
            Should -Not -ActualValue 3 -BeLessOrEqual 2
        }

        It 'Should convert `Should -ActualValue 3 -Not -BeLessOrEqual 2` correctly' {
            Should -ActualValue 3 -Not -BeLessOrEqual 2
        }

        It 'Should convert `Should -ActualValue 3 -BeLessOrEqual 2 -Not` correctly' {
            Should -ActualValue 3 -BeLessOrEqual 2 -Not
        }

        It 'Should convert `Should -BeLessOrEqual 2 -ActualValue 3 -Not` correctly' {
            Should -BeLessOrEqual 2 -ActualValue 3 -Not
        }

        It 'Should convert `Should -BeLessOrEqual 2 -Not -ActualValue 3` correctly' {
            Should -BeLessOrEqual 2 -Not -ActualValue 3
        }

        It 'Should convert `Should -Not -BeLessOrEqual 2 -ActualValue 3` correctly' {
            Should -Not -BeLessOrEqual 2 -ActualValue 3
        }

        It 'Should convert `Should -ActualValue 3 -BeLessOrEqual -Not -ExpectedValue 2` correctly' {
            Should -ActualValue 3 -BeLessOrEqual -Not -ExpectedValue 2
        }

        It 'Should convert `Should -ActualValue 3 -Not -BeLessOrEqual -ExpectedValue 2` correctly' {
            Should -ActualValue 3 -Not -BeLessOrEqual -ExpectedValue 2
        }

        It 'Should convert `Should -ActualValue 3 -BeLessOrEqual -ExpectedValue 2 -Not` correctly' {
            Should -ActualValue 3 -BeLessOrEqual -ExpectedValue 2 -Not
        }
    }

    Context 'When alias operator name is used' {
        It 'Should convert `Should -LE 2 -ActualValue 1` correctly' {
            Should -LE 2 -ActualValue 1
        }
    }
}
