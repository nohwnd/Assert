param ($Path, [switch]$CIBuild)
$ErrorActionPreference = 'Stop'
$WarningPreference = 'SilentlyContinue'
pushd $PSScriptRoot

Set-StrictMode -Version Latest

$minimumNugetProviderVersion = '2.8.5.201'
# not using the -Name parameter because it throws when Nuget is not installed
if (-not (Get-PackageProvider -ListAvailable | Where { $_.Name -eq "Nuget" -and $_.Version -ge $minimumNugetProviderVersion })) {
    "Installing Nuget package provider."
    Install-PackageProvider -Name NuGet -MinimumVersion $minimumNugetProviderVersion -Force
}

$minimumPesterVersion = "4.4.0"
if (-not (Get-Module -ListAvailable | Where { $_.Name -eq"Pester" -and $_.Version -ge $minimumPesterVersion })) {
    "Installing Pester."
    Install-Module -Name Pester -Force -SkipPublisherCheck -MinimumVersion $minimumPesterVersion -Scope CurrentUser
}

get-module pester, assert, axiom, testHelpers | Remove-Module -force

# import the tested module
Import-Module ./../Assert.psd1

# import modules and utilities for testing 
Import-Module Pester
Import-Module ./TestHelpers.psm1
Import-Module ./../Axiom/src/Axiom.psm1 -WarningAction SilentlyContinue

Get-Date
if ($null -eq $Path) {
    $path = (Resolve-Path ($PWD | Split-Path))
}

"Running all tests from: $path"
if ($CIBuild) {
    Invoke-Pester $path -EnableExit
}
else {
    Invoke-Pester $path -Show Summary, Failed
}

popd