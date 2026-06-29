[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
param ()

BeforeAll {
    $script:dscModuleName = 'PesterConverter'

    Import-Module -Name $script:dscModuleName

    $PSDefaultParameterValues['InModuleScope:ModuleName'] = $script:dscModuleName
    $PSDefaultParameterValues['Mock:ModuleName'] = $script:dscModuleName
    $PSDefaultParameterValues['Should-Invoke:ModuleName'] = $script:dscModuleName
    $PSDefaultParameterValues['Should-NotInvoke:ModuleName'] = $script:dscModuleName
}

AfterAll {
    $PSDefaultParameterValues.Remove('InModuleScope:ModuleName')
    $PSDefaultParameterValues.Remove('Mock:ModuleName')
    $PSDefaultParameterValues.Remove('Should-Invoke:ModuleName')
    $PSDefaultParameterValues.Remove('Should-NotInvoke:ModuleName')

    # Unload the module being tested so that it doesn't impact any other tests.
    Get-Module -Name $script:dscModuleName -All | Remove-Module -Force
}

Describe 'Get-CommandAst' {
    It 'Should return the correct CommandAst for Should -Be $true' {
        InModuleScope -ScriptBlock {
            $mockAst = {
                Describe 'ShouldBe' {
                    It 'Should be true' {
                        $true | Should -Be $true
                    }
                }
            }.Ast

            $result = Get-CommandAst -Ast $mockAst -CommandName 'Should'

            $result | Should-HaveType ([System.Management.Automation.Language.CommandAst])
            $result.CommandElements[0].Value | Should-Be 'Should'
            $result.CommandElements[0].Extent.Text | Should-Be 'Should'

            $result.CommandElements[1].ParameterName | Should-Be 'Be'
            $result.CommandElements[1].Extent.Text | Should-Be '-Be'

            $result.CommandElements[2].Extent.Text | Should-Be '$true'
        }
    }

    It 'Should return the correct CommandAst for Should -BeTrue' {
        InModuleScope -ScriptBlock {
            $mockAst = {
                Describe 'ShouldBe' {
                    It 'Should be true' {
                        $true | Should -BeTrue
                    }
                }
            }.Ast

            $result = Get-CommandAst -Ast $mockAst -CommandName 'Should'

            $result | Should-HaveType ([System.Management.Automation.Language.CommandAst])
            $result.CommandElements[0].Value | Should-Be 'Should'
            $result.CommandElements[0].Extent.Text | Should-Be 'Should'

            $result.CommandElements[1].ParameterName | Should-Be 'BeTrue'
            $result.CommandElements[1].Extent.Text | Should-Be '-BeTrue'

            $result.CommandElements[2].Extent.Text | Should-BeNull
        }
    }

    It 'Should return the correct CommandAst''s when there are multiple Should' {
        InModuleScope -ScriptBlock {
            $mockAst = {
                Describe 'ShouldBe' {
                    It 'Should be true' {
                        $true | Should -BeTrue
                    }

                    It 'Should be false' {
                        $true | Should -BeFalse
                    }
                }
            }.Ast

            $result = Get-CommandAst -Ast $mockAst -CommandName 'Should'

            $result.Count | Should-Be 2

            $result | Should-All { $_ | Should-HaveType ([System.Management.Automation.Language.CommandAst]) }

            # First Should
            $result[0].CommandElements[0].Value | Should-Be 'Should'
            $result[0].CommandElements[0].Extent.Text | Should-Be 'Should'

            $result[0].CommandElements[1].ParameterName | Should-Be 'BeTrue'
            $result[0].CommandElements[1].Extent.Text | Should-Be '-BeTrue'

            $result[0].CommandElements[2].Extent.Text | Should-BeNull

            # Second Should
            $result[1].CommandElements[0].Value | Should-Be 'Should'
            $result[1].CommandElements[0].Extent.Text | Should-Be 'Should'

            $result[1].CommandElements[1].ParameterName | Should-Be 'BeFalse'
            $result[1].CommandElements[1].Extent.Text | Should-Be '-BeFalse'

            $result[1].CommandElements[2].Extent.Text | Should-BeNull
        }
    }
}
