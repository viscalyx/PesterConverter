[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
param ()

BeforeDiscovery {
    try
    {
        if (-not (Get-Module -Name 'DscResource.Test'))
        {
            # Assumes dependencies has been resolved, so if this module is not available, run 'noop' task.
            if (-not (Get-Module -Name 'DscResource.Test' -ListAvailable))
            {
                # Redirect all streams to $null, except the error stream (stream 2)
                & "$PSScriptRoot/../../../build.ps1" -Tasks 'noop' 2>&1 4>&1 5>&1 6>&1 > $null
            }

            # If the dependencies has not been resolved, this will throw an error.
            Import-Module -Name 'DscResource.Test' -Force -ErrorAction 'Stop'
        }
    }
    catch [System.IO.FileNotFoundException]
    {
        throw 'DscResource.Test module dependency not found. Please run ".\build.ps1 -ResolveDependency -Tasks build" first.'
    }
}

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
