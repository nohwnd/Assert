function Assert-Same {
    param (
        [Parameter(Position=1, ValueFromPipeline=$true)]
        $Actual, 
        [Parameter(Position=0)]
        $Expected,
        [String]$CustomMessage
    )

    if ($Expected -is [int])
    {
        throw [System.ArgumentException]"Assert-Throw provides unexpected results for low integers. See https://github.com/nohwnd/Assertions/issues/6"
    }

    $Actual = Collect-Input -ParameterInput $Actual -PipelineInput $local:Input
    if (-not ([object]::ReferenceEquals($Expected, $Actual))) 
    { 
        $Message = Get-AssertionMessage -Expected $Expected -Actual $Actual -CustomMessage $CustomMessage -DefaultMessage "Expected <expectedType> '<expected>', to be the same instance but it was not."
        throw [Assertions.AssertionException]$Message
    }
    
    $Actual
}
