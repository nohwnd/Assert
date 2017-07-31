param ([switch]$CIBuild)
pushd $PSScriptRoot


get-module pester, assert, axioms, testHelpers | Remove-Module -force

# import the tested module
Import-Module .\..\Assert.psm1

# import modules and utilities for testing 
Import-Module Pester
Import-Module .\TestHelpers.psm1
Import-Module .\..\Axiom\src\Axiom.psm1 -WarningAction SilentlyContinue

Get-Date
$path = (Resolve-Path ($PWD | Split-Path))
"Running all tests from: $path"
if ($CIBuild) {
    Invoke-Pester $path -EnableExit 
}
else {
    Invoke-Pester $path -Show Summary, Failed
}

popd