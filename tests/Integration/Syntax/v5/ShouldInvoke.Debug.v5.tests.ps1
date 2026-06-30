It 'Should convert `Should -Invoke` even if it has another `Should` in its extent' {
    InModuleScope -Parameters $_ -ScriptBlock {
        1..3 | ForEach-Object { Get-Something -Path 'test.txt' }

        Should -Invoke -CommandName TestCommand -ParameterFilter {
            'a' | Should -MatchExactly 'a'

            # Return $true if the assert above does not throw.
            $true
        } -Exactly -Times 1 -Scope It
    }
}
