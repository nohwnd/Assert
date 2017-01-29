Get-ChildItem -Path $PSScriptRoot\src\ -Recurse -Filter *.ps1 | 
    foreach { . $_.FullName }

Export-ModuleMember -Function Assert-ObjectEquivalent, Assert-Equal, Assert-NotEqual, Assert-Same, Assert-NotSame, Assert-Null, Assert-NotNull, Assert-Type, Assert-NotType