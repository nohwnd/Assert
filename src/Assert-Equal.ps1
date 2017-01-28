function Assert-Equal {
    param (
        [Parameter(ValueFromPipeline=$true)]
        $Actual, 
        [Parameter(Position=0)]
        $Expected,
        [String]$Message
    )

    if ($Expected -is [String]) 
    {
        Assert-StringEqual -Expected $Expected -Actual $Actual -Message $Message
    }

    if ($Expected -is [Int]) 
    {
        Assert-IntEqual -Expected $Expected -Actual $Actual -Message $Message
    }

    if ($Expected -is [Double]) 
    {
        Assert-DoubleEqual -Expected $Expected -Actual $Actual -Message $Message
    }

    if ($Expected -is [Decimal]) 
    {
        Assert-DecimalEqual -Expected $Expected -Actual $Actual -Message $Message
    }

    Assert-ObjectEqual -Expected $Expected -Actual $Actual -Message $Message
}