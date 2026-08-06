[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
param ()

BeforeAll {
    $script:moduleName = 'PesterConverter'

    Import-Module -Name $script:moduleName

    $PSDefaultParameterValues['InModuleScope:ModuleName'] = $script:moduleName
    $PSDefaultParameterValues['Mock:ModuleName'] = $script:moduleName
    $PSDefaultParameterValues['Should:ModuleName'] = $script:moduleName
}

AfterAll {
    $PSDefaultParameterValues.Remove('InModuleScope:ModuleName')
    $PSDefaultParameterValues.Remove('Mock:ModuleName')
    $PSDefaultParameterValues.Remove('Should:ModuleName')

    # Unload the module being tested so that it doesn't impact any other tests.
    Get-Module -Name $script:moduleName -All | Remove-Module -Force
}

Describe 'Get-ExtentText' {
    Context 'When the CommandAst is missing a property TextWithConvertedChild' {
        It 'returns the correct extent text' {
            InModuleScope -ScriptBlock {
                $mockCommandAst = {
                    Get-Process -Name 'powershell'
                }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                $result = Get-ExtentText -CommandAst $mockCommandAst
                $result | Should -Be "Get-Process -Name 'powershell'"
            }
        }
    }

    Context 'When the CommandAst has a property TextWithConvertedChild' {
        It 'returns the correct extent text' {
            InModuleScope -ScriptBlock {
                $mockCommandAst = {
                    Get-Process -Name 'powershell'
                }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                $mockCommandAst.Extent | Add-Member -MemberType NoteProperty -Name 'TextWithConvertedChild' -Value 'Mock Child Extent' -Force

                $result = Get-ExtentText -CommandAst $mockCommandAst
                $result | Should -Be 'Mock Child Extent'
            }
        }
    }
}
