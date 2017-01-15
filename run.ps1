cd $PSScriptRoot

get-module pester | Remove-Module 
Import-Module C:\Users\nohwnd\projects\Pester\Pester.psd1 -Force

. .\initialize.ps1

Get-Date
Invoke-Pester $pwd