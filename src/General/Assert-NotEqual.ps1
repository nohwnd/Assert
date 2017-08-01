function Assert-NotEqual {
    param (
        [Parameter(Position=1, ValueFromPipeline=$true)]
        $Actual, 
        [Parameter(Position=0)]
        $Expected,
        [String]$Message
    )

    $Actual = Collect-Input -ParameterInput $Actual -PipelineInput $local:Input
    if ($Expected -eq $Actual) 
    { 
        $Message = Get-AssertionMessage -Expected $Expected -Actual $Actual -Message $Message -DefaultMessage "Expected <expectedType> '<expected>', to be different than the actual value, but they were the same."
        throw [Assertions.AssertionException]$Message
    }

    $Actual
}