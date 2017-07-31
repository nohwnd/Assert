function Assert-CollectionAny {
    param (
        [Parameter(ValueFromPipeline=$true, Position=1)]
        $Actual, 
        [Parameter(Position=0, Mandatory=$true)]
        [scriptblock]$FilterScript,
        [String]$Message
    )
    
    $Expected = $FilterScript
    $Actual = Collect-Input -ParameterInput $Actual -PipelineInput $local:Input
    if (-not ($Actual | Where-Object -FilterScript $FilterScript))
    { 
        $Message = Get-AssertionMessage -Expected $Expected -Actual $Actual -Message $Message -DefaultMessage "Expected at least one item in collection '<actual>' to pass filter '<expected>', but none of the items passed the filter."
        throw [Assertions.AssertionException]$Message
    }

    $Actual
}