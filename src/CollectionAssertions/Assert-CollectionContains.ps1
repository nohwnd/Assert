function Assert-CollectionContains {
    param (
        [Parameter(ValueFromPipeline=$true)]
        $Actual, 
        [Parameter(Position=0)]
        $Expected,
        [String]$Message
    )
    begin {
        $collection = @()
    }
    process {
        $collection += $Actual
    }
    end {
        if (-not ($collection -contains $Expected)) 
        {
            throw [Assertions.AssertionException]"Expected the collection to contain '$Expected' but got '$($collection -join ', ')'."
        }
    }
}