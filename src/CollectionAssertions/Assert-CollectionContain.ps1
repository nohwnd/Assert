function Assert-CollectionContain {
    param (
        [Parameter(ValueFromPipeline=$true)]
        $Actual, 
        [Parameter(Position=0)]
        $Expected,
        [String]$Message
    )

    $Actual = Collect-Input -ParameterInput $Actual -PipelineInput $local:Input
    if ($Actual -notcontains $Expected) 
    { 
        $type = [string]$Expected
        $Message = Get-AssertionMessage -Expected $Expected -Actual $Actual -Message $Message -DefaultMessage "Expected <expectedType> '<expected>' to be present in collection '<actual>', but it was not there."
        throw [Assertions.AssertionException]$Message
    }

    $Actual
}