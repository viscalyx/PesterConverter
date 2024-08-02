# TODO: When Pester 6 supports the correct positional parameter for `Should -Throw` this test should be activated.
Describe 'Should -Throw' -Skip:$true {
    Context 'When the tests are affirming' {
        It 'Should convert `Should -Throw -ExceptionType ([System.Exception]) -ErrorId ''MockErrorId'' -Because ''BecauseString'' -ExpectedMessage ''MockErrorMessage'' -ActualValue { Write-Error -Message ''MockErrorMessage'' -ErrorId ''MockErrorId'' -Category ''InvalidOperation'' -TargetObject ''MockTargetObject'' -ErrorAction ''Stop'' }` correctly' {
            Should -Throw -Because 'BecauseString' -ExceptionType ([System.Exception]) -ErrorId 'MockErrorId' -ExpectedMessage 'MockErrorMessage' -ActualValue {
                Write-Error -Message 'MockErrorMessage' -ErrorId 'MockErrorId' -Category 'InvalidOperation' -TargetObject 'MockTargetObject' -ErrorAction 'Stop'
            }
        }

        It 'Should convert `Should -Throw -Because ''BecauseString'' -ExceptionType ([System.Exception]) -ErrorId ''MockErrorId'' -ExpectedMessage ''MockErrorMessage''` correctly' {
            {
                Write-Error -Message 'MockErrorMessage' -ErrorId 'MockErrorId' -Category 'InvalidOperation' -TargetObject 'MockTargetObject' -ErrorAction 'Stop'
            } | Should -Throw -Because 'BecauseString' -ExceptionType ([System.Exception]) -ErrorId 'MockErrorId' -ExpectedMessage 'MockErrorMessage'
        }

        It 'Should convert `$scriptBlock | Should -Throw` correctly' {
            $scriptBlock = { throw 'mock error' }

            $scriptBlock | Should -Throw
        }

        It 'Should convert `{ throw ''myMessage'' } | Should -Throw -Because ''BecauseString''` correctly' {
            { throw 'myMessage' } | Should -Throw -Because 'BecauseString'
        }

        It 'Should convert `{ throw ''myMessage'' } | Should -Throw -Because ''BecauseString'' -ExpectedMessage ''ExpectedString''` correctly' {
            { throw 'myMessage' } |
                Should -Throw -Because 'BecauseString' -ExpectedMessage 'myMessage'
        }

        It 'Should convert `"throw ''five''" | ForEach-Object { [scriptblock]::Create($_) } | Should -Throw -Not` correctly' {
            "throw 'five'" |
                ForEach-Object { [scriptblock]::Create($_) } |
                Should -Throw
        }

        It 'Should convert `Should -Throw ''MockErrorMessage'' ''MockErrorId'' ([System.Exception]) ''BecauseString''` correctly' {
            {
                Write-Error -Message 'MockErrorMessage' -ErrorId 'MockErrorId' -Category 'InvalidOperation' -TargetObject 'MockTargetObject' -ErrorAction 'Stop'
            } | Should -Throw 'MockErrorMessage' 'MockErrorId' ([System.Exception]) 'BecauseString'
        }

        It 'Should convert `Should -Throw ''MockErrorMessage'' ''MockErrorId'' ([System.Exception])` correctly' {
            {
                Write-Error -Message 'MockErrorMessage' -ErrorId 'MockErrorId' -Category 'InvalidOperation' -TargetObject 'MockTargetObject' -ErrorAction 'Stop'
            } | Should -Throw 'MockErrorMessage' 'MockErrorId' ([System.Exception])
        }

        It 'Should convert `Should -Throw ''MockErrorMessage'' ''MockErrorId''` correctly' {
            {
                Write-Error -Message 'MockErrorMessage' -ErrorId 'MockErrorId' -Category 'InvalidOperation' -TargetObject 'MockTargetObject' -ErrorAction 'Stop'
            } | Should -Throw 'MockErrorMessage' 'MockErrorId'
        }

        It 'Should convert `Should -Throw ''MockErrorMessage''` correctly' {
            {
                Write-Error -Message 'MockErrorMessage' -ErrorId 'MockErrorId' -Category 'InvalidOperation' -TargetObject 'MockTargetObject' -ErrorAction 'Stop'
            } | Should -Throw 'MockErrorMessage'
        }
    }
}
