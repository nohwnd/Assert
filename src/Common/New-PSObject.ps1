function New-PSObject ([hashtable]$Property) {
    New-Object -Type PSObject -Property $Property
}