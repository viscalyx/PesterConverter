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
    Context 'When using Should command' {
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

    Context 'When using Assert-MockCalled command' {
        It 'Should return the correct parameter name for a valid abbreviation' {
            InModuleScope -ScriptBlock {
                $result = ConvertTo-ActualParameterName -CommandName 'Assert-MockCalled' -NamedParameter 'Param'

                $result | Should -Be 'ParameterFilter'
            }
        }

        It 'Should return the correct parameter name for an exact match' {
            InModuleScope -ScriptBlock {
                $result = ConvertTo-ActualParameterName -CommandName 'Assert-MockCalled' -NamedParameter 'Times'

                $result | Should -Be 'Times'
            }
        }

        It 'Should throw when parameter name is ambiguous' {
            InModuleScope -ScriptBlock {
                $mockErrorMessage = $script:localizedData.AmbiguousNamedParameter -f 'E', 'Assert-MockCalled'

                {
                    # Would return Exactly and ExclusiveFilter which is ambiguous for "E"
                    ConvertTo-ActualParameterName -CommandName 'Assert-MockCalled' -NamedParameter 'E'
                } | Should -Throw -ExpectedMessage $mockErrorMessage
            }
        }
    }

    Context 'When using null or empty values' {
        It 'Should throw when NamedParameter is empty' {
            InModuleScope -ScriptBlock {
                $mockErrorMessage = $script:localizedData.UnknownNamedParameter -f '', 'Should'

                {
                    ConvertTo-ActualParameterName -CommandName 'Should' -NamedParameter ''
                } | Should -Throw -ExpectedMessage $mockErrorMessage
            }
        }

        It 'Should throw when NamedParameter contains only whitespace' {
            InModuleScope -ScriptBlock {
                $mockErrorMessage = $script:localizedData.UnknownNamedParameter -f '   ', 'Should'

                {
                    ConvertTo-ActualParameterName -CommandName 'Should' -NamedParameter '   '
                } | Should -Throw -ExpectedMessage $mockErrorMessage
            }
        }
    }
}
