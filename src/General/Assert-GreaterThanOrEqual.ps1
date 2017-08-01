function Assert-GreaterThanOrEqual {
    param (
        [Parameter(Position=1, ValueFromPipeline=$true)]
        $Actual, 
        [Parameter(Position=0)]
        $Expected,
        [String]$Message
    )

    $Actual = Collect-Input -ParameterInput $Actual -PipelineInput $local:Input
    if ($Expected -gt $Actual) 
    { 
        $Message = Get-AssertionMessage -Expected $Expected -Actual $Actual -Message $Message -DefaultMessage "Expected <actualType> '<actual>' to be greater than or equal to <expectedType> '<expected>', but it was not."
        throw [Assertions.AssertionException]$Message
    }

    $Actual
}
