Describe 'Should -Match' {
    Context 'When the tests are affirming' {
        It 'Should convert `Should -Match ''Test''` correctly' {
            'Test' | Should -Match 'Test'
        }

        It 'Should convert `Should -Match "ExpectedString"` correctly' {
            'Test' | Should -Match "Test"
        }

        It 'Should convert `Should -Match $anyValue` correctly' {
            $anyValue = 'Test'

            'Test' | Should -Match $anyValue
        }

        It 'Should convert `Should -ActualValue ''ExpectedString'' -Match ''ExpectedString''` correctly' {
            Should -ActualValue 'ExpectedString' -Match 'ExpectedString'
        }

        It 'Should convert `Should -Match ''ExpectedString'' -ActualValue ''ExpectedString''` correctly' {
            Should -Match 'ExpectedString' -ActualValue 'ExpectedString'
        }

        It 'Should convert `Should -ActualValue ''ExpectedString'' -Match -RegularExpression ''ExpectedString''` correctly' {
            Should -ActualValue 'ExpectedString' -Match -RegularExpression 'ExpectedString'
        }

        It 'Should convert `Should -Match -ActualValue ''ExpectedString'' -RegularExpression ''ExpectedString''` correctly' {
            Should -Match -ActualValue 'ExpectedString' -RegularExpression 'ExpectedString'
        }

        It 'Should convert `Should -Match -RegularExpression ''ExpectedString'' -ActualValue ''ExpectedString''` correctly' {
            Should -Match -RegularExpression 'ExpectedString' -ActualValue 'ExpectedString'
        }

        It 'Should convert `Should -RegularExpression ''ExpectedString'' -Match -ActualValue ''ExpectedString''` correctly' {
            Should -RegularExpression 'ExpectedString' -Match -ActualValue 'ExpectedString'
        }

        It 'Should convert `Should -RegularExpression ''ExpectedString'' -ActualValue ''ExpectedString'' -Match` correctly' {
            Should -RegularExpression 'ExpectedString' -ActualValue 'ExpectedString' -Match
        }

        It 'Should convert `Should -Not:$false -Match ''ExpectedString''` correctly' {
            'ExpectedString' | Should -Not:$false -Match 'ExpectedString'
        }

        It 'Should convert `Should -Match (Get-Something)` correctly' {
            function Get-Something
            {
                return 'ExpectedString'
            }

            'ExpectedString' | Should -Match (Get-Something)
        }

        It 'Should convert `Should -Match ''ExpectedString'' -Because ''mock should test correct value'' ''ExpectedString''` correctly' {
            Should -Match 'ExpectedString' -Because 'mock should test correct value' 'ExpectedString'
        }

        It 'Should convert `Should -Match ''ExpectedString'' ''mock should test correct value'' ''ExpectedString''` correctly' {
            Should -Match 'ExpectedString' 'mock should test correct value' 'ExpectedString'
        }

        <#
            This was not supported in Pester 5.6.1. There it gave the error message:

            RuntimeException: Legacy Should syntax (without dashes) is not supported in Pester 5.Please refer to migration guide at: https://pester.dev/docs/migrations/v3-to-v4
            ParameterBindingException: Cannot retrieve the dynamic parameters for the cmdlet. Legacy Should syntax (without dashes) is not supported in Pester 5. Please refer to migration guide at: https://pester.dev/docs/migrations/v3-to-v4
        #>
        # It 'Should convert `Should ''ExpectedString'' ''mock should test correct value'' ''ExpectedString'' -Match` correctly' {
        #     Should 'ExpectedString' 'mock should test correct value' 'ExpectedString' -Match
        # }
    }

    Context 'When the tests are negated' {
        It 'Should convert `Should -Not -Match ''ExpectedString''` correctly' {
            'ActualString' | Should -Not -Match 'ExpectedString'
        }

        It 'Should convert `Should -Match ''Test'' -Not` correctly' {
            'ActualString' | Should -Match 'Test' -Not
        }

        It 'Should convert `Should -Not -Match "ExpectedString"` correctly' {
            'ActualString' | Should -Not -Match 'ExpectedString'
        }

        It 'Should convert `Should -Not -Match $anyValue` correctly' {
            $anyValue = 'Test'

            'ActualString' | Should -Not -Match $anyValue
        }

        It 'Should convert `Should -Match $anyValue -Not` correctly' {
            $anyValue = 'Test'

            'ActualString' | Should -Match $anyValue -Not
        }

        It 'Should convert `Should -Not:$true -Match ''ExpectedString''` correctly' {
            'ActualString' | Should -Not:$true -Match 'ExpectedString'
        }

        It 'Should convert `Should -Not -ActualValue ''ActualString'' -Match ''ExpectedString''` correctly' {
            Should -Not -ActualValue 'ActualString' -Match 'ExpectedString'
        }

        It 'Should convert `Should -ActualValue ''ActualString'' -Not -Match ''ExpectedString''` correctly' {
            Should -ActualValue 'ActualString' -Not -Match 'ExpectedString'
        }

        It 'Should convert `Should -ActualValue ''ActualString'' -Match ''ExpectedString'' -Not` correctly' {
            Should -ActualValue 'ActualString' -Match 'ExpectedString' -Not
        }

        It 'Should convert `Should -Match ''ExpectedString'' -ActualValue ''ActualString'' -Not` correctly' {
            Should -Match 'ExpectedString' -ActualValue 'ActualString' -Not
        }

        It 'Should convert `Should -Match ''ExpectedString'' -Not -ActualValue ''ActualString''` correctly' {
            Should -Match 'ExpectedString' -Not -ActualValue 'ActualString'
        }

        It 'Should convert `Should -Not -Match ''ExpectedString'' -ActualValue ''ActualString''` correctly' {
            Should -Not -Match 'ExpectedString' -ActualValue 'ActualString'
        }

        It 'Should convert `Should -ActualValue ''ActualString'' -Match -Not -RegularExpression ''ExpectedString''` correctly' {
            Should -ActualValue 'ActualString' -Match -Not -RegularExpression 'ExpectedString'
        }

        It 'Should convert `Should -ActualValue ''ActualString'' -Not -Match -RegularExpression ''ExpectedString''` correctly' {
            Should -ActualValue 'ActualString' -Not -Match -RegularExpression 'ExpectedString'
        }

        It 'Should convert `Should -ActualValue ''ActualString'' -Match -RegularExpression ''ExpectedString'' -Not` correctly' {
            Should -ActualValue 'ActualString' -Match -RegularExpression 'ExpectedString' -Not
        }
    }
}
