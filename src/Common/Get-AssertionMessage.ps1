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


    $Message = $Message.Replace('<expected>', $expectedFormatted)
    $Message = $Message.Replace('<actual>', $actualFormatted)
    $Message = $Message.Replace('<expectedType>', (Get-ShortType -Value $Expected))
    $Message = $Message.Replace('<actualType>', (Get-ShortType -Value $Actual))
    $Message = $Message.Replace('<options>', $optionMessage)

    $Message
}