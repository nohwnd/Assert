param($Path)
cd $PSScriptRoot


get-module pester,assert,axioms | Remove-Module -force

Import-Module Pester
import-module .\..\Assert.psm1
Import-Module .\Axioms\Axioms.psm1 -WarningAction SilentlyContinue

Get-Date

if (-not $Path){
    Invoke-Pester .
}
else {
    Invoke-Pester $Path
}