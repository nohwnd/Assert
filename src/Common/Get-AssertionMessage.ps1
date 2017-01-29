function Get-AssertionMessage ($Expected, $Actual, $Option, $Message, $DefaultMessage, [switch]$Pretty) 
{
    if (-not $Message)
    {
        $Message = $DefaultMessage
    }
    
    $expectedFormatted = Format-Custom -Value $Expected -Pretty:$Pretty
    $actualFormatted = Format-Custom -Value $Actual -Pretty:$Pretty

    $optionMessage = $null;
    if ($null -ne $Option)
    {
        $optionMessage = "Used options: $($Option -join ", ")."
    }

    $Message = $Message `
        -replace '<expected>', $expectedFormatted `
        -replace '<actual>', $actualFormatted `
        -replace '<expectedType>', (Get-ShortType -Value $Expected) `
        -replace '<actualType>', (Get-ShortType -Value $Actual) `
        -replace '<options>', $optionMessage

    $Message
}