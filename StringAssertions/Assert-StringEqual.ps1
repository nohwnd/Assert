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

function Collect-Input ($ParameterInput, $PipelineInput) 
{
    #source: http://www.powertheshell.com/input_psv3/
    $collectedInput = $PipelineInput

    $isInPipeline = $collectedInput.Count -gt 0
    if ($isInPipeline) {
        $collectedInput
    }
    else 
    {
        $ParameterInput
    }
}

function Assert-StringEqual 
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
    
    $_actual = Collect-Input -ParameterInput $Actual -PipelineInput $local:Input
        
    if (-not (Test-StringEqual -Expected $Expected -Actual $_actual -CaseSensitive:$CaseSensitive -IgnoreWhitespace:$IgnoreWhiteSpace)) 
    {
        if (-not $Message)
        {
            $formattedMessage = Get-StringEqualDefaultFailureMessage -Expected $Expected -Actual $_actual
        }
        else 
        {
            $formattedMessage = Get-CustomFailureMessage -Expected $Expected -Actual $_actual -Message $Message
        }

        throw [Assertions.AssertionException]$formattedMessage
    }
}
