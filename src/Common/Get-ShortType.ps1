function Get-ShortType ($Value) {
    $type = '<null>'
    if ($null -ne $value)
    {
        $type = ([string]$Value.GetType()) 
    }
    $type `
        -replace "^System\." `
        -replace "^Management\.Automation\.PSCustomObject$","PSObject" `
        -replace "^Object\[\]$","collection"
}