Describe 'Should -BeNullOrEmpty' {
    Context 'When the tests are affirming' {
        It 'Should convert `$null | Should -BeNullOrEmpty` correctly' {
            $null | Should -BeNullOrEmpty
        }

        It 'Should convert `'' | Should -BeNullOrEmpty` correctly' {
            '' | Should -BeNullOrEmpty
        }

        It 'Should convert `@() | Should -BeNullOrEmpty` correctly' {
            @() | Should -BeNullOrEmpty
        }

        It 'Should convert `Should -BeNullOrEmpty -Because ''BecauseMockString''` correctly' {
            $null | Should -BeNullOrEmpty -Because 'BecauseMockString'
        }

        It 'Should convert `Should -BeNullOrEmpty -ActualValue $null -Because ''BecauseMockString''` correctly' {
            Should -BeNullOrEmpty -ActualValue $null -Because 'BecauseMockString'
        }

        It 'Should convert `Should -BeNullOrEmpty ''BecauseMockString''` correctly' {
            $null | Should -BeNullOrEmpty 'BecauseMockString'
        }

        It 'Should convert `Should -BeNullOrEmpty ''BecauseMockString'' $null` correctly' {
            Should -BeNullOrEmpty 'BecauseMockString' $null
        }

        It 'Should convert `Should -Not:$false -BeNullOrEmpty ''BecauseMockString'' $null` correctly' {
            Should -Not:$false -BeNullOrEmpty 'BecauseMockString' $null
        }

        It 'Should convert `Should -BeNullOrEmpty -ActualValue $null ''BecauseMockString''` correctly' {
            Should -BeNullOrEmpty -ActualValue $null 'BecauseMockString'
        }

        It 'Should convert `Should -BeNullOrEmpty ''BecauseMockString'' -ActualValue $true` correctly' {
            Should -BeNullOrEmpty 'BecauseMockString' -ActualValue $null
        }

        It 'Should convert `Should -BeNullOrEmpty -Because ''BecauseMockString'' $true` correctly' {
            Should -BeNullOrEmpty -Because 'BecauseMockString' $null
        }

        It 'Should convert `Should -BeNullOrEmpty $null -Because ''BecauseMockString''` correctly' {
            Should -BeNullOrEmpty $null -Because 'BecauseMockString'
        }

        It 'Should convert `Should -BeNullOrEmpty ''BecauseMockString'' (Get-BooleanValue)` correctly' {
            function Get-NullOrEmptyValue
            {
                return $null
            }

            Should -BeNullOrEmpty 'BecauseMockString' (Get-NullOrEmptyValue)
        }

        It 'Should convert `Should -BeNullOrEmpty -ActualValue $null` correctly' {
            Should -BeNullOrEmpty -ActualValue $null
        }
    }

    Context 'When the tests are negated' {
        It 'Should convert `Should -Not -BeNullOrEmpty` correctly' {
            $null | Should -Not -BeNullOrEmpty
        }

        It 'Should convert `Should -BeNullOrEmpty -Not:$true` correctly' {
            $null | Should -BeNullOrEmpty -Not:$true
        }
    }

    Context 'When tests should always use named parameters' {
        It 'Should convert `Should -BeNullOrEmpty ''BecauseMockString'' $null` correctly' {
            Should -BeNullOrEmpty 'BecauseMockString' $null
        }
    }

    Context 'When tests should always use positional parameters' {
        It 'Should convert `Should -BeNullOrEmpty -Because ''BecauseMockString'' -ActualValue $null` correctly' {
            Should -BeNullOrEmpty -Because 'BecauseMockString' -ActualValue $null
        }
    }
}
