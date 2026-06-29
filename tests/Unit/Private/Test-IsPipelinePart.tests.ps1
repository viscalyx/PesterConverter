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

Describe 'Test-IsPipelinePart' {
    It 'Should return $false for a command that is not part of a pipeline' {
        InModuleScope -ScriptBlock {
            $mockCommandAstPester5 = {
                Should -BeIn @('ExpectedValue1', 'ExpectedValue2') 'BecauseString'
            }.Ast.FindAll({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

            $result = Test-IsPipelinePart -CommandAst $mockCommandAstPester5[0]

            $result | Should-BeFalse
        }
    }

    It 'Should return $true for a command that is part of a pipeline' {
        InModuleScope -ScriptBlock {
            # Using FindAll() to get the correct AST element we need to pass.
            $mockCommandAstPester5 = {
                'ActualValue' | Get-Something | Should -BeIn @('ExpectedValue1', 'ExpectedValue2') 'BecauseString'
            }.Ast.FindAll({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $false)

            $result = Test-IsPipelinePart -CommandAst $mockCommandAstPester5[1]

            $result | Should-BeTrue
        }
    }
}
