param($Path = '.')
pushd $PSScriptRoot


get-module pester, assert, axioms, testHelpers | Remove-Module -force

# import the tested module
Import-Module .\..\Assert.psm1

# import modules and utilities for testing 
Import-Module Pester
Import-Module .\TestHelpers.psm1
Import-Module .\Axioms\Axioms.psm1 -WarningAction SilentlyContinue

Get-Date

Invoke-Pester (Resolve-Path $Path) -Show Summary, Fails

popd