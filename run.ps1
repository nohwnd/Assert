cd $PSScriptRoot

get-module pester | Remove-Module 
Import-Module C:\Users\nohwnd\documents\GitHub\Pester_main\Pester.psd1 -Force

. .\initialize.ps1

Get-Date
Invoke-Pester $pwd