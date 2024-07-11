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

Describe 'Convert-PesterSyntax' {
    BeforeAll {
        $mockAstExtentText = {
            Describe 'Should -Be' {
                It 'Should -Be using pipeline' {
                    $true | Should -Be $true -Because 'BecauseString'
                }
            }
        }.Ast.GetScriptBlock().ToString()

        $mockScriptFilePath = Join-Path -Path $TestDrive -ChildPath 'Mock.Tests.ps1'

        Set-Content -Path $mockScriptFilePath -Value $mockAstExtentText -Encoding 'utf8'

        # Save current ProgressPreference and then set it to SilentlyContinue
        $script:originalProgressPreference = $ProgressPreference
        $script:ProgressPreference = 'SilentlyContinue'
    }

    AfterAll {
        # Restore the original ProgressPreference
        $script:ProgressPreference = $script:originalProgressPreference
    }

    It 'Should return the correct converted script' {
        $mockExpectedConvertedScript = {
            Describe 'Should -Be' {
                It 'Should -Be using pipeline' {
                    $true | Should-Be $true -Because 'BecauseString'
                }
            }
        }.Ast.GetScriptBlock().ToString()

        $result = Convert-PesterSyntax -Path $mockScriptFilePath -PassThru

        $result | Should-BeString -CaseSensitive -Expected $mockExpectedConvertedScript -TrimWhitespace
    }

    It 'Should return the correct converted script using named parameters' {
        $mockExpectedConvertedScript = {
            Describe 'Should -Be' {
                It 'Should -Be using pipeline' {
                    $true | Should-Be -Because 'BecauseString' -Expected $true
                }
            }
        }.Ast.GetScriptBlock().ToString()

        $result = Convert-PesterSyntax -Path $mockScriptFilePath -UseNamedParameters -PassThru

        $result | Should-BeString -CaseSensitive -Expected $mockExpectedConvertedScript -TrimWhitespace
    }

    It 'Should return the correct converted script using positional parameters' {
        $mockExpectedConvertedScript = {
            Describe 'Should -Be' {
                It 'Should -Be using pipeline' {
                    $true | Should-Be $true -Because 'BecauseString'
                }
            }
        }.Ast.GetScriptBlock().ToString()

        $result = Convert-PesterSyntax -Path $mockScriptFilePath -UsePositionalParameters -PassThru

        $result | Should-BeString -CaseSensitive -Expected $mockExpectedConvertedScript -TrimWhitespace
    }
}
