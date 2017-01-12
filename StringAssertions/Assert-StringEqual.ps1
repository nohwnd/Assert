# Asserts that two strings are 

. $PSScriptRoot\..\common.ps1

function Test-StringEqual 
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
        $Expected -eq $Actual
    } 
    else 
    {
        $Expected -ceq $Actual
    }
}

function Get-StringEqualDefaultFailureMessage ([String]$Expected, [String]$Actual) 
{
    "Expected the string to be '$Expected' but got '$Actual'."
}

function Assert-StringEqual 
{
    param (
        [Parameter(ValueFromPipeline=$true)]
        [String]$Expected, 
        [Parameter(Position=0)]
        [String]$Actual, 
        [String]$Message,
        [switch]$CaseSensitive,
        [switch]$IgnoreWhitespace
    )

    if (-not (Test-StringEqual -Expected $Expected -Actual $Actual -CaseSensitive:$CaseSensitive -IgnoreWhitespace:$IgnoreWhiteSpace)) 
    {
        if (-not $Message)
        {
            $formattedMessage = Get-StringEqualDefaultFailureMessage -Expected $Expected -Actual $Actual
        }
        else 
        {
            $formattedMessage = Get-CustomFailureMessage -Expected $Expected -Actual $Actual -Message $Message
        }

        throw [Exception]$formattedMessage
    }
}
