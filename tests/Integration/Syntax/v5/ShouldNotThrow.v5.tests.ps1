Describe 'Should -Not -Throw' {
    Context 'When the tests are negated' {
        It 'Should convert `Should -Not -Throw -ExceptionType ([System.Exception]) -ErrorId ''MockErrorId'' -Because ''BecauseString'' -ExpectedMessage ''MockErrorMessage'' -ActualValue { $null = 1 + 1 }` correctly' {
            Should -Not -Throw -Because 'BecauseString' -ExceptionType ([System.Exception]) -ErrorId 'MockErrorId' -ExpectedMessage 'MockErrorMessage' -ActualValue {
                $null = 1 + 1
            }
        }

        It 'Should convert `{ $null = 1 + 1 } | Should -Not -Throw -ExceptionType ([System.Exception]) -ErrorId ''MockErrorId'' -Because ''BecauseString'' -ExpectedMessage ''MockErrorMessage''` correctly' {
            {
                $null = 1 + 1
            } | Should -Not -Throw -Because 'BecauseString' -ExceptionType ([System.Exception]) -ErrorId 'MockErrorId' -ExpectedMessage 'MockErrorMessage'
        }

        It 'Should convert `$scriptBlock | Should -Not -Throw` correctly' {
            $scriptBlock = {
                $null = 1 + 1
            }

            $scriptBlock | Should -Not -Throw
        }

        It 'Should convert `{ $null = 1 + 1 } | Should -Not -Throw -Because ''BecauseString''` correctly' {
            # Intentionally having everything on one line to test the conversion.
            { $null = 1 + 1 } | Should -Not -Throw -Because 'BecauseString'
        }

        It 'Should convert `{ $null = 1 + 1 } | Should -Not -Throw -Because ''BecauseString'' -ExpectedMessage ''ExpectedString''` correctly' {
            # Intentionally splitting over two lines to test the conversion.
            { $null = 1 + 1 } |
                Should -Not -Throw -Because 'BecauseString' -ExpectedMessage 'ExpectedString'
        }

        It 'Should convert `''$null = 1 + 1'' | ForEach-Object { [scriptblock]::Create($_) } | Should -Throw -Not` correctly' {
            # Intentionally splitting over three lines to test the conversion.
            '$null = 1 + 1' |
                ForEach-Object { [scriptblock]::Create($_) } |
                Should -Throw -Not
        }
    }
}
