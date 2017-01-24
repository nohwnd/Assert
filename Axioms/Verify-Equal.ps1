function Verify-Equal {
    param (
        [Parameter(ValueFromPipeline=$true)]
        $Actual,
        [Parameter(Mandatory=$true,Position=0)]
        $Expected
    )

    if ($Expected -ne $Actual) {
        throw [Exception]("Expected and actual values differ!`n"+
            "Expected: '$Expected'`n"+
            "Actual  : '$Actual'`n" +
            "Expected length: $($Expected.Length)`nActual length: $($Actual.Length)")
    }
    
    $Actual
}