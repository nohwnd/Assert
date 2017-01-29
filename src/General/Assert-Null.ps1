function Assert-Null {
    param (
        [Parameter(ValueFromPipeline=$true)]
        $Actual, 
        [String]$Message
    )

    $Actual = Collect-Input -ParameterInput $Actual -PipelineInput $local:Input
    if ($null -ne $Actual) 
    { 
        $Message = Get-AssertionMessage -Expected $null -Actual $Actual -Message $Message -DefaultMessage "Expected `$null, but got <actualType> '<actual>'."
        throw [Assertions.AssertionException]$Message
    }

    $Actual
}
