param($Path = '.')
pushd $PSScriptRoot


get-module pester, assert, axioms, testHelpers | Remove-Module -force

Import-Module Pester
Import-Module .\..\Assert.psm1
Import-Module .\TestHelpers.psm1
Import-Module .\Axioms\Axioms.psm1 -WarningAction SilentlyContinue
Import-Module .\..\src\TypeClass\TypeClass.psm1


Write-host (New-Dictionary @{name="jakub"})
Get-Date

Invoke-Pester (Resolve-Path $Path)

popd