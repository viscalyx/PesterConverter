Describe 'Should -BeOfType' {
    Context 'When the tests are affirming' {
        It 'Should convert `Should -BeOfType ''System.String''` correctly' {
            'AnyString' | Should -BeOfType 'System.String'
        }

        It 'Should convert `Should -BeOfType [System.String]` correctly' {
            'AnyString' | Should -BeOfType [System.String]
        }

        It 'Should convert `Should -BeOfType [System.String] ''BecauseString''` correctly' {
            'AnyString' | Should -BeOfType [System.String] 'BecauseString'
        }

        It 'Should convert `Should -ActualValue ''AnyString'' [System.String] -BeOfType ''BecauseString''` correctly' {
            Should -ActualValue 'AnyString' [System.String] -BeOfType 'BecauseString'
        }

        It 'Should convert `Should -ActualValue ''AnyString'' [System.String] -BeOfType -Because ''BecauseString''` correctly' {
            Should -ActualValue 'AnyString' [System.String] -BeOfType 'BecauseString'
        }

        It 'Should convert `Should -ActualValue ''AnyString'' -ExpectedType [System.String] -BeOfType -Because ''BecauseString''` correctly' {
            Should -ActualValue 'AnyString' -ExpectedType [System.String] -BeOfType -Because 'BecauseString'
        }

        It 'Should convert `Should -BeOfType [System.String] -ActualValue ''AnyString''` correctly' {
            Should -BeOfType [System.String] -ActualValue 'AnyString'
        }

        It 'Should convert `Should -ExpectedType [System.String] -ActualValue ''AnyString'' -BeOfType` correctly' {
            Should -ExpectedType [System.String] -ActualValue 'AnyString' -BeOfType
        }

        It 'Should convert `Should -Not:$false -ExpectedType [System.String] -ActualValue ''AnyString'' -BeOfType` correctly' {
            Should -Not:$false -ExpectedType [System.String] -ActualValue 'AnyString' -BeOfType
        }

        It 'Should convert `Should -BeOfType (Get-Something)` correctly' {
            function Get-MyType
            {
                return ([System.String])
            }

            'AnyString' | Should -BeOfType (Get-MyType)
        }
    }

    Context 'When the tests are negated' {
        It 'Should convert `Should -Not -Be 1` correctly' {
            2 | Should -Not -BeOfType [System.String]
        }

        It 'Should convert `Should -BeOfType [System.String] -Not` correctly' {
            2 | Should -BeOfType [System.String] -Not
        }

        It 'Should convert `Should -Not -BeOfType $anyValue` correctly' {
            $anyValue = ([System.String])

            2 | Should -Not -BeOfType $anyValue
        }
    }

    Context 'When alias operator name is used' {
        It 'Should convert `Should -HaveType [System.String] -ActualValue ''AnyString''` correctly' {
            Should -HaveType [System.String] -ActualValue 'AnyString'
        }
    }
}
