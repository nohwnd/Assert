function Assert-IntEqual 
{
    param (
        [Parameter(ValueFromPipeline=$true)]
        [Int]$Actual, 
        [Parameter(Position=0)]
        [Int]$Expected,
        [String]$Message
    )

    if (-not ($Expected -eq $Actual)) 
    {
        throw [Assertions.AssertionException]"Expected the int to be '$Expected' but got '$Actual'."
    }
}