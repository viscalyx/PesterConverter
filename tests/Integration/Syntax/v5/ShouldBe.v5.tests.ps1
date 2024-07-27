Describe 'Should -Be' {
    Context 'When the tests are affirming' {
        It 'Should convert `Should -Be 1` correctly' {
            1 | Should -Be 1
        }

        It 'Should convert `Should -Be "AnyString"` correctly' {
            'AnyString' | Should -Be 'AnyString'
        }

        It 'Should convert `Should -Be ''AnyString''` correctly' {
            'AnyString' | Should -Be 'AnyString'
        }

        It 'Should convert `Should -Be $true` correctly' {
            $true | Should -Be $true
        }

        It 'Should convert `Should -Be $anyValue` correctly' {
            $anyValue = 1

            1 | Should -Be $anyValue
        }

        It 'Should convert `Should -ActualValue $true -Be $true` correctly' {
            Should -ActualValue $true -Be $true
        }

        It 'Should convert `Should -Be $true -ActualValue $true` correctly' {
            Should -Be $true -ActualValue $true
        }

        It 'Should convert `Should -ActualValue $true -Be -ExpectedValue $true` correctly' {
            Should -ActualValue $true -Be -ExpectedValue $true
        }

        It 'Should convert `Should -Be -ActualValue $true -ExpectedValue $true` correctly' {
            Should -Be -ActualValue $true -ExpectedValue $true
        }

        It 'Should convert `Should -Be -ExpectedValue $false -ActualValue $false` correctly' {
            Should -Be -ExpectedValue $false -ActualValue $false
        }

        It 'Should convert `Should -ExpectedValue $false -Be -ActualValue $false` correctly' {
            Should -ExpectedValue $false -Be -ActualValue $false
        }

        It 'Should convert `Should -ExpectedValue $true -ActualValue $true -Be` correctly' {
            Should -ExpectedValue $true -ActualValue $true -Be
        }

        It 'Should convert `Should -Not:$false -Be $false` correctly' {
            $false | Should -Not:$false -Be $false
        }

        It 'Should convert `Should -Be (Get-Something)` correctly' {
            function Get-Something
            {
                return 'AnyString'
            }

            'AnyString' | Should -Be (Get-Something)
        }

        It 'Should convert `Should -Be $false -Because ''mock should test correct value'' $false` correctly' {
            Should -Be $false -Because 'mock should test correct value' $false
        }

        It 'Should convert `Should -Be ''ExpectedString'' ''mock should test correct value'' ''ExpectedString''` correctly' {
            Should -Be 'ExpectedString' 'mock should test correct value' 'ExpectedString'
        }


        <#
            This was not supported in Pester 5.6.1. There it gave the error message:

            RuntimeException: Legacy Should syntax (without dashes) is not supported in Pester 5.Please refer to migration guide at: https://pester.dev/docs/migrations/v3-to-v4
            ParameterBindingException: Cannot retrieve the dynamic parameters for the cmdlet. Legacy Should syntax (without dashes) is not supported in Pester 5. Please refer to migration guide at: https://pester.dev/docs/migrations/v3-to-v4
        #>
        # It 'Should convert `Should ''ExpectedString'' -Be ''mock should test correct value'' ''ExpectedString''` correctly' {
        #     Should 'ExpectedString' -Be 'mock should test correct value' 'ExpectedString'
        # }

        <#
            This was not supported in Pester 5.6.1. There it gave the error message:

            RuntimeException: Legacy Should syntax (without dashes) is not supported in Pester 5.Please refer to migration guide at: https://pester.dev/docs/migrations/v3-to-v4
            ParameterBindingException: Cannot retrieve the dynamic parameters for the cmdlet. Legacy Should syntax (without dashes) is not supported in Pester 5. Please refer to migration guide at: https://pester.dev/docs/migrations/v3-to-v4
        #>
        # It 'Should convert `Should ''ExpectedString'' ''mock should test correct value'' -Be ''ExpectedString''` correctly' {
        #     Should  'ExpectedString' 'mock should test correct value' -Be 'ExpectedString'
        # }

        <#
            This was not supported in Pester 5.6.1. There it gave the error message:

            RuntimeException: Legacy Should syntax (without dashes) is not supported in Pester 5.Please refer to migration guide at: https://pester.dev/docs/migrations/v3-to-v4
            ParameterBindingException: Cannot retrieve the dynamic parameters for the cmdlet. Legacy Should syntax (without dashes) is not supported in Pester 5. Please refer to migration guide at: https://pester.dev/docs/migrations/v3-to-v4
        #>
        # It 'Should convert `Should ''ExpectedString'' ''mock should test correct value'' ''ExpectedString'' -Be` correctly' {
        #     Should 'ExpectedString' 'mock should test correct value' 'ActualString' -Be
        # }
    }

    Context 'When the tests are negated' {
        It 'Should convert `Should -Not -Be 1` correctly' {
            2 | Should -Not -Be 1
        }

        It 'Should convert `Should -Be 1 -Not` correctly' {
            2 | Should -Be 1 -Not
        }

        It 'Should convert `Should -Not -Be "AnyString"` correctly' {
            'OtherString' | Should -Not -Be 'AnyString'
        }

        It 'Should convert `Should -Not -Be ''AnyString''` correctly' {
            'OtherString' | Should -Not -Be 'AnyString'
        }

        It 'Should convert `Should -Not -Be $true` correctly' {
            $false | Should -Not -Be $true
        }

        It 'Should convert `Should -Not -Be $anyValue` correctly' {
            $anyValue = 2

            1 | Should -Not -Be $anyValue
        }

        It 'Should convert `Should -Be $true -Not` correctly' {
            $false | Should -Be $true -Not
        }

        It 'Should convert `Should -Not:$true -Be $true` correctly' {
            $false | Should -Not:$true -Be $true
        }

        It 'Should convert `Should -Not -ActualValue $true -Be $false` correctly' {
            Should -Not -ActualValue $true -Be $false
        }

        It 'Should convert `Should -ActualValue $true -Not -Be $false` correctly' {
            Should -ActualValue $true -Not -Be $false
        }

        It 'Should convert `Should -ActualValue $true -Be $false -Not` correctly' {
            Should -ActualValue $true -Be $false -Not
        }

        It 'Should convert `Should -Be $false -ActualValue $true -Not` correctly' {
            Should -Be $false -ActualValue $true -Not
        }

        It 'Should convert `Should -Be $false -Not -ActualValue $true` correctly' {
            Should -Be $false -Not -ActualValue $true
        }

        It 'Should convert `Should -Not -Be $false -ActualValue $true` correctly' {
            Should -Not -Be $false -ActualValue $true
        }

        It 'Should convert `Should -ActualValue $true -Be -Not -ExpectedValue $false` correctly' {
            Should -ActualValue $true -Be -Not -ExpectedValue $false
        }

        It 'Should convert `Should -ActualValue $true -Not -Be -ExpectedValue $false` correctly' {
            Should -ActualValue $true -Not -Be -ExpectedValue $false
        }

        It 'Should convert `Should -ActualValue $true -Be -ExpectedValue $false -Not` correctly' {
            Should -ActualValue $true -Be -ExpectedValue $false -Not
        }
    }

    Context 'When tests should always use named parameters' {
        It 'Should convert `Should -Be $true -ActualValue $true` correctly' {
            Should -Be $true -ActualValue $true
        }
    }

    Context 'When alias operator name is used' {
        It 'Should convert `Should -EQ $true -ActualValue $true` correctly' {
            Should -EQ $true -ActualValue $true
        }
    }

    Context 'When tests should always use positional parameters' {
        Context 'When the tests are affirming' {
            It 'Should convert `Should -Be ''ExpectedString'' -ActualValue ''ExpectedString''` correctly' {
                Should -Be 'ExpectedString' -ActualValue 'ExpectedString'
            }

            It 'Should convert `Should -Be $true -ActualValue $true -Because "this must return true"` correctly' {
                Should -Be $true -ActualValue $true -Because 'this must return true'
            }

            It 'Should convert `Should -Be $true -Because "this must return true" -ActualValue $true` correctly' {
                Should -Be $true -Because 'this must return true' -ActualValue $true
            }

            It 'Should convert `Should -Because "this must return true" -ActualValue $true -Be $true` correctly' {
                Should -Because 'this must return true' -ActualValue $true -Be $true
            }
        }

        Context 'When the tests are negated' {
            It 'Should convert `Should -Be $true -ActualValue $true -Because "this must return true" -Not` correctly' {
                Should -Be $true -ActualValue $false -Because 'this must return true' -Not
            }
        }
    }
}
