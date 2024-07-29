Describe 'Should -BeIn' {
    Context 'When the tests are affirming' {
        It 'Should convert `Should -BeIn @(''ExpectedValue1'', ''ExpectedValue2'') ''BecauseString'' ''ExpectedValue2''` correctly' {
            Should -BeIn @('ExpectedValue1', 'ExpectedValue2') 'BecauseString' 'ExpectedValue2'
        }

        It 'Should convert `Should -BeIn @(''ExpectedValue1'', ''ExpectedValue2'') -Because ''BecauseString'' ''ExpectedValue2''` correctly' {
            Should -BeIn @('ExpectedValue1', 'ExpectedValue2') -Because 'BecauseString' 'ExpectedValue2'
        }

        It 'Should convert `Should -BeIn -ExpectedValue @(''ExpectedValue1'', ''ExpectedValue2'') -Because ''BecauseString'' ''ExpectedValue2''` correctly' {
            Should -BeIn -ExpectedValue @('ExpectedValue1', 'ExpectedValue2') -Because 'BecauseString' 'ExpectedValue2'
        }

        It 'Should convert `Should -BeIn -ExpectedValue @(''ExpectedValue1'', ''ExpectedValue2'') -Because ''BecauseString'' -ActualValue ''ExpectedValue2''` correctly' {
            Should -BeIn -ExpectedValue @('ExpectedValue1', 'ExpectedValue2') -Because 'BecauseString' -ActualValue 'ExpectedValue2'
        }

        It 'Should convert `''ExpectedValue2'' | Should -BeIn @(''ExpectedValue1'', ''ExpectedValue2'') -Because ''BecauseString''` correctly' {
            'ExpectedValue2' | Should -BeIn @('ExpectedValue1', 'ExpectedValue2') -Because 'BecauseString'
        }

        It 'Should convert `''ExpectedValue2'' | Should -BeIn -Because ''BecauseString'' -ExpectedValue @(''ExpectedValue1'', ''ExpectedValue2'')` correctly' {
            'ExpectedValue2' | Should -BeIn -Because 'BecauseString' -ExpectedValue @('ExpectedValue1', 'ExpectedValue2')
        }

        It 'Should convert `''ExpectedValue2'' | Should -BeIn @(''ExpectedValue1'', ''ExpectedValue2'')` correctly' {
            'ExpectedValue2' | Should -BeIn @('ExpectedValue1', 'ExpectedValue2')
        }
    }

    Context 'When the tests are negated' {
        It 'Should convert `Should -Not -BeIn @(''ExpectedValue1'', ''ExpectedValue2'') ''BecauseString'' ''ActualValue''` correctly' {
            Should -Not -BeIn @('ExpectedValue1', 'ExpectedValue2') 'BecauseString' 'ActualValue'
        }
    }

    Context 'When tests should always use named parameters' {
        It 'Should convert `Should -BeIn @(''ExpectedValue1'', ''ExpectedValue2'') ''BecauseString'' ''ExpectedValue2''` correctly' {
            Should -BeIn @('ExpectedValue1', 'ExpectedValue2') 'BecauseString' 'ExpectedValue2'
        }

        It 'Should convert `''ExpectedValue2'' | Should -BeIn @(''ExpectedValue1'', ''ExpectedValue2'') ''BecauseString''` correctly' {
            'ExpectedValue2' | Should -BeIn @('ExpectedValue1', 'ExpectedValue2') 'BecauseString'
        }

        It 'Should convert `''ExpectedValue2'' | Get-Something | Should -BeIn @(''ExpectedValue1'', ''ExpectedValue2'') ''BecauseString''` correctly' {
            function Get-Something
            {
                [CmdletBinding()]
                param
                (
                    [Parameter(ValueFromPipeline = $true)]
                    [System.String]
                    $InputString
                )

                process
                {
                    Write-Output $InputString
                }
            }

            'ExpectedValue2' | Get-Something | Should -BeIn @('ExpectedValue1', 'ExpectedValue2') 'BecauseString'
        }
    }

    Context 'When tests should always use positional parameters' {
        Context 'When the tests are affirming' {
            It 'Should convert `Should -BeIn -ExpectedValue @(''ExpectedValue1'', ''ExpectedValue2'') -Because ''BecauseString'' -ActualValue ''ExpectedValue2''` correctly' {
                Should -BeIn -ExpectedValue @('ExpectedValue1', 'ExpectedValue2') -Because 'BecauseString' -ActualValue 'ExpectedValue2'
            }

            It 'Should convert `''ExpectedValue2'' | Should -BeIn -Because ''BecauseString'' -ExpectedValue @(''ExpectedValue1'', ''ExpectedValue2'')` correctly' {
                'ExpectedValue2' | Should -BeIn -Because 'BecauseString' -ExpectedValue @('ExpectedValue1', 'ExpectedValue2')
            }
        }

        Context 'When the tests are negated' {
            It 'Should convert `Should -Not -BeIn -ExpectedValue @(''ExpectedValue1'', ''ExpectedValue2'') -Because ''BecauseString'' -ActualValue ''ActualValue''` correctly' {
                Should -Not -BeIn -ExpectedValue @('ExpectedValue1', 'ExpectedValue2') -Because 'BecauseString' -ActualValue 'ActualValue'
            }

            It 'Should convert `''ActualValue'' | Should -Not -BeIn -Because ''BecauseString'' -ExpectedValue @(''ExpectedValue1'', ''ExpectedValue2'')` correctly' {
                'ActualValue' | Should -Not -BeIn -Because 'BecauseString' -ExpectedValue @('ExpectedValue1', 'ExpectedValue2')
            }
        }
    }
}
