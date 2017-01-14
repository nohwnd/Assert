function Assert-DecimalEqual 
{
    param (
        [Parameter(ValueFromPipeline=$true)]
        [Decimal]$Actual, 
        [Parameter(Position=0)]
        [decimal]$Expected,
        [String]$Message
    )

    if (-not ($Expected -eq $Actual)) 
    {
        throw [Assertions.AssertionException]"Expected the decimal to be '$Expected' but got '$Actual'."
    }
}