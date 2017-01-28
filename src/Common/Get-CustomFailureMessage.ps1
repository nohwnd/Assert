function Get-CustomFailureMessage ($Message, $Expected, $Actual) 
{
    $formatted = $Message -f $Expected, $Actual
    $tokensReplaced = $formatted -replace '<expected>', $Expected -replace '<actual>', $Actual
    $tokensReplaced -replace '<e>', $Expected -replace '<a>', $Actual
}