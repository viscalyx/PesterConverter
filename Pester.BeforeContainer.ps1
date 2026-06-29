Write-Information -MessageData 'Invoking Pester.BeforeContainer.' -InformationAction 'Continue'

try
{
    if (-not (Get-Module -Name 'DscResource.Test'))
    {
        # Assumes dependencies has been resolved, so if this module is not available, run 'noop' task.
        if (-not (Get-Module -Name 'DscResource.Test' -ListAvailable))
        {
            # Redirect all streams to $null, except the error stream (stream 2)
            & "$PSScriptRoot/build.ps1" -Tasks 'noop' 2>&1 4>&1 5>&1 6>&1 > $null
        }

        # If the dependencies has not been resolved, this will throw an error.
        Import-Module -Name 'DscResource.Test' -Force -ErrorAction 'Stop'
    }
}
catch [System.IO.FileNotFoundException]
{
    throw 'DscResource.Test module dependency not found. Please run ".\build.ps1 -ResolveDependency -Tasks build" first.'
}

Write-Information -MessageData 'Successfully invoked Pester.BeforeContainer.' -InformationAction 'Continue'

# BeforeDiscovery {
#     Write-Information -MessageData 'Invoking Pester.BeforeContainer BeforeDiscover-block.' -InformationAction 'Continue'

#     try
#     {
#         if (-not (Get-Module -Name 'DscResource.Test'))
#         {
#             # Assumes dependencies has been resolved, so if this module is not available, run 'noop' task.
#             if (-not (Get-Module -Name 'DscResource.Test' -ListAvailable))
#             {
#                 # Redirect all streams to $null, except the error stream (stream 2)
#                 & "$PSScriptRoot/build.ps1" -Tasks 'noop' 2>&1 4>&1 5>&1 6>&1 > $null
#             }

#             # If the dependencies has not been resolved, this will throw an error.
#             Import-Module -Name 'DscResource.Test' -Force -ErrorAction 'Stop'
#         }
#     }
#     catch [System.IO.FileNotFoundException]
#     {
#         throw 'DscResource.Test module dependency not found. Please run ".\build.ps1 -ResolveDependency -Tasks build" first.'
#     }

#     Write-Information -MessageData 'Successfully invoked Pester.BeforeContainer BeforeDiscover-block.' -InformationAction 'Continue'
# }

# BeforeAll {
#     Write-Information -MessageData 'Invoking Pester.BeforeContainer BeforeAll-block.' -InformationAction 'Continue'

#     $script:dscModuleName = 'PesterConverter'

#     Import-Module -Name $script:dscModuleName

#     $PSDefaultParameterValues['InModuleScope:ModuleName'] = $script:dscModuleName
#     $PSDefaultParameterValues['Mock:ModuleName'] = $script:dscModuleName
#     $PSDefaultParameterValues['Should-Invoke:ModuleName'] = $script:dscModuleName
#     $PSDefaultParameterValues['Should-NotInvoke:ModuleName'] = $script:dscModuleName

#     Write-Information -MessageData 'Successfully invoked Pester.BeforeContainer BeforeAll-block.' -InformationAction 'Continue'
# }

# AfterAll {
#     Write-Information -MessageData 'Invoking Pester.BeforeContainer AfterAll-block.' -InformationAction 'Continue'

#     $PSDefaultParameterValues.Remove('InModuleScope:ModuleName')
#     $PSDefaultParameterValues.Remove('Mock:ModuleName')
#     $PSDefaultParameterValues.Remove('Should-Invoke:ModuleName')
#     $PSDefaultParameterValues.Remove('Should-NotInvoke:ModuleName')

#     # Unload the module being tested so that it doesn't impact any other tests.
#     Get-Module -Name $script:dscModuleName -All | Remove-Module -Force

#     Write-Information -MessageData 'Successfully invoked Pester.BeforeContainer AfterAll-block.' -InformationAction 'Continue'
# }
