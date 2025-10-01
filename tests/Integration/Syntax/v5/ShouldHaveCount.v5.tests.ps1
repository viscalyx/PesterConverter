Describe 'Should -HaveCount' {
    Context 'When the tests are affirming' {
        It 'Should convert `Should -HaveCount 2` correctly' {
            @(1, 2) | Should -HaveCount 2
        }

        It 'Should convert `Should -HaveCount $numericValue` correctly' {
            $numericValue = 2

            @(1, 2) | Should -HaveCount $numericValue
        }

        It 'Should convert `Should -Not:$false -HaveCount 2` correctly' {
            @(1, 2) | Should -Not:$false -HaveCount 2
        }

        It 'Should convert `Should -HaveCount (Get-Something)` correctly' {
            function Get-Something
            {
                return 2
            }

            @(1, 2) | Should -HaveCount (Get-Something)
        }
    }

    Context 'When the tests are negated' {
        It 'Should convert `Should -Not -HaveCount 1` correctly' {
            @(1, 2) | Should -Not -HaveCount 1
        }

        It 'Should convert `Should -HaveCount 1 -Not` correctly' {
            @(1, 2) | Should -HaveCount 1 -Not
        }

        It 'Should convert `Should -Not -HaveCount $anyValue` correctly' {
            $anyValue = 1

            @(1, 2) | Should -Not -HaveCount $anyValue
        }

        It 'Should convert `Should -Not:$true -HaveCount 1` correctly' {
            @(1, 2) | Should -Not:$true -HaveCount 1
        }
    }
}
