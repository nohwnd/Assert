function Assert-True{
    param (
        [Parameter(ValueFromPipeline=$true)]
        $Actual, 
        [String]$Message
    )

    $Actual = Collect-Input -ParameterInput $Actual -PipelineInput $local:Input
    if (-not $Actual) 
    { 
        $Message = Get-AssertionMessage -Expected $true -Actual $Actual -Message $Message -DefaultMessage "Expected <actualType> '<actual>' to be <expectedType> '<expected>' or truthy value."
        throw [Assertions.AssertionException]$Message
    }

    $Actual
}
