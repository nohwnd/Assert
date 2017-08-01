function Assert-NotNull {
    param (
        [Parameter(Position=1, ValueFromPipeline=$true)]
        $Actual, 
        [String]$Message
    )

    $Actual = Collect-Input -ParameterInput $Actual -PipelineInput $local:Input
    if ($null -eq $Actual) 
    { 
        $Message = Get-AssertionMessage -Expected $null -Actual $Actual -Message $Message -DefaultMessage "Expected not `$null, but got `$null."
        throw [Assertions.AssertionException]$Message
    }

    $Actual
}
