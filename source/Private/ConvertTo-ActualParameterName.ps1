<#
    .SYNOPSIS
        Converts a unambiguous abbreviated named parameter to its actual parameter
        name.

    .DESCRIPTION
        The ConvertTo-ActualParameterName function returns the actual parameter
        name of a unambiguous abbreviated named parameter.

    .PARAMETER CommandName
        Specifies the name of the command. Must be one supported.

    .PARAMETER NamedParameter
        Specifies the unambiguous abbreviated named parameter to convert.

    .OUTPUTS
        System.String

        Holds the converted parameter name.

    .EXAMPLE
        ConvertTo-ActualParameterName -CommandName 'Should' -NamedParameter 'Actual'

        Returns the correct parameter name `ActualValue`.
#>
function ConvertTo-ActualParameterName
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet('Should')]
        [System.String]
        $CommandName,

        [Parameter(Mandatory = $true)]
        [System.String]
        $NamedParameter
    )

    switch ($CommandName)
    {
        # Should in Pester 5.
        'Should'
        {
            $parametersName = @(
                # Parameters names.
                'ActualValue'
                'Alias'
                'Be'
                'Because'
                'BeExactly'
                'BeFalse'
                'BeGreaterOrEqual'
                'BeGreaterThan'
                'BeIn'
                'BeLessOrEqual'
                'BeLessThan'
                'BeLike'
                'BeLikeExactly'
                'BeNullOrEmpty'
                'BeOfType'
                'BeTrue'
                'CallerSessionState'
                'CommandName'
                'Contain'
                'Debug'
                'DefaultValue'
                'ErrorAction'
                'ErrorId'
                'ErrorVariable'
                'Exactly'
                'ExceptionType'
                'ExclusiveFilter'
                'Exist'
                'ExpectedContent'
                'ExpectedMessage'
                'ExpectedType'
                'ExpectedValue'
                'FileContentMatch'
                'FileContentMatchExactly'
                'FileContentMatchMultiline'
                'FileContentMatchMultilineExactly'
                'HasArgumentCompleter'
                'HaveCount'
                'HaveParameter'
                'InformationAction'
                'InformationVariable'
                'InParameterSet'
                'Invoke'
                'InvokeVerifiable'
                'Mandatory'
                'Match'
                'MatchExactly'
                'ModuleName'
                'Not'
                'OutBuffer'
                'OutVariable'
                'ParameterFilter'
                'ParameterName'
                'PassThru'
                'PipelineVariable'
                'ProgressAction'
                'RegularExpression'
                'Scope'
                'Throw'
                'Times'
                'Type'
                'Verbose'
                'WarningAction'
                'WarningVariable'

                # Alias parameter names.
                'EQ'
                'CEQ'
                'GT'
                'LE'
                'LT'
                'GE'
                'HaveType'
                'CMATCH'
            )
        }
    }

    # Try to match exact name.
    $result = $parametersName -match "^$NamedParameter$"

    if (-not $result)
    {
        # Try to match abbreviated name.
        $result = $parametersName -match "^$NamedParameter"

        if ($result.Count -gt 1)
        {
            $PSCmdlet.ThrowTerminatingError(
                [System.Management.Automation.ErrorRecord]::new(
                    ($script:localizedData.AmbiguousNamedParameter -f $NamedParameter, $CommandName),
                    'CTAPN0001', # cSpell: disable-line
                    [System.Management.Automation.ErrorCategory]::InvalidOperation,
                    $NamedParameter
                )
            )
        }
    }

    if (-not $result)
    {
        $PSCmdlet.ThrowTerminatingError(
            [System.Management.Automation.ErrorRecord]::new(
                ($script:localizedData.UnknownNamedParameter -f $NamedParameter, $CommandName),
                'CTAPN0002', # cSpell: disable-line
                [System.Management.Automation.ErrorCategory]::InvalidOperation,
                $NamedParameter
            )
        )
    }

    return $result
}
