function Assert-Throw {
    param (
        [Parameter(ValueFromPipeline=$true)]
        [ScriptBlock] $Actual, 
        [String]$ExceptionMessage,
        [Type]$ExceptionType,
        [String]$FullyQualifiedErrorId,
        [String]$Message
    )

    $Actual = Collect-Input -ParameterInput $Actual -PipelineInput $local:Input

    $exceptionThrown = $false
    try {
        $null = & $Actual
    }
    catch
    {
        $exceptionThrown = $true
        $_
    }
    
    if (-not $exceptionThrown) {
        $Message = Get-AssertionMessage -Expected $Expected -Actual $Actual -Message $Message `
        -DefaultMessage "Expected exception to be thrown."
        throw [Assertions.AssertionException]$Message
    }

    $Actual
}
