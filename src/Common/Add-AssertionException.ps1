$here = $MyInvocation.MyCommand.Path | Split-Path
$typeDefinition = Get-Content $here/AssertionException.cs | Out-String
Add-Type -TypeDefinition $typeDefinition -WarningAction SilentlyContinue