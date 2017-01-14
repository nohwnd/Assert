function Verify-NullOrEmpty {
    param (
        [Parameter(ValueFromPipeline=$true)]
        $Actual
    )

    if ($null -ne $Actual) {
        throw [Exception]"Expected `$null but got '$Actual'."
    }
    
    $Actual
}