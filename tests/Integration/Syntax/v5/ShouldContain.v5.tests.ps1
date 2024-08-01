Describe 'Should -Contain' {
    Context 'When the tests are affirming' {
        It 'Should convert `Should -Contain ''b''` correctly' {
            @('a', 'b') | Should -Contain 'b'
        }

        It 'Should convert `Should -Contain "b"` correctly' {
            @('a', 'b') | Should -Contain "b"
        }

        It 'Should convert `Should -Contain $anyValue` correctly' {
            $anyValue = 'b'

            @('a', 'b') | Should -Contain $anyValue
        }

        # This is seemingly not supported in Pester v5 to pass an array to -ActualValue.
        # It 'Should convert `Should -ActualValue @(''a'', ''b'') -Contain ''b''` correctly' {
        #     Should -ActualValue @('a', 'b') -Contain 'b'
        # }

        # This is seemingly not supported in Pester v5 to pass an array to -ActualValue.
        # It 'Should convert `Should -Contain ''b'' -ActualValue @(''a'', ''b'')` correctly' {
        #     Should -Contain 'b' -ActualValue @('a', 'b')
        # }

        # This is seemingly not supported in Pester v5 to pass an array to -ActualValue.
        # It 'Should convert `Should -ActualValue @(''a'', ''b'') -Contain -ExpectedValue ''b''` correctly' {
        #     Should -ActualValue @('a', 'b') -Contain -ExpectedValue 'b'
        # }

        # This is seemingly not supported in Pester v5 to pass an array to -ActualValue.
        # It 'Should convert `Should -Contain -ActualValue @(''a'', ''b'') -ExpectedValue ''b''` correctly' {
        #     Should -Contain -ActualValue @('a', 'b') -ExpectedValue 'b'
        # }

        # This is seemingly not supported in Pester v5 to pass an array to -ActualValue.
        # It 'Should convert `Should -Contain -ExpectedValue ''b'' -ActualValue @(''a'', ''b'')` correctly' {
        #     Should -Contain -ExpectedValue 'b' -ActualValue @('a', 'b')
        # }

        # This is seemingly not supported in Pester v5 to pass an array to -ActualValue.
        # It 'Should convert `Should -ExpectedValue ''b'' -Contain -ActualValue @(''a'', ''b'')` correctly' {
        #     Should -ExpectedValue 'b' -Contain -ActualValue @('a', 'b')
        # }

        # This is seemingly not supported in Pester v5 to pass an array to -ActualValue.
        # It 'Should convert `Should -ExpectedValue ''b'' -ActualValue @(''a'', ''b'') -Contain` correctly' {
        #     Should -ExpectedValue 'b' -ActualValue @('a', 'b') -Contain
        # }

        It 'Should convert `Should -Not:$false -Contain ''b''` correctly' {
            @('a', 'b') | Should -Not:$false -Contain 'b'
        }

        It 'Should convert `Should -Contain (Get-Something)` correctly' {
            function Get-Something
            {
                return 'b'
            }

            @('a', 'b') | Should -Contain (Get-Something)
        }

        It 'Should convert `Should -Contain ''b'' -Because ''mock should test correct value''` correctly' {
            @('a', 'b') | Should -Contain 'b' -Because 'mock should test correct value'
        }

        It 'Should convert `Should -Contain ''b'' ''mock should test correct value''` correctly' {
            @('a', 'b') | Should -Contain 'b' 'mock should test correct value'
        }

        <#
            This was not supported in Pester 5.6.1. There it gave the error message:

            RuntimeException: Legacy Should syntax (without dashes) is not supported in Pester 5.Please refer to migration guide at: https://pester.dev/docs/migrations/v3-to-v4
            ParameterBindingException: Cannot retrieve the dynamic parameters for the cmdlet. Legacy Should syntax (without dashes) is not supported in Pester 5. Please refer to migration guide at: https://pester.dev/docs/migrations/v3-to-v4
        #>
        # It 'Should convert `Should ''b'' ''mock should test correct value'' -Contain` correctly' {
        #     @('a', 'b') | Should 'b' 'mock should test correct value' -Contain
        # }
    }

    Context 'When the tests are negated' {
        It 'Should convert `Should -Not -Contain ''b''` correctly' {
            @('a', 'c') | Should -Not -Contain 'b'
        }

        It 'Should convert `Should -Contain ''Test'' -Not` correctly' {
            @('a', 'c') | Should -Contain 'b' -Not
        }

        It 'Should convert `Should -Not -Contain "b"` correctly' {
            @('a', 'c') | Should -Not -Contain 'b'
        }

        It 'Should convert `Should -Not -Contain $anyValue` correctly' {
            $anyValue = 'b'

            @('a', 'c') | Should -Not -Contain $anyValue
        }

        It 'Should convert `Should -Contain $anyValue -Not` correctly' {
            $anyValue = 'b'

            @('a', 'c') | Should -Contain $anyValue -Not
        }

        It 'Should convert `Should -Not:$true -Contain ''b''` correctly' {
            @('a', 'c') | Should -Not:$true -Contain 'b'
        }

        # This is seemingly not supported in Pester v5 to pass an array to -ActualValue.
        # It 'Should convert `Should -Not -ActualValue @(''a'', ''c'') -Contain ''b''` correctly' {
        #     Should -Not -ActualValue @('a', 'c') -Contain 'b'
        # }

        # This is seemingly not supported in Pester v5 to pass an array to -ActualValue.
        # It 'Should convert `Should -ActualValue @(''a'', ''c'') -Not -Contain ''b''` correctly' {
        #     Should -ActualValue @('a', 'c') -Not -Contain 'b'
        # }

        # This is seemingly not supported in Pester v5 to pass an array to -ActualValue.
        # It 'Should convert `Should -ActualValue @(''a'', ''b'') -Contain ''b'' -Not` correctly' {
        #     Should -ActualValue @('a', 'c') -Contain 'b' -Not
        # }

        # This is seemingly not supported in Pester v5 to pass an array to -ActualValue.
        # It 'Should convert `Should -Contain ''b'' -ActualValue @(''a'', ''c'') -Not` correctly' {
        #     Should -Contain 'b' -ActualValue @('a', 'c') -Not
        # }

        # This is seemingly not supported in Pester v5 to pass an array to -ActualValue.
        # It 'Should convert `Should -Contain ''b'' -Not -ActualValue @(''a'', ''c'')` correctly' {
        #     Should -Contain 'b' -Not -ActualValue @('a', 'c')
        # }

        # This is seemingly not supported in Pester v5 to pass an array to -ActualValue.
        # It 'Should convert `Should -Not -Contain ''b'' -ActualValue @(''a'', ''c'')` correctly' {
        #     Should -Not -Contain 'b' -ActualValue @('a', 'c')
        # }

        # This is seemingly not supported in Pester v5 to pass an array to -ActualValue.
        # It 'Should convert `Should -ActualValue @(''a'', ''c'') -Contain -Not -ExpectedValue ''b''` correctly' {
        #     Should -ActualValue @('a', 'c') -Contain -Not -ExpectedValue 'b'
        # }

        # This is seemingly not supported in Pester v5 to pass an array to -ActualValue.
        # It 'Should convert `Should -ActualValue @(''a'', ''c'') -Not -Contain -ExpectedValue ''b''` correctly' {
        #     Should -ActualValue @('a', 'c') -Not -Contain -ExpectedValue 'b'
        # }

        # # This is seemingly not supported in Pester v5 to pass an array to -ActualValue.
        # It 'Should convert `Should -ActualValue @(''a'', ''c'') -Contain -ExpectedValue ''b'' -Not` correctly' {
        #     Should -ActualValue @('a', 'c') -Contain -ExpectedValue 'b' -Not
        # }
    }
}
