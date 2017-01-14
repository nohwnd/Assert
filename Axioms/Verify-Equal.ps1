function Verify-Equal {
    param (
        [Parameter(ValueFromPipeline=$true)]
        $Actual,
        [Parameter(Mandatory=$true,Position=0)]
        $Expected
    )

    if ($Expected -ne $Actual) {
        throw [Exception]"Expected '$Expected' but got '$Actual'.`nExpected length: $($Expected.Length)`nActual length: $($Actual.Length)"
    }
    
    $Actual
}