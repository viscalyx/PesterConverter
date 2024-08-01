Describe 'Should -BeExactly' {
    Context 'When the tests are affirming' {
        It 'Should convert `Should -BeExactly ''Test''` correctly' {
            'Test' | Should -BeExactly 'Test'
        }

        It 'Should convert `Should -BeExactly "ExpectedString"` correctly' {
            'ExpectedString' | Should -BeExactly 'ExpectedString'
        }

        It 'Should convert `Should -BeExactly ''ExpectedString''` correctly' {
            'ExpectedString' | Should -BeExactly 'ExpectedString'
        }

        It 'Should convert `Should -BeExactly $anyValue` correctly' {
            $anyValue = 'ExpectedString'

            'ExpectedString' | Should -BeExactly $anyValue
        }

        It 'Should convert `Should -ActualValue ''ExpectedString'' -BeExactly ''ExpectedString''` correctly' {
            Should -ActualValue 'ExpectedString' -BeExactly 'ExpectedString'
        }

        It 'Should convert `Should -BeExactly ''ExpectedString'' -ActualValue ''ExpectedString''` correctly' {
            Should -BeExactly 'ExpectedString' -ActualValue 'ExpectedString'
        }

        It 'Should convert `Should -ActualValue ''ExpectedString'' -BeExactly -ExpectedValue ''ExpectedString''` correctly' {
            Should -ActualValue 'ExpectedString' -BeExactly -ExpectedValue 'ExpectedString'
        }

        It 'Should convert `Should -BeExactly -ActualValue ''ExpectedString'' -ExpectedValue ''ExpectedString''` correctly' {
            Should -BeExactly -ActualValue 'ExpectedString' -ExpectedValue 'ExpectedString'
        }

        It 'Should convert `Should -BeExactly -ExpectedValue ''ExpectedString'' -ActualValue ''ExpectedString''` correctly' {
            Should -BeExactly -ExpectedValue 'ExpectedString' -ActualValue 'ExpectedString'
        }

        It 'Should convert `Should -ExpectedValue ''ExpectedString'' -BeExactly -ActualValue ''ExpectedString''` correctly' {
            Should -ExpectedValue 'ExpectedString' -BeExactly -ActualValue 'ExpectedString'
        }

        It 'Should convert `Should -ExpectedValue ''ExpectedString'' -ActualValue ''ExpectedString'' -BeExactly` correctly' {
            Should -ExpectedValue 'ExpectedString' -ActualValue 'ExpectedString' -BeExactly
        }

        It 'Should convert `Should -Not:$false -BeExactly ''ExpectedString''` correctly' {
            'ExpectedString' | Should -Not:$false -BeExactly 'ExpectedString'
        }

        It 'Should convert `Should -BeExactly (Get-Something)` correctly' {
            function Get-Something
            {
                return 'ExpectedString'
            }

            'ExpectedString' | Should -BeExactly (Get-Something)
        }

        It 'Should convert `Should -BeExactly ''ExpectedString'' -Because ''mock should test correct value'' ''ExpectedString''` correctly' {
            Should -BeExactly 'ExpectedString' -Because 'mock should test correct value' 'ExpectedString'
        }

        It 'Should convert `Should -BeExactly ''ExpectedString'' ''mock should test correct value'' ''ActualString''` correctly' {
            Should -BeExactly 'ExpectedString' 'mock should test correct value' 'ExpectedString'
        }

        <#
            This was not supported in Pester 5.6.1. There it gave the error message:

            RuntimeException: Legacy Should syntax (without dashes) is not supported in Pester 5.Please refer to migration guide at: https://pester.dev/docs/migrations/v3-to-v4
            ParameterBindingException: Cannot retrieve the dynamic parameters for the cmdlet. Legacy Should syntax (without dashes) is not supported in Pester 5. Please refer to migration guide at: https://pester.dev/docs/migrations/v3-to-v4
        #>
        # It 'Should convert `Should ''ExpectedString'' ''mock should test correct value'' ''ActualString'' -BeExactly` correctly' {
        #     Should 'ExpectedString' 'mock should test correct value' 'ExpectedString' -BeExactly
        # }
    }

    Context 'When the tests are negated' {
        It 'Should convert `Should -Not -BeExactly ''ExpectedString''` correctly' {
            'ActualString' | Should -Not -BeExactly 'ExpectedString'
        }

        It 'Should convert `Should -BeExactly ''ExpectedString'' -Not` correctly' {
            'ActualString' | Should -BeExactly 'ExpectedString' -Not
        }

        It 'Should convert `Should -Not -BeExactly "ExpectedString"` correctly' {
            'ActualString' | Should -Not -BeExactly 'ExpectedString'
        }

        It 'Should convert `Should -Not -BeExactly $anyValue` correctly' {
            $anyValue = 'ExpectedString'

            'ActualString' | Should -Not -BeExactly $anyValue
        }

        It 'Should convert `Should -BeExactly $anyValue -Not` correctly' {
            $anyValue = 'ExpectedString'

            'ActualString' | Should -BeExactly $anyValue -Not
        }

        It 'Should convert `Should -Not:$true -BeExactly ''ExpectedString''` correctly' {
            'ActualString' | Should -Not:$true -BeExactly 'ExpectedString'
        }

        It 'Should convert `Should -Not -ActualValue ''ActualString'' -BeExactly ''ExpectedString''` correctly' {
            Should -Not -ActualValue 'ActualString' -BeExactly 'ExpectedString'
        }

        It 'Should convert `Should -ActualValue ''ActualString'' -Not -BeExactly ''ExpectedString''` correctly' {
            Should -ActualValue 'ActualString' -Not -BeExactly 'ExpectedString'
        }

        It 'Should convert `Should -ActualValue ''ActualString'' -BeExactly ''ExpectedString'' -Not` correctly' {
            Should -ActualValue 'ActualString' -BeExactly 'ExpectedString' -Not
        }

        It 'Should convert `Should -BeExactly ''ExpectedString'' -ActualValue ''ActualString'' -Not` correctly' {
            Should -BeExactly 'ExpectedString' -ActualValue 'ActualString' -Not
        }

        It 'Should convert `Should -BeExactly ''ExpectedString'' -Not -ActualValue ''ActualString''` correctly' {
            Should -BeExactly 'ExpectedString' -Not -ActualValue 'ActualString'
        }

        It 'Should convert `Should -Not -BeExactly ''ExpectedString'' -ActualValue ''ActualString''` correctly' {
            Should -Not -BeExactly 'ExpectedString' -ActualValue 'ActualString'
        }

        It 'Should convert `Should -ActualValue ''ActualString'' -BeExactly -Not -ExpectedValue ''ExpectedString''` correctly' {
            Should -ActualValue 'ActualString' -BeExactly -Not -ExpectedValue 'ExpectedString'
        }

        It 'Should convert `Should -ActualValue ''ActualString'' -Not -BeExactly -ExpectedValue ''ExpectedString''` correctly' {
            Should -ActualValue 'ActualString' -Not -BeExactly -ExpectedValue 'ExpectedString'
        }

        It 'Should convert `Should -ActualValue ''ActualString'' -BeExactly -ExpectedValue ''ExpectedString'' -Not` correctly' {
            Should -ActualValue 'ActualString' -BeExactly -ExpectedValue 'ExpectedString' -Not
        }
    }

    Context 'When alias operator name is used' {
        It 'Should convert `Should -CEQ ''ExpectedString'' -ActualValue ''ExpectedString''` correctly' {
            Should -CEQ 'ExpectedString' -ActualValue 'ExpectedString'
        }
    }
}
