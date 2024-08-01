Describe 'Should -BeLike' {
    Context 'When the tests are affirming' {
        It 'Should convert `Should -BeLike ''Test*''` correctly' {
           'TestValue' | Should -BeLike 'Test*'
        }

        It 'Should convert `Should -BeLike "Test*"` correctly' {
            'TestValue' | Should -BeLike "Test*"
        }

        It 'Should convert `Should -BeLike $anyValue` correctly' {
            $anyValue = 'Test*'

            'TestValue' | Should -BeLike $anyValue
        }

        It 'Should convert `Should -ActualValue ''TestValue'' -BeLike ''Test*''` correctly' {
            Should -ActualValue 'TestValue' -BeLike 'Test*'
        }

        It 'Should convert `Should -BeLike ''Test*'' -ActualValue ''TestValue''` correctly' {
            Should -BeLike 'Test*' -ActualValue 'TestValue'
        }

        It 'Should convert `Should -ActualValue ''TestValue'' -BeLike -ExpectedValue ''Test*''` correctly' {
            Should -ActualValue 'TestValue' -BeLike -ExpectedValue 'Test*'
        }

        It 'Should convert `Should -BeLike -ActualValue ''TestValue'' -ExpectedValue ''Test*''` correctly' {
            Should -BeLike -ActualValue 'TestValue' -ExpectedValue 'Test*'
        }

        It 'Should convert `Should -BeLike -ExpectedValue ''Test*'' -ActualValue ''TestValue''` correctly' {
            Should -BeLike -ExpectedValue 'Test*' -ActualValue 'TestValue'
        }

        It 'Should convert `Should -ExpectedValue ''Test*'' -BeLike -ActualValue ''TestValue''` correctly' {
            Should -ExpectedValue 'Test*' -BeLike -ActualValue 'TestValue'
        }

        It 'Should convert `Should -ExpectedValue ''Test*'' -ActualValue ''TestValue'' -BeLike` correctly' {
            Should -ExpectedValue 'Test*' -ActualValue 'TestValue' -BeLike
        }

        It 'Should convert `Should -Not:$false -BeLike ''Test*''` correctly' {
            'TestValue' | Should -Not:$false -BeLike 'Test*'
        }

        It 'Should convert `Should -BeLike (Get-Something)` correctly' {
            function Get-Something
            {
                return 'Test*'
            }

            'TestValue' | Should -BeLike (Get-Something)
        }

        It 'Should convert `Should -BeLike ''Test*'' -Because ''mock should test correct value'' ''TestValue''` correctly' {
            Should -BeLike 'Test*' -Because 'mock should test correct value' 'TestValue*'
        }

        It 'Should convert `Should -BeLike ''Test*'' ''mock should test correct value'' ''TestValue''` correctly' {
            Should -BeLike 'Test*' 'mock should test correct value' 'TestValue'
        }

        <#
            This was not supported in Pester 5.6.1. There it gave the error message:

            RuntimeException: Legacy Should syntax (without dashes) is not supported in Pester 5.Please refer to migration guide at: https://pester.dev/docs/migrations/v3-to-v4
            ParameterBindingException: Cannot retrieve the dynamic parameters for the cmdlet. Legacy Should syntax (without dashes) is not supported in Pester 5. Please refer to migration guide at: https://pester.dev/docs/migrations/v3-to-v4
        #>
        # It 'Should convert `Should ''Test*'' ''mock should test correct value'' ''TestValue'' -BeLike` correctly' {
        #     Should 'Test*' 'mock should test correct value' 'TestValue' -BeLike
        # }
    }

    Context 'When the tests are negated' {
        It 'Should convert `Should -Not -BeLike ''Test*''` correctly' {
            'OtherValue' | Should -Not -BeLike 'Test*'
        }

        It 'Should convert `Should -BeLike ''Test*'' -Not` correctly' {
            'OtherValue' | Should -BeLike 'Test*' -Not
        }

        It 'Should convert `Should -Not -BeLike $anyValue` correctly' {
            $anyValue = 'Test*'

            'OtherValue' | Should -Not -BeLike $anyValue
        }

        It 'Should convert `Should -BeLike $anyValue -Not` correctly' {
            $anyValue = 'Test*'

            'OtherValue' | Should -BeLike $anyValue -Not
        }

        It 'Should convert `Should -Not:$true -BeLike ''Test*''` correctly' {
            'OtherValue' | Should -Not:$true -BeLike 'Test*'
        }

        It 'Should convert `Should -Not -ActualValue ''OtherValue'' -BeLike ''Test*''` correctly' {
            Should -Not -ActualValue 'OtherValue' -BeLike 'Test*'
        }

        It 'Should convert `Should -ActualValue ''OtherValue'' -Not -BeLike ''Test*''` correctly' {
            Should -ActualValue 'OtherValue' -Not -BeLike 'Test*'
        }

        It 'Should convert `Should -ActualValue ''OtherValue'' -BeLike ''Test*'' -Not` correctly' {
            Should -ActualValue 'OtherValue' -BeLike 'Test*' -Not
        }

        It 'Should convert `Should -BeLike ''Test*'' -ActualValue ''OtherValue'' -Not` correctly' {
            Should -BeLike 'Test*' -ActualValue 'OtherValue' -Not
        }

        It 'Should convert `Should -BeLike ''Test*'' -Not -ActualValue ''OtherValue''` correctly' {
            Should -BeLike 'Test*' -Not -ActualValue 'OtherValue'
        }

        It 'Should convert `Should -Not -BeLike ''Test*'' -ActualValue ''OtherValue''` correctly' {
            Should -Not -BeLike 'Test*' -ActualValue 'OtherValue'
        }

        It 'Should convert `Should -ActualValue ''OtherValue'' -BeLike -Not -ExpectedValue ''Test*''` correctly' {
            Should -ActualValue 'OtherValue' -BeLike -Not -ExpectedValue 'Test*'
        }

        It 'Should convert `Should -ActualValue ''OtherValue'' -Not -BeLike -ExpectedValue ''Test*''` correctly' {
            Should -ActualValue 'OtherValue' -Not -BeLike -ExpectedValue 'Test*'
        }

        It 'Should convert `Should -ActualValue ''OtherValue'' -BeLike -ExpectedValue ''Test*'' -Not` correctly' {
            Should -ActualValue 'OtherValue' -BeLike -ExpectedValue 'Test*' -Not
        }
    }
}
