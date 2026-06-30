Import-Module PesterConverter -Force
Convert-PesterSyntax -Path 'tests/Integration/Syntax/v5/ShouldInvoke.Debug.v5.tests.ps1' -Pester6 -Verbose -PassThru
