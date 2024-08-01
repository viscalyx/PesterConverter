# TODO: When Pester 6 supports `Should-MatchString` and `Should-NotMatchString` this test should be activated.
Describe 'Should -MatchExactly' -Skip:$true {
    Context 'When the tests are affirming' {
        It 'Should convert `Should -MatchExactly ''Test''` correctly' {
            'Test' | Should -MatchExactly 'Test'
        }

        It 'Should convert `Should -MatchExactly "ExpectedString"` correctly' {
            'Test' | Should -MatchExactly "Test"
        }

        It 'Should convert `Should -MatchExactly $anyValue` correctly' {
            $anyValue = 'Test'

            'Test' | Should -MatchExactly $anyValue
        }

        It 'Should convert `Should -ActualValue ''ExpectedString'' -MatchExactly ''ExpectedString''` correctly' {
            Should -ActualValue 'ExpectedString' -MatchExactly 'ExpectedString'
        }

        It 'Should convert `Should -MatchExactly ''ExpectedString'' -ActualValue ''ExpectedString''` correctly' {
            Should -MatchExactly 'ExpectedString' -ActualValue 'ExpectedString'
        }

        It 'Should convert `Should -ActualValue ''ExpectedString'' -MatchExactly -RegularExpression ''ExpectedString''` correctly' {
            Should -ActualValue 'ExpectedString' -MatchExactly -RegularExpression 'ExpectedString'
        }

        It 'Should convert `Should -MatchExactly -ActualValue ''ExpectedString'' -RegularExpression ''ExpectedString''` correctly' {
            Should -MatchExactly -ActualValue 'ExpectedString' -RegularExpression 'ExpectedString'
        }

        It 'Should convert `Should -MatchExactly -RegularExpression ''ExpectedString'' -ActualValue ''ExpectedString''` correctly' {
            Should -MatchExactly -RegularExpression 'ExpectedString' -ActualValue 'ExpectedString'
        }

        It 'Should convert `Should -RegularExpression ''ExpectedString'' -MatchExactly -ActualValue ''ExpectedString''` correctly' {
            Should -RegularExpression 'ExpectedString' -MatchExactly -ActualValue 'ExpectedString'
        }

        It 'Should convert `Should -RegularExpression ''ExpectedString'' -ActualValue ''ExpectedString'' -MatchExactly` correctly' {
            Should -RegularExpression 'ExpectedString' -ActualValue 'ExpectedString' -MatchExactly
        }

        It 'Should convert `Should -Not:$false -MatchExactly ''ExpectedString''` correctly' {
            'ExpectedString' | Should -Not:$false -MatchExactly 'ExpectedString'
        }

        It 'Should convert `Should -MatchExactly (Get-Something)` correctly' {
            function Get-Something
            {
                return 'ExpectedString'
            }

            'ExpectedString' | Should -MatchExactly (Get-Something)
        }

        It 'Should convert `Should -MatchExactly ''ExpectedString'' -Because ''mock should test correct value'' ''ExpectedString''` correctly' {
            Should -MatchExactly 'ExpectedString' -Because 'mock should test correct value' 'ExpectedString'
        }

        It 'Should convert `Should -MatchExactly ''ExpectedString'' ''mock should test correct value'' ''ExpectedString''` correctly' {
            Should -MatchExactly 'ExpectedString' 'mock should test correct value' 'ExpectedString'
        }

        <#
            This was not supported in Pester 5.6.1. There it gave the error message:

            RuntimeException: Legacy Should syntax (without dashes) is not supported in Pester 5.Please refer to migration guide at: https://pester.dev/docs/migrations/v3-to-v4
            ParameterBindingException: Cannot retrieve the dynamic parameters for the cmdlet. Legacy Should syntax (without dashes) is not supported in Pester 5. Please refer to migration guide at: https://pester.dev/docs/migrations/v3-to-v4
        #>
        # It 'Should convert `Should ''ExpectedString'' ''mock should test correct value'' ''ExpectedString'' -MatchExactly` correctly' {
        #     Should 'ExpectedString' 'mock should test correct value' 'ExpectedString' -MatchExactly
        # }
    }

    Context 'When the tests are negated' {
        It 'Should convert `Should -Not -MatchExactly ''ExpectedString''` correctly' {
            'ActualString' | Should -Not -MatchExactly 'ExpectedString'
        }

        It 'Should convert `Should -MatchExactly ''Test'' -Not` correctly' {
            'ActualString' | Should -MatchExactly 'Test' -Not
        }

        It 'Should convert `Should -Not -MatchExactly "ExpectedString"` correctly' {
            'ActualString' | Should -Not -MatchExactly 'ExpectedString'
        }

        It 'Should convert `Should -Not -MatchExactly $anyValue` correctly' {
            $anyValue = 'Test'

            'ActualString' | Should -Not -MatchExactly $anyValue
        }

        It 'Should convert `Should -MatchExactly $anyValue -Not` correctly' {
            $anyValue = 'Test'

            'ActualString' | Should -MatchExactly $anyValue -Not
        }

        It 'Should convert `Should -Not:$true -MatchExactly ''ExpectedString''` correctly' {
            'ActualString' | Should -Not:$true -MatchExactly 'ExpectedString'
        }

        It 'Should convert `Should -Not -ActualValue ''ActualString'' -MatchExactly ''ExpectedString''` correctly' {
            Should -Not -ActualValue 'ActualString' -MatchExactly 'ExpectedString'
        }

        It 'Should convert `Should -ActualValue ''ActualString'' -Not -MatchExactly ''ExpectedString''` correctly' {
            Should -ActualValue 'ActualString' -Not -MatchExactly 'ExpectedString'
        }

        It 'Should convert `Should -ActualValue ''ActualString'' -MatchExactly ''ExpectedString'' -Not` correctly' {
            Should -ActualValue 'ActualString' -MatchExactly 'ExpectedString' -Not
        }

        It 'Should convert `Should -MatchExactly ''ExpectedString'' -ActualValue ''ActualString'' -Not` correctly' {
            Should -MatchExactly 'ExpectedString' -ActualValue 'ActualString' -Not
        }

        It 'Should convert `Should -MatchExactly ''ExpectedString'' -Not -ActualValue ''ActualString''` correctly' {
            Should -MatchExactly 'ExpectedString' -Not -ActualValue 'ActualString'
        }

        It 'Should convert `Should -Not -MatchExactly ''ExpectedString'' -ActualValue ''ActualString''` correctly' {
            Should -Not -MatchExactly 'ExpectedString' -ActualValue 'ActualString'
        }

        It 'Should convert `Should -ActualValue ''ActualString'' -MatchExactly -Not -RegularExpression ''ExpectedString''` correctly' {
            Should -ActualValue 'ActualString' -MatchExactly -Not -RegularExpression 'ExpectedString'
        }

        It 'Should convert `Should -ActualValue ''ActualString'' -Not -MatchExactly -RegularExpression ''ExpectedString''` correctly' {
            Should -ActualValue 'ActualString' -Not -MatchExactly -RegularExpression 'ExpectedString'
        }

        It 'Should convert `Should -ActualValue ''ActualString'' -MatchExactly -RegularExpression ''ExpectedString'' -Not` correctly' {
            Should -ActualValue 'ActualString' -MatchExactly -RegularExpression 'ExpectedString' -Not
        }
    }
}
