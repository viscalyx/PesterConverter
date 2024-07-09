@{
    # Script module or binary module file associated with this manifest.
    RootModule           = 'PesterConverter.psm1'

    # Version number of this module.
    ModuleVersion        = '0.0.1'

    # ID used to uniquely identify this module
    GUID                 = 'aba638ad-a584-4234-8eaa-48691b21be2f'

    # Author of this module
    Author               = 'Viscalyx' # cSpell: ignore Viscalyx

    # Company or vendor of this module
    CompanyName          = 'Viscalyx'

    # Copyright statement for this module
    Copyright            = '(c) Viscalyx. All rights reserved.'

    # Description of the functionality provided by this module
    Description          = 'Commands ta convert Pester tests syntax.'

    # Minimum version of the PowerShell engine required by this module
    PowerShellVersion    = '7.0'

    # Modules that must be imported into the global environment prior to importing this module
    RequiredModules      = @()

    # Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
    FunctionsToExport    = @()

    # Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
    CmdletsToExport      = @()

    # Variables to export from this module
    VariablesToExport    = @()

    # Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
    AliasesToExport      = @()

    # DSC resources to export from this module
    DscResourcesToExport = @()

    # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData          = @{
        PSData = @{
            # Tags applied to this module. These help with module discovery in online galleries.
            # Tags = @()

            # A URL to the license for this module.
            # LicenseUri = ''

            # A URL to the main website for this project.
            # ProjectUri = ''

            # A URL to an icon representing this module.
            # IconUri = ''

            # ReleaseNotes of this module
            ReleaseNotes = ''

            # Prerelease string of this module
            Prerelease   = ''

            # Flag to indicate whether the module requires explicit user acceptance for install/update/save
            # RequireLicenseAcceptance = $false

            # External dependent modules of this module
            # ExternalModuleDependencies = @()
        } # End of PSData hashtable
    } # End of PrivateData hashtable
}
