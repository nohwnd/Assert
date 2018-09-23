function Verify-AssertionFailed {
    param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [ScriptBlock]$ScriptBlock
    )

    $assertionExceptionThrown = $false
    try {
        $null = & $ScriptBlock
    }
    catch [Assertions.AssertionException]
    {
        $assertionExceptionThrown = $true
        $_
    }
    
    if (-not $assertionExceptionThrown) {
        throw [Exception]"An exception of type Assertions.AssertionException was expected but no exception was thrown!"
    }
}