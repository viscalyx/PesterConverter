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

Describe 'ConvertTo-ActualParameterName' {
    It 'Should return the correct parameter name for a valid abbreviation' {
        InModuleScope -ScriptBlock {
            $result = ConvertTo-ActualParameterName -CommandName 'Should' -NamedParameter 'Actual'

            $result | Should-Be 'ActualValue'
        }
    }

    It 'Should return the correct parameter name for a actual name' {
        InModuleScope -ScriptBlock {
            $result = ConvertTo-ActualParameterName -CommandName 'Should' -NamedParameter 'Be'

            $result | Should-Be 'Be'
        }
    }

    It 'Should throw an error for ambiguous parameter names' {
        InModuleScope -ScriptBlock {
            $mockErrorMessage = $script:localizedData.AmbiguousNamedParameter -f 'BeL', 'Should'

            {
                # Would return BeLessOrEqual, BeLessThan, BeLike, BeLikeExactly which is ambiguous for "BeL".
                ConvertTo-ActualParameterName -CommandName 'Should' -NamedParameter 'BeL'
            } | Should-Throw -ExceptionMessage $mockErrorMessage
        }
    }

    It 'Should throw an error for invalid command names' {
        InModuleScope -ScriptBlock {
            {
                ConvertTo-ActualParameterName -CommandName 'InvalidCommand' -NamedParameter 'Actual'
            } | Should-Throw
        }
    }

    It 'Should return an empty result for non-matching parameter names' {
        InModuleScope -ScriptBlock {
            $mockErrorMessage = $script:localizedData.UnknownNamedParameter -f 'NonExistent', 'Should'

            {
                ConvertTo-ActualParameterName -CommandName 'Should' -NamedParameter 'NonExistent'
            } | Should-Throw -ExceptionMessage $mockErrorMessage

            $result | Should-BeNull
        }
    }
}
