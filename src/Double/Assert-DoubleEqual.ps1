function Assert-DoubleEqual 
{
    param (
        [Parameter(ValueFromPipeline=$true)]
        [Double]$Actual, 
        [Parameter(Position=0)]
        [Double]$Expected,
        [String]$Message
    )

    if (-not ($Expected -eq $Actual)) 
    {
        throw [Assertions.AssertionException]"Expected the double to be '$Expected' but got '$Actual'."
    }
}