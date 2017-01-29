function Get-AssertionMessage ($Expected, $Actual, $Option, $Message, $DefaultMessage) 
{
    if (-not $Message)
    {
        $Message = $DefaultMessage
    }
    
    $expectedFormatted = Format-Custom -Value $Expected
    $actualFormatted = Format-Custom -Value $Actual

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