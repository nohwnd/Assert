Get-ChildItem -Path $PSScriptRoot\src\ -Recurse -Filter *.ps1 | 
    foreach { . $_.FullName }

Export-ModuleMember -Function Assert-ObjectEquivalent