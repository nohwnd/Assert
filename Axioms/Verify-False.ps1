function Verify-False {
    param (
        [Parameter(ValueFromPipeline=$true)]
        $Actual
    )

    if ($Actual) {
        throw [Exception]"Expected `$true but got '$Actual'."
    }

    $Actual
}