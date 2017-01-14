# Asserts that two strings are 

. $PSScriptRoot\..\common.ps1

function Test-StringNotEqual 
{
    param (
        [String]$Expected, 
        [String]$Actual, 
        [switch]$CaseSensitive,
        [switch]$IgnoreWhitespace
    )

    if ($IgnoreWhitespace)
    { 
        $Expected = $Expected -replace '\s'
        $Actual = $Actual -replace '\s'
    }

    if (-not $CaseSensitive) 
    {
        $Expected -ne $Actual
    } 
    else 
    {
        $Expected -cne $Actual
    }
}

function Get-StringNotEqualDefaultFailureMessage ([String]$Expected, [String]$Actual) 
{
    "Expected the strings to be different but they were the same '$Expected'."
}

function Assert-StringNotEqual 
{
    param (
        [Parameter(ValueFromPipeline=$true)]
        [String]$Actual, 
        [Parameter(Position=0)]
        [String]$Expected,
        [String]$Message,
        [switch]$CaseSensitive,
        [switch]$IgnoreWhitespace
    )

    if (-not (Test-StringNotEqual -Expected $Expected -Actual $Actual -CaseSensitive:$CaseSensitive -IgnoreWhitespace:$IgnoreWhiteSpace)) 
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
