Describe 'Should -BeLikeExactly' {
    Context 'When the tests are affirming' {
        It 'Should convert `Should -BeLikeExactly ''Test*''` correctly' {
           'TestValue' | Should -BeLikeExactly 'Test*'
        }

        It 'Should convert `Should -BeLikeExactly "Test*"` correctly' {
            'TestValue' | Should -BeLikeExactly "Test*"
        }

        It 'Should convert `Should -BeLikeExactly $anyValue` correctly' {
            $anyValue = 'Test*'

            'TestValue' | Should -BeLikeExactly $anyValue
        }

        It 'Should convert `Should -ActualValue ''TestValue'' -BeLikeExactly ''Test*''` correctly' {
            Should -ActualValue 'TestValue' -BeLikeExactly 'Test*'
        }

        It 'Should convert `Should -BeLikeExactly ''Test*'' -ActualValue ''TestValue''` correctly' {
            Should -BeLikeExactly 'Test*' -ActualValue 'TestValue'
        }

        It 'Should convert `Should -ActualValue ''TestValue'' -BeLikeExactly -ExpectedValue ''Test*''` correctly' {
            Should -ActualValue 'TestValue' -BeLikeExactly -ExpectedValue 'Test*'
        }

        It 'Should convert `Should -BeLikeExactly -ActualValue ''TestValue'' -ExpectedValue ''Test*''` correctly' {
            Should -BeLikeExactly -ActualValue 'TestValue' -ExpectedValue 'Test*'
        }

        It 'Should convert `Should -BeLikeExactly -ExpectedValue ''Test*'' -ActualValue ''TestValue''` correctly' {
            Should -BeLikeExactly -ExpectedValue 'Test*' -ActualValue 'TestValue'
        }

        It 'Should convert `Should -ExpectedValue ''Test*'' -BeLikeExactly -ActualValue ''TestValue''` correctly' {
            Should -ExpectedValue 'Test*' -BeLikeExactly -ActualValue 'TestValue'
        }

        It 'Should convert `Should -ExpectedValue ''Test*'' -ActualValue ''TestValue'' -BeLikeExactly` correctly' {
            Should -ExpectedValue 'Test*' -ActualValue 'TestValue' -BeLikeExactly
        }

        It 'Should convert `Should -Not:$false -BeLikeExactly ''Test*''` correctly' {
            'TestValue' | Should -Not:$false -BeLikeExactly 'Test*'
        }

        It 'Should convert `Should -BeLikeExactly (Get-Something)` correctly' {
            function Get-Something
            {
                return 'Test*'
            }

            'TestValue' | Should -BeLikeExactly (Get-Something)
        }

        It 'Should convert `Should -BeLikeExactly ''Test*'' -Because ''mock should test correct value'' ''TestValue''` correctly' {
            Should -BeLikeExactly 'Test*' -Because 'mock should test correct value' 'TestValue*'
        }

        It 'Should convert `Should -BeLikeExactly ''Test*'' ''mock should test correct value'' ''TestValue''` correctly' {
            Should -BeLikeExactly 'Test*' 'mock should test correct value' 'TestValue'
        }

        <#
            This was not supported in Pester 5.6.1. There it gave the error message:

            RuntimeException: Legacy Should syntax (without dashes) is not supported in Pester 5.Please refer to migration guide at: https://pester.dev/docs/migrations/v3-to-v4
            ParameterBindingException: Cannot retrieve the dynamic parameters for the cmdlet. Legacy Should syntax (without dashes) is not supported in Pester 5. Please refer to migration guide at: https://pester.dev/docs/migrations/v3-to-v4
        #>
        # It 'Should convert `Should ''Test*'' ''mock should test correct value'' ''TestValue'' -BeLikeExactly` correctly' {
        #     Should 'Test*' 'mock should test correct value' 'TestValue' -BeLikeExactly
        # }
    }

    Context 'When the tests are negated' {
        It 'Should convert `Should -Not -BeLikeExactly ''Test*''` correctly' {
            'OtherValue' | Should -Not -BeLikeExactly 'Test*'
        }

        It 'Should convert `Should -BeLikeExactly ''Test*'' -Not` correctly' {
            'OtherValue' | Should -BeLikeExactly 'Test*' -Not
        }

        It 'Should convert `Should -Not -BeLikeExactly $anyValue` correctly' {
            $anyValue = 'Test*'

            'OtherValue' | Should -Not -BeLikeExactly $anyValue
        }

        It 'Should convert `Should -BeLikeExactly $anyValue -Not` correctly' {
            $anyValue = 'Test*'

            'OtherValue' | Should -BeLikeExactly $anyValue -Not
        }

        It 'Should convert `Should -Not:$true -BeLikeExactly ''Test*''` correctly' {
            'OtherValue' | Should -Not:$true -BeLikeExactly 'Test*'
        }

        It 'Should convert `Should -Not -ActualValue ''OtherValue'' -BeLikeExactly ''Test*''` correctly' {
            Should -Not -ActualValue 'OtherValue' -BeLikeExactly 'Test*'
        }

        It 'Should convert `Should -ActualValue ''OtherValue'' -Not -BeLikeExactly ''Test*''` correctly' {
            Should -ActualValue 'OtherValue' -Not -BeLikeExactly 'Test*'
        }

        It 'Should convert `Should -ActualValue ''OtherValue'' -BeLikeExactly ''Test*'' -Not` correctly' {
            Should -ActualValue 'OtherValue' -BeLikeExactly 'Test*' -Not
        }

        It 'Should convert `Should -BeLikeExactly ''Test*'' -ActualValue ''OtherValue'' -Not` correctly' {
            Should -BeLikeExactly 'Test*' -ActualValue 'OtherValue' -Not
        }

        It 'Should convert `Should -BeLikeExactly ''Test*'' -Not -ActualValue ''OtherValue''` correctly' {
            Should -BeLikeExactly 'Test*' -Not -ActualValue 'OtherValue'
        }

        It 'Should convert `Should -Not -BeLikeExactly ''Test*'' -ActualValue ''OtherValue''` correctly' {
            Should -Not -BeLikeExactly 'Test*' -ActualValue 'OtherValue'
        }

        It 'Should convert `Should -ActualValue ''OtherValue'' -BeLikeExactly -Not -ExpectedValue ''Test*''` correctly' {
            Should -ActualValue 'OtherValue' -BeLikeExactly -Not -ExpectedValue 'Test*'
        }

        It 'Should convert `Should -ActualValue ''OtherValue'' -Not -BeLikeExactly -ExpectedValue ''Test*''` correctly' {
            Should -ActualValue 'OtherValue' -Not -BeLikeExactly -ExpectedValue 'Test*'
        }

        It 'Should convert `Should -ActualValue ''OtherValue'' -BeLikeExactly -ExpectedValue ''Test*'' -Not` correctly' {
            Should -ActualValue 'OtherValue' -BeLikeExactly -ExpectedValue 'Test*' -Not
        }
    }

    Context 'When tests should always use named parameters' {
        It 'Should convert `Should -BeLikeExactly ''Test*'' -ActualValue ''TestValue''` correctly' {
            Should -BeLikeExactly 'Test*' -ActualValue 'TestValue'
        }
    }

    Context 'When tests should always use positional parameters' {
        Context 'When the tests are affirming' {
            It 'Should convert `Should -BeLikeExactly ''Test*'' -ActualValue ''TestValue''` correctly' {
                Should -BeLikeExactly 'Test*' -ActualValue 'TestValue'
            }

            It 'Should convert `Should -BeLikeExactly ''Test*'' -ActualValue ''TestValue'' -Because "this must return true"` correctly' {
                Should -BeLikeExactly 'Test*' -ActualValue 'TestValue' -Because 'this must return true'
            }

            It 'Should convert `Should -BeLikeExactly ''Test*'' -Because "this must return true" -ActualValue ''TestValue''` correctly' {
                Should -BeLikeExactly 'Test*' -Because 'this must return true' -ActualValue 'TestValue'
            }

            It 'Should convert `Should -Because "this must return true" -ActualValue ''TestValue'' -BeLikeExactly ''Test*''` correctly' {
                Should -Because 'this must return true' -ActualValue 'TestValue' -BeLikeExactly 'Test*'
            }
        }

        Context 'When the tests are negated' {
            It 'Should convert `Should -BeLikeExactly ''Test*'' -ActualValue ''OtherValue'' -Because "this must return true" -Not` correctly' {
                Should -BeLikeExactly 'Test*' -ActualValue 'OtherValue' -Because 'this must return true' -Not
            }
        }
    }
}
