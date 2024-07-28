Describe 'Should -BeTrue' {
    Context 'When the tests are affirming' {
        It 'Should convert `Should -BeTrue` correctly' {
            $true | Should -BeTrue
        }

        It 'Should convert `Should -BeTrue -Because ''BecauseMockString''` correctly' {
            $true | Should -BeTrue -Because 'BecauseMockString'
        }

        It 'Should convert `Should -BeTrue -ActualValue $true -Because ''BecauseMockString''` correctly' {
            Should -BeTrue -ActualValue $true -Because 'BecauseMockString'
        }

        It 'Should convert `Should -BeTrue ''BecauseMockString''` correctly' {
            $true | Should -BeTrue 'BecauseMockString'
        }

        It 'Should convert `Should -BeTrue ''BecauseMockString'' $true` correctly' {
            Should -BeTrue 'BecauseMockString' $true
        }

        It 'Should convert `Should -Not:$false -BeTrue ''BecauseMockString'' $true` correctly' {
            Should -Not:$false -BeTrue 'BecauseMockString' $true
        }

        It 'Should convert `Should -BeTrue -ActualValue $true ''BecauseMockString''` correctly' {
            Should -BeTrue -ActualValue $true 'BecauseMockString'
        }

        It 'Should convert `Should -BeTrue ''BecauseMockString'' -ActualValue $true` correctly' {
            Should -BeTrue 'BecauseMockString' -ActualValue $true
        }

        It 'Should convert `Should -BeTrue -Because ''BecauseMockString'' $true` correctly' {
            Should -BeTrue -Because 'BecauseMockString' $true
        }

        It 'Should convert `Should -BeTrue $true -Because ''BecauseMockString''` correctly' {
            Should -BeTrue -Because 'BecauseMockString' $true
        }

        It 'Should convert `Should -BeTrue ''BecauseMockString'' (Get-BooleanValue)` correctly' {
            function Get-BooleanValue
            {
                return $true
            }

            Should -BeTrue 'BecauseMockString' (Get-BooleanValue)
        }

        It 'Should convert `Should -BeTrue -ActualValue $true` correctly' {
            Should -BeTrue -ActualValue $true
        }
    }

    Context 'When the tests are negated' {
        It 'Should convert `Should -Not -BeTrue` correctly' {
            $false | Should -Not -BeTrue
        }

        It 'Should convert `Should -BeTrue -Not:$true` correctly' {
            $false | Should -BeTrue -Not:$true
        }
    }

    Context 'When tests should always use named parameters' {
        It 'Should convert `Should -BeTrue ''BecauseMockString'' $true` correctly' {
            Should -BeTrue 'BecauseMockString' $true
        }
    }

    Context 'When tests should always use positional parameters' {
        It 'Should convert `Should -BeTrue -Because ''BecauseMockString'' -ActualValue $true` correctly' {
            Should -BeTrue -Because 'BecauseMockString' -ActualValue $true
        }
    }
}
