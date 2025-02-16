BeforeDiscovery {
    $pesterVersion = (Get-Module -Name Pester).Version

    if ($pesterVersion -ge '6.0.0')
    {
        return
    }
}

Describe 'Assert-MockCalled' {
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
        It 'Should convert Assert-MockCalled using default settings correctly' {
            Get-Something -Path 'test.txt'

            Assert-MockCalled -CommandName 'TestCommand' -Times 1
        }

        It 'Should convert Assert-MockCalled with ParameterFilter correctly' {
            Get-Something -Path 'test.txt'

            Assert-MockCalled -CommandName 'TestCommand' -ParameterFilter { $Path -eq 'test.txt' }
        }

        It 'Should convert Assert-MockCalled with Times and Exactly correctly' {
            1..3 | ForEach-Object { Get-Something -Path 'test.txt' }

            Assert-MockCalled -CommandName 'TestCommand' -Times 3 -Exactly
        }

        It 'Should convert Assert-MockCalled with Scope correctly' {
            Get-Something -Path 'test.txt'

            Assert-MockCalled -CommandName 'TestCommand' -Scope 'It'
        }

        It 'Should convert Assert-MockCalled with all parameters correctly' {
            1..3 | ForEach-Object { Get-Something -Path 'test.txt' }

            Assert-MockCalled -CommandName 'TestCommand' `
                -Times 3 `
                -Exactly `
                -ParameterFilter { $Path -eq 'test.txt' } `
                -Scope 'It'
        }

        It 'Should convert Assert-MockCalled using positional parameters correctly' {
            1..3 | ForEach-Object { Get-Something -Path 'test.txt' }

            Assert-MockCalled 'TestCommand' 3 { $Path -eq 'test.txt' }
        }
    }

    Context 'When the tests are negated' {
        It 'Should convert Assert-MockCalled with Times 0 correctly' {
            Assert-MockCalled -CommandName 'TestCommand' -Times 0
        }

        It 'Should convert Assert-MockCalled with Times 0 and ParameterFilter correctly' {
            Assert-MockCalled -CommandName 'TestCommand' -Times 0 -ParameterFilter { $Path -eq 'test.txt' }
        }

        It 'Should convert Assert-MockCalled with Times 0 and Scope correctly' {
            Assert-MockCalled -CommandName 'TestCommand' -Times 0 -Scope 'It'
        }

        It 'Should convert Assert-MockCalled with Times 0 and all parameters correctly' {
            Assert-MockCalled -CommandName 'TestCommand' `
                -Times 0 `
                -ParameterFilter { $Path -eq 'test.txt' } `
                -Scope 'It'
        }

        It 'Should convert Assert-MockCalled with Times 0 using positional parameters correctly' {
            Assert-MockCalled 'TestCommand' 0 { $Path -eq 'test.txt' }
        }
    }
}
