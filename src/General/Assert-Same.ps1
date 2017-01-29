function Assert-Same {
    param (
        [Parameter(ValueFromPipeline=$true)]
        $Actual, 
        [Parameter(Position=0)]
        $Expected,
        [String]$Message
    )

    $Actual = Collect-Input -ParameterInput $Actual -PipelineInput $local:Input
    if (-not ([object]::ReferenceEquals($Expected, $Actual))) 
    { 
        $Message = Get-AssertionMessage -Expected $Expected -Actual $Actual -Message $Message -DefaultMessage "Expected <expectedType> '<expected>', to be the same instance but it was not."
        throw [Assertions.AssertionException]$Message
    }
    
    $Actual
}
