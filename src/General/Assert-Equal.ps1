function Assert-Equal {
    param (
        [Parameter(ValueFromPipeline=$true)]
        $Actual, 
        [Parameter(Position=0)]
        $Expected,
        [String]$Message
    )

    $Actual = Collect-Input -ParameterInput $Actual -PipelineInput $local:Input
    if ($Expected -ne $Actual) 
    { 
        $Message = Get-AssertionMessage -Expected $Expected -Actual $Actual -Message $Message -DefaultMessage "Expected <expectedType> '<expected>', but got <actualType> '<actual>'."
        throw [Assertions.AssertionException]$Message
    }

    $Actual
}
