Describe 'Should -Invoke' {
    BeforeAll {
        function TestCommand
        {
            param
            (
                [Parameter()]
                [System.String]
                $Path
            )

            Write-Verbose -Message "TestCommand called with Path: $Path"
        }

        function Get-Something {
            param
            (
                [Parameter()]
                [System.String]
                $Path
            )

            TestCommand -Path $Path
        }

        # Mock the TestCommand for all tests
        Mock -CommandName 'TestCommand'
    }

    Context 'When the tests are affirming' {
        It 'Should convert `Should -Invoke` using default settings correctly' {
            Get-Something -Path 'test.txt'

            Should -Invoke -CommandName 'TestCommand' -Times 1
        }

        It 'Should convert `Should -Invoke` with ParameterFilter correctly' {
            Get-Something -Path 'test.txt'

            Should -Invoke -CommandName 'TestCommand' -ParameterFilter { $Path -eq 'test.txt' }
        }

        It 'Should convert `Should -Invoke` with Times and Exactly correctly' {
            1..3 | ForEach-Object { Get-Something -Path 'test.txt' }

            Should -Invoke -CommandName 'TestCommand' -Times 3 -Exactly
        }

        It 'Should convert `Should -Invoke` with Scope correctly' {
            Get-Something -Path 'test.txt'

            Should -Invoke -CommandName 'TestCommand' -Scope 'It'
        }

        It 'Should convert `Should -Invoke` with Because correctly' {
            Get-Something -Path 'test.txt'

            Should -Invoke -CommandName 'TestCommand' -Because 'Command should be called'
        }

        It 'Should convert `Should -Invoke` with all parameters correctly' {
            1..3 | ForEach-Object { Get-Something -Path 'test.txt' }

            Should -Invoke -CommandName 'TestCommand' `
                -Times 3 `
                -Exactly `
                -ParameterFilter { $Path -eq 'test.txt' } `
                -Scope 'It' `
                -Because 'Command should be called exactly 3 times'
        }

        It 'Should convert `Should -Invoke` using positional parameters correctly' {
            1..3 | ForEach-Object { Get-Something -Path 'test.txt' }

            Should -Invoke 'TestCommand' 3 { $Path -eq 'test.txt' }
        }
    }

    Context 'When the tests are negated' {
        It 'Should convert `Should -Not -Invoke` correctly' {
            Should -Not -Invoke -CommandName 'TestCommand'
        }

        It 'Should convert `Should -Not -Invoke` with ParameterFilter correctly' {
            Should -Not -Invoke -CommandName 'TestCommand' -ParameterFilter { $Path -eq 'test.txt' }
        }

        It 'Should convert `Should -Not -Invoke` with Scope correctly' {
            Should -Not -Invoke -CommandName 'TestCommand' -Scope 'It'
        }

        It 'Should convert `Should -Not -Invoke` with Because correctly' {
            Should -Not -Invoke -CommandName 'TestCommand' -Because 'Command should not be called'
        }

        It 'Should convert `Should -Not -Invoke` with all parameters correctly' {
            Should -Not -Invoke -CommandName 'TestCommand' `
                -ParameterFilter { $Path -eq 'test.txt' } `
                -Scope 'It' `
                -Because 'Command should not be called'
        }

        It 'Should convert `Should -Not -Invoke` using positional parameters correctly' {
            Should -Not -Invoke 'TestCommand' 1 { $Path -eq 'test.txt' }
        }
    }
}
