function New-Dictionary ([hashtable]$Hashtable) {
    $d = new-object "Collections.Generic.Dictionary[string,object]"
    
    $Hashtable.GetEnumerator() | foreach { $d.Add($_.Key, $_.Value) }

    $d
}

function Clear-WhiteSpace ($Text) {
    "$($Text -replace "(`t|`n|`r)"," " -replace "\s+"," ")".Trim()
}

# this function helps us provide different functionality
# on windows and some other OS. It should generaly be avoided,
# especially in unit tests. I added it now because I don't want 
# to change the test suite extensively while porting it to pwsh6
# in the future it should be removed by choosing better examples
# for the related tests, if possible
function Choose {
    param (
        [Parameter(Mandatory=$true)]
        $OnWindows,
        [Parameter(Mandatory=$true)]
        $Elsewhere
    )

    if ($IsWindows) {
        $OnWindows
    } else {
        $Elsewhere
    }
}