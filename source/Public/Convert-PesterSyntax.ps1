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
        $PassThru,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $OutputPath
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

        $assertBoundParameterParameters = @{
            BoundParameterList     = $PSBoundParameters
            MutuallyExclusiveList1 = @('PassThru')
            MutuallyExclusiveList2 = @('OutputPath')
        }

        Assert-BoundParameter @assertBoundParameterParameters

        if ($OutputPath)
        {
            if (-not (Test-Path -Path $OutputPath))
            {
                $PSCmdlet.ThrowTerminatingError(
                    [System.Management.Automation.ErrorRecord]::new(
                        $script:localizedData.Convert_PesterSyntax_OutputPathDoesNotExist -f $OutputPath,
                        'CPS0002', # cSpell: disable-line
                        [System.Management.Automation.ErrorCategory]::InvalidArgument,
                        $OutputPath
                    )
                )
            }

            if ((Test-Path -Path $OutputPath) -and (Get-Item -Path $OutputPath).PSIsContainer -eq $false)
            {
                $PSCmdlet.ThrowTerminatingError(
                    [System.Management.Automation.ErrorRecord]::new(
                        $script:localizedData.Convert_PesterSyntax_OutputPathIsNotDirectory -f $OutputPath,
                        'CPS0003', # cSpell: disable-line
                        [System.Management.Automation.ErrorCategory]::InvalidArgument,
                        $OutputPath
                    )
                )
            }
        }

        $convertParameters = @{} + $PSBoundParameters
        $convertParameters.Remove('Path')
        $convertParameters.Remove('Force')
        $convertParameters.Remove('PassThru')
        $convertParameters.Remove('OutputPath')

        if ($PSCmdlet.ParameterSetName -eq 'Pester6' -and -not $Pester6.IsPresent)
        {
            $Pester6 = $true
            $convertParameters.Pester6 = $true
        }

        if ($Pester6.IsPresent)
        {
            Write-Verbose -Message $script:localizedData.Convert_PesterSyntax_StartPester6Conversion
        }
        else
        {
            $PSCmdlet.ThrowTerminatingError(
                [System.Management.Automation.ErrorRecord]::new(
                    $script:localizedData.Convert_PesterSyntax_NoVersionSpecified,
                    'CPS0001', # cSpell: disable-line
                    [System.Management.Automation.ErrorCategory]::InvalidOperation,
                    $null
                )
            )
        }
    }

    process
    {
        $writeProgressId1Parameters = @{
            Id       = 1
            Activity = $script:localizedData.Convert_PesterSyntax_WriteProgress_Id1_Activity
        }

        if ($Path.Count -gt 1)
        {
            Write-Progress @writeProgressId1Parameters -PercentComplete 0 -Status ($script:localizedData.Convert_PesterSyntax_WriteProgress_Id1_Status_ProcessingFiles -f $Path.Count)
        }
        else
        {
            Write-Progress @writeProgressId1Parameters -PercentComplete 0 -Status ($script:localizedData.Convert_PesterSyntax_WriteProgress_Id1_Status_ProcessingFile -f (Split-Path -Path $Path -Leaf))
        }

        foreach ($filePath in $Path)
        {
            if ($Path.Count -gt 1)
            {
                Write-Progress @writeProgressId1Parameters -PercentComplete (($Path.IndexOf($filePath) / $Path.Count) * 100) -Status ($script:localizedData.Convert_PesterSyntax_WriteProgress_Id1_Status_ProcessingFile -f (Split-Path -Path $filePath -Leaf))
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

            Write-Debug -Message ($script:localizedData.Convert_PesterSyntax_Debug_ScriptBlockAst -f $scriptBlockAst.Extent.Text)

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
                $writeProgressId2Parameters = @{
                    Id       = 2
                    ParentId = 1
                    Activity = $script:localizedData.Convert_PesterSyntax_WriteProgress_Id2_Activity
                }

                Write-Progress @writeProgressId2Parameters -PercentComplete 0 -Status ($script:localizedData.Convert_PesterSyntax_WriteProgress_Id2_Status_ProcessingCommands -f $shouldCommandAst.Count)

                Write-Debug -Message ($script:localizedData.Convert_PesterSyntax_Debug_FoundShouldCommand -f $shouldCommandAst.Count, $filePath)

                foreach ($commandAst in $shouldCommandAst)
                {
                    $apply = $true

                    # Get start and end offsets of commandAst.Extent
                    $startOffset = $commandAst.Extent.StartOffset
                    $endOffset = $commandAst.Extent.EndOffset

                    # If only one item was returned then there is no collection that has the method IndexOf.
                    $percentComplete = $shouldCommandAst.Count -gt 1 ? (($shouldCommandAst.IndexOf($commandAst) / $shouldCommandAst.Count) * 100) : 100

                    Write-Progress @writeProgressId2Parameters -PercentComplete $percentComplete -Status ($script:localizedData.Convert_PesterSyntax_WriteProgress_Id2_Status_ProcessingLine -f $commandAst.Extent.StartLineNumber)

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

                            'BeFalse'
                            {
                                $newExtentText = Convert-ShouldBeFalse -CommandAst $commandAst @convertParameters -ErrorAction 'Stop'

                                break
                            }

                            'BeGreaterOrEqual'
                            {
                                $newExtentText = Convert-ShouldBeGreaterOrEqual -CommandAst $commandAst @convertParameters -ErrorAction 'Stop'

                                break
                            }

                            'BeGreaterThan'
                            {
                                $newExtentText = Convert-ShouldBeGreaterThan -CommandAst $commandAst @convertParameters -ErrorAction 'Stop'

                                break
                            }

                            'BeIn'
                            {
                                $newExtentText = Convert-ShouldBeIn -CommandAst $commandAst @convertParameters -ErrorAction 'Stop'

                                if ((Test-IsPipelinePart -CommandAst $commandAst -ErrorAction 'Stop'))
                                {
                                    # Change start and end offsets to replace the entire commandAst.Parent.Extent.Text.
                                    $startOffset = $commandAst.Parent.Extent.StartOffset
                                    $endOffset = $commandAst.Parent.Extent.EndOffset
                                }

                                break
                            }

                            'BeLessOrEqual'
                            {
                                $newExtentText = Convert-ShouldBeLessOrEqual -CommandAst $commandAst @convertParameters -ErrorAction 'Stop'

                                break
                            }

                            'BeLessThan'
                            {
                                $newExtentText = Convert-ShouldBeLessThan -CommandAst $commandAst @convertParameters -ErrorAction 'Stop'

                                break
                            }

                            'BeLike'
                            {
                                $newExtentText = Convert-ShouldBeLike -CommandAst $commandAst @convertParameters -ErrorAction 'Stop'

                                break
                            }

                            'BeLikeExactly'
                            {
                                $newExtentText = Convert-ShouldBeLikeExactly -CommandAst $commandAst @convertParameters -ErrorAction 'Stop'

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

                            'BeTrue'
                            {
                                $newExtentText = Convert-ShouldBeTrue -CommandAst $commandAst @convertParameters -ErrorAction 'Stop'

                                break
                            }

                            'Contain'
                            {
                                $newExtentText = Convert-ShouldContain -CommandAst $commandAst @convertParameters -ErrorAction 'Stop'

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

                            default
                            {
                                Write-Warning -Message ($script:localizedData.Convert_PesterSyntax_Warning_UnsupportedCommandOperator -f $operatorName, $commandAst.Extent.Text)

                                $apply = $false
                            }
                        }
                    }
                    else
                    {
                        Write-Warning -Message ($script:localizedData.Convert_PesterSyntax_MissingSupportedCommandOperator -f $commandAst.Extent.Text)
                    }

                    if ($apply)
                    {
                        # Replace the portion of the script.
                        $convertedScriptText = $convertedScriptText.Remove($startOffset, $endOffset - $startOffset).Insert($startOffset, $newExtentText)
                    }
                }

                Write-Progress @writeProgressId2Parameters -Completed -PercentComplete 100 -Status $script:localizedData.Convert_PesterSyntax_WriteProgress_Id2_Status_Completed
            }
            else
            {
                Write-Verbose -Message ($script:localizedData.Convert_PesterSyntax_NoShouldCommand -f $filePath)
            }

            if ($PassThru)
            {
                $convertedScriptText
            }
            else
            {
                if ($OutputPath)
                {
                    $newFilePath = Join-Path -Path $OutputPath -ChildPath (Split-Path -Path $filePath -Leaf)
                    Set-Content -Path $newFilePath -Value $convertedScriptText -NoNewLine -ErrorAction 'Stop'
                }
                else
                {
                    Set-Content -Path $filePath -Value $convertedScriptText -NoNewLine -ErrorAction 'Stop'
                }
            }
        }
    }

    end
    {
        Write-Progress @writeProgressId1Parameters -Completed -PercentComplete 100 -Status $script:localizedData.Convert_PesterSyntax_WriteProgress_Id1_Status_Completed
    }
}
