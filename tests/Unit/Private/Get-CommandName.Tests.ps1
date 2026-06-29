[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
param ()

BeforeAll {
    $script:dscModuleName = 'PesterConverter'

    Import-Module -Name $script:dscModuleName

    $PSDefaultParameterValues['InModuleScope:ModuleName'] = $script:dscModuleName
    $PSDefaultParameterValues['Mock:ModuleName'] = $script:dscModuleName
    $PSDefaultParameterValues['Should:ModuleName'] = $script:dscModuleName
}

AfterAll {
    $PSDefaultParameterValues.Remove('InModuleScope:ModuleName')
    $PSDefaultParameterValues.Remove('Mock:ModuleName')
    $PSDefaultParameterValues.Remove('Should:ModuleName')

    # Unload the module being tested so that it doesn't impact any other tests.
    Get-Module -Name $script:dscModuleName -All | Remove-Module -Force
}

Describe 'Get-CommandName' {
    Context 'When the command element is a StringConstantExpressionAst' {
        It 'returns the command name from the value property' {
            InModuleScope -ScriptBlock {
                $mockCommandAst = {
                    Get-Process -Name 'powershell'
                }.Ast.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

                $result = Get-CommandName -CommandAst $mockCommandAst
                $result | Should -Be 'Get-Process'
            }
        }
    }
}
