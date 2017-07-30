function Assert-ObjectEqual 
{
    param (
        [Parameter(ValueFromPipeline=$true)]
        $Actual, 
        [Parameter(Position=0)]
        $Expected,
        [String]$Message
    )

    if (-not ($Expected -eq $Actual)) 
    {
        throw [Assertions.AssertionException]"Expected the object to be '$Expected' but got '$Actual'."
    }
}