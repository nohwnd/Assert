function Get-StringNotEqualDefaultFailureMessage ([String]$Expected, $Actual) 
{
    "Expected the strings to be different but they were the same '$Expected'."
}

function Assert-StringNotEqual 
{
    param (
        [Parameter(ValueFromPipeline=$true)]
        $Actual, 
        [Parameter(Position=0)]
        [String]$Expected,
        [String]$Message,
        [switch]$CaseSensitive,
        [switch]$IgnoreWhitespace
    )

    if (Test-StringEqual -Expected $Expected -Actual $Actual -CaseSensitive:$CaseSensitive -IgnoreWhitespace:$IgnoreWhiteSpace) 
    {
        if (-not $Message)
        {
            $formattedMessage = Get-StringNotEqualDefaultFailureMessage -Expected $Expected -Actual $Actual
        }
        else 
        {
            $formattedMessage = Get-CustomFailureMessage -Expected $Expected -Actual $Actual -Message $Message
        }

        throw [Assertions.AssertionException]$formattedMessage
    }
}
