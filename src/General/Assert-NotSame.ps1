function Assert-NotSame {
    param (
        [Parameter(ValueFromPipeline=$true)]
        $Actual, 
        [Parameter(Position=0)]
        $Expected,
        [String]$Message
    )

    $Actual = Collect-Input -ParameterInput $Actual -PipelineInput $local:Input
    if ([object]::ReferenceEquals($Expected, $Actual))
    { 
        $Message = Get-AssertionMessage -Expected $Expected -Actual $Actual -Message $Message -DefaultMessage "Expected <expectedType> '<expected>', to not be the same instance."
        throw [Assertions.AssertionException]$Message
    }
    
    $Actual
}
