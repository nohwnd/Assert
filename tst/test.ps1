param ($Path, [switch]$CIBuild, [switch] $UseBreakpointCodeCoverage)
$ErrorActionPreference = 'Stop'
$WarningPreference = 'SilentlyContinue'
$here = $PSScriptRoot
Set-StrictMode -Version Latest

try {
    Push-Location $here

    # this is useful also for running in docker
    # but keeping it without the build switch
    # makes every test run slow because Get-PackagerProvider
    # takes 10 seconds
    if ($CIBuild) {
        Import-Module -Name PackageManagement
        $minimumNugetProviderVersion = '2.8.5.201'
        # not using the -Name parameter because it throws when Nuget is not installed
        if (-not (Get-PackageProvider -ListAvailable | Where-Object { $_.Name -eq "Nuget" -and $_.Version -ge $minimumNugetProviderVersion })) {
            "Installing Nuget package provider."
            Install-PackageProvider -Name NuGet -MinimumVersion $minimumNugetProviderVersion -Force
        }

        $minimumPesterVersion = "5.3.0-alpha4"
        # if (-not (Get-Module -All | Where-Object { $_.Name -eq "Pester" -and $_.Version -ge $minimumPesterVersion })) {
            "Installing Pester."
            Install-Module -Name Pester -Force -MinimumVersion $minimumPesterVersion -Scope CurrentUser -AllowPreRelease
        # }
    }
    

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
    if (-not $CIBuild) {
        $configuration = New-PesterConfiguration
        $configuration.Run.Path = $Path 
        $configuration.Run.Exit = $true
        $configuration.Output.Verbosity = "Detailed"
        $configuration.TestResult.Enabled = $true
        $configuration.TestResult.OutputPath = "$PSScriptRoot/../TestResults.xml"
        $configuration.CodeCoverage.Enabled = $true
        $configuration.CodeCoverage.OutputFormat = 'CoverageGutters'
        if ($UseBreakpointCodeCoverage) {
            $configuration.CodeCoverage.OutputPath = "$PSScriptRoot/../coverage-with-bps.xml"
        }
        else {
            $configuration.CodeCoverage.UseBreakpoints = $false
            $configuration.CodeCoverage.OutputPath = "$PSScriptRoot/../coverage-without-bps.xml"
        }
        $configuration.CodeCoverage.Path = "$PSScriptRoot/../src"
        Invoke-Pester -Configuration $configuration
    }
    else {
        Invoke-Pester $path -Output Detailed
    }
}
finally {
    Pop-Location
}