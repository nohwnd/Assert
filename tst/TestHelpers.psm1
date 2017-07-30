function New-Dictionary ([hashtable]$Hashtable) {
    $d = new-object "Collections.Generic.Dictionary[string,object]"
    
    $Hashtable.GetEnumerator() | foreach { $d.Add($_.Key, $_.Value) }

    $d
}