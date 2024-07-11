<#
    .SYNOPSIS
        Converts the syntax of a file to the syntax of a newer Pester version.

    .DESCRIPTION
        The Convert-PesterSyntax command is used to convert the syntax of a file to
        the syntax of a newer Pester version.. It supports converting to Pester 6 format.

    .PARAMETER Path
        Specifies the path of the file(s) to be converted. This parameter is mandatory
        and accepts a string or a FileInfo object.

    .PARAMETER Pester6
        Specifies that the syntax to convert to is Pester 6. This parameter is
        mandatory to convert to Pester 6 syntax.

    .PARAMETER UseNamedParameters
        Specifies whether to use named parameters in the converted syntax.

    .PARAMETER UsePositionalParameters
        Specifies whether to use positional parameters in the converted syntax,
        where supported.

    .PARAMETER Force
        Specifies that the file should be created without any confirmation.

    .PARAMETER PassThru
        Returns the script after converting the syntax. This parameter is most
        useful when passing in a single file to convert. If multiple files are
        passed in, the script of all the files will be returned as an array.
        If PassThru is specified, no file will not be modified.

    .EXAMPLE
        Convert-PesterSyntax -Path "C:\Scripts\Test.ps1" -Pester6

        Converts the syntax of the Test.ps1 file to Pester 6 syntax.

    .EXAMPLE
        Get-ChildItem -Path "C:\Scripts" -Recurse -Filter "*.ps1" | Convert-PesterSyntax

        Converts the syntax of all PowerShell files in the C:\Scripts directory and
        its subdirectories to the default (newest) Pester syntax.
#>

function Convert-PesterSyntax
{
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidMultipleTypeAttributes', '', Justification = 'We want to pass in both strings and FileInfo objects to parameter Path.')]
    [CmdletBinding(DefaultParameterSetName = 'Pester6', SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [System.String[]]
        [System.IO.FileInfo[]]
        $Path,

        [Parameter(ParameterSetName = 'Pester6')]
        [System.Management.Automation.SwitchParameter]
        $Pester6,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $UseNamedParameters,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $UsePositionalParameters,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $Force,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $PassThru
    )

    begin
    {
        if (($Force.IsPresent -and -not $Confirm) -or $PassThru.IsPresent)
        {
            $ConfirmPreference = 'None'
        }

        $assertBoundParameterParameters = @{
            BoundParameterList     = $PSBoundParameters
            MutuallyExclusiveList1 = @('UseNamedParameters')
            MutuallyExclusiveList2 = @('UsePositionalParameters')
        }

        Assert-BoundParameter @assertBoundParameterParameters

        $convertParameters = @{} + $PSBoundParameters
        $convertParameters.Remove('Path')
        $convertParameters.Remove('Force')
        $convertParameters.Remove('PassThru')

        if ($PSCmdlet.ParameterSetName -eq 'Pester6' -and -not $Pester6.IsPresent)
        {
            $Pester6 = $true
            $convertParameters.Pester6 = $true
        }

        if ($Pester6)
        {
            Write-Verbose 'Converting to Pester 6 syntax.'
        }
        else
        {
            throw 'No version syntax specified. Please specify a format to convert to.'
        }
    }

    process
    {
        if ($Path.Count -gt 1)
        {
            Write-Progress -Id 1 -Activity 'Converting Pester syntax' -Status ('Processing {0} file(s)' -f $Path.Count) -PercentComplete 0
        }
        else
        {
            Write-Progress -Id 1 -Activity 'Converting Pester syntax' -Status ('Processing file {0}' -f (Split-Path -Path $Path -Leaf)) -PercentComplete 0
        }

        foreach ($filePath in $Path)
        {
            if ($Path.Count -gt 1)
            {
                Write-Progress -Id 1 -Activity 'Converting Pester syntax' -Status "Processing $filePath" -PercentComplete (($Path.IndexOf($filePath) / $Path.Count) * 100)
            }

            $verboseDescriptionMessage = $script:localizedData.Convert_PesterSyntax_ShouldProcessVerboseDescription -f $filePath
            $verboseWarningMessage = $script:localizedData.Convert_PesterSyntax_ShouldProcessVerboseWarning -f $filePath
            $captionMessage = $script:localizedData.Convert_PesterSyntax_ShouldProcessCaption

            if (-not ($PSCmdlet.ShouldProcess($verboseDescriptionMessage, $verboseWarningMessage, $captionMessage)))
            {
                continue
            }

            if ($filePath -is [System.String])
            {
                $filePath = Convert-Path -Path $filePath
            }

            $scriptBlockAst = $filePath | Get-AstDefinition -ErrorAction 'Stop'

            # Get the script text from the script block AST that will be used to replace the original script text.
            $convertedScriptText = $scriptBlockAst.Extent.Text

            Write-Debug -Message ('Parsing the script block AST: {0}' -f $scriptBlockAst.Extent.Text)

            <#
                Get all the Should command AST's in the script block AST, and sort
                them by their start offset in descending order. The descending order
                is so that we can replace the original extent text with the new extent
                without reloading the script block AST.
            #>
            $shouldCommandAst = $scriptBlockAst |
                Get-CommandAst -CommandName 'Should' -ErrorAction 'Stop' |
                Sort-Object -Property { $_.Extent.StartOffset } -Descending

            if ($shouldCommandAst)
            {
                Write-Progress -Id 2 -ParentId 1 -Activity 'Converting Should command syntax' -Status ('Processing {0} command(s)' -f $shouldCommandAst.Count) -PercentComplete 0

                Write-Debug -Message ('Found {0} ''Should'' command(s) in {1}.' -f $shouldCommandAst.Count, $filePath)

                foreach ($commandAst in $shouldCommandAst)
                {
                    $apply = $true

                    # Get start and end offsets of commandAst.Extent
                    $startOffset = $commandAst.Extent.StartOffset
                    $endOffset = $commandAst.Extent.EndOffset

                    # If only one item was returned then there is no collection that has the method IndexOf.
                    $percentComplete = $shouldCommandAst.Count -gt 1 ? (($shouldCommandAst.IndexOf($commandAst) / $shouldCommandAst.Count) * 100) : 100

                    Write-Progress -Id 2 -ParentId 1 -Activity 'Converting Should command syntax' -Status "Processing extent on line $($commandAst.Extent.StartLineNumber)" -PercentComplete $percentComplete

                    $operatorName = Get-ShouldCommandOperatorName -CommandAst $commandAst -ErrorAction 'Stop'

                    if ($operatorName)
                    {
                        switch ($operatorName)
                        {
                            'Be'
                            {
                                $newExtentText = Convert-ShouldBe -CommandAst $commandAst @convertParameters -ErrorAction 'Stop'

                                break
                            }

                            'BeExactly'
                            {
                                $newExtentText = Convert-ShouldBeExactly -CommandAst $commandAst @convertParameters -ErrorAction 'Stop'

                                break
                            }

                            'BeTrue'
                            {
                                $newExtentText = Convert-ShouldBeTrue -CommandAst $commandAst @convertParameters -ErrorAction 'Stop'

                                break
                            }

                            'BeFalse'
                            {
                                $newExtentText = Convert-ShouldBeFalse -CommandAst $commandAst @convertParameters -ErrorAction 'Stop'

                                break
                            }

                            'BeNullOrEmpty'
                            {
                                $newExtentText = Convert-ShouldBeNullOrEmpty -CommandAst $commandAst @convertParameters -ErrorAction 'Stop'

                                break
                            }

                            'BeOfType'
                            {
                                $newExtentText = Convert-ShouldBeOfType -CommandAst $commandAst @convertParameters -ErrorAction 'Stop'

                                break
                            }

                            'Throw'
                            {
                                $isNegated = Test-PesterCommandNegated -CommandAst $commandAst

                                if ($isNegated)
                                {
                                    $newExtentText = Convert-ShouldNotThrow -CommandAst $commandAst @convertParameters -ErrorAction 'Stop'

                                    # Change start and end offsets to replace the entire commandAst.Parent.Extent.Text.
                                    $startOffset = $commandAst.Parent.Extent.StartOffset
                                    $endOffset = $commandAst.Parent.Extent.EndOffset
                                }
                                else
                                {
                                    $newExtentText = Convert-ShouldThrow -CommandAst $commandAst @convertParameters -ErrorAction 'Stop'
                                }

                                break
                            }

                            'Match'
                            {
                                $newExtentText = Convert-ShouldMatch -CommandAst $commandAst @convertParameters -ErrorAction 'Stop'

                                break
                            }

                            'MatchExactly'
                            {
                                $newExtentText = Convert-ShouldMatchExactly -CommandAst $commandAst @convertParameters -ErrorAction 'Stop'

                                break
                            }

                            'Contain'
                            {
                                $newExtentText = Convert-ShouldContain -CommandAst $commandAst @convertParameters -ErrorAction 'Stop'

                                break
                            }

                            default
                            {
                                Write-Warning -Message ('Unsupported command operator ''{0}'' in extent: `{1}`' -f $operatorName, $commandAst.Extent.Text)

                                $apply = $false
                            }
                        }
                    }
                    else
                    {
                        Write-Warning -Message ('Did not found any of the supported command operators in extent: `{0}`' -f $commandAst.Extent.Text)
                    }

                    if ($apply)
                    {
                        # Replace the portion of the script.
                        $convertedScriptText = $convertedScriptText.Remove($startOffset, $endOffset - $startOffset).Insert($startOffset, $newExtentText)
                    }
                }

                Write-Progress -Id 2 -ParentId 1 -Activity 'Converting Should command syntax' -Status 'Completed' -PercentComplete 100 -Completed
            }
            else
            {
                Write-Verbose -Message "No 'Should' command found in $filePath."
            }

            if ($PassThru)
            {
                $convertedScriptText
            }
            else
            {
                Set-Content -Path $filePath -Value $convertedScriptText -NoNewLine -ErrorAction 'Stop'
            }
        }
    }

    end
    {
        Write-Progress -Id 1 -Activity 'Converting Pester syntax' -Status 'Completed' -PercentComplete 100 -Completed
    }
}
