@{
    Severity     = @('Error', 'Warning')

    # Write-Host: these are interactive installer and test scripts whose colored
    # console output is the UX; nothing consumes them through the pipeline.
    # ShouldProcess: flagged functions are internal script helpers, not exported
    # cmdlets; -WhatIf plumbing would be ceremony with no caller.
    ExcludeRules = @(
        'PSAvoidUsingWriteHost',
        'PSUseShouldProcessForStateChangingFunctions'
    )
}
