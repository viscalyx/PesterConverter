Describe 'Should -BeFalse' {
    Context 'When the tests are affirming' {
        It 'Should convert `Should -BeFalse` correctly' {
            $false | Should -BeFalse
        }

        It 'Should convert `Should -BeFalse -Because ''BecauseMockString''` correctly' {
            $false | Should -BeFalse -Because 'BecauseMockString'
        }

        It 'Should convert `Should -BeFalse -ActualValue $true -Because ''BecauseMockString''` correctly' {
            Should -BeFalse -ActualValue $false -Because 'BecauseMockString'
        }

        # Test intentionally uses abbreviated parameter name for -ActualValue.
        It 'Should convert `Should -BeFalse -Actual $false -Because ''BecauseMockString''` correctly' {
            Should -BeFalse -Actual $false -Because 'BecauseMockString'
        }

        It 'Should convert `Should -BeFalse ''BecauseMockString''` correctly' {
            $true | Should -BeFalse 'BecauseMockString'
        }

        It 'Should convert `Should -BeFalse ''BecauseMockString'' $false` correctly' {
            Should -BeFalse 'BecauseMockString' $false
        }

        It 'Should convert `Should -Not:$false -BeFalse ''BecauseMockString'' $false` correctly' {
            Should -Not:$false -BeFalse 'BecauseMockString' $false
        }

        It 'Should convert `Should -BeFalse -ActualValue $false ''BecauseMockString''` correctly' {
            Should -BeFalse -ActualValue $false 'BecauseMockString'
        }

        It 'Should convert `Should -BeFalse ''BecauseMockString'' -ActualValue $false` correctly' {
            Should -BeFalse 'BecauseMockString' -ActualValue $false
        }

        It 'Should convert `Should -BeFalse -Because ''BecauseMockString'' $false` correctly' {
            Should -BeFalse -Because 'BecauseMockString' $false
        }

        It 'Should convert `Should -BeFalse $false -Because ''BecauseMockString''` correctly' {
            Should -BeFalse $false -Because 'BecauseMockString'
        }

        It 'Should convert `Should -BeFalse ''BecauseMockString'' (Get-BooleanValue)` correctly' {
            function Get-BooleanValue
            {
                return $false
            }

            Should -BeFalse 'BecauseMockString' (Get-BooleanValue)
        }

        It 'Should convert `Should -BeFalse -ActualValue $false` correctly' {
            Should -BeFalse -ActualValue $false
        }
    }

    Context 'When the tests are negated' {
        It 'Should convert `Should -Not -BeFalse` correctly' {
            $true | Should -Not -BeFalse
        }

        It 'Should convert `Should -BeFalse -Not:$true` correctly' {
            $true | Should -BeFalse -Not:$true
        }
    }

    Context 'When tests should always use named parameters' {
        It 'Should convert `Should -BeFalse ''BecauseMockString'' $true` correctly' {
            Should -BeFalse 'BecauseMockString' $false
        }
    }

    Context 'When tests should always use positional parameters' {
        It 'Should convert `Should -BeFalse -Because ''BecauseMockString'' -ActualValue $true` correctly' {
            Should -BeFalse -Because 'BecauseMockString' -ActualValue $false
        }
    }
}
