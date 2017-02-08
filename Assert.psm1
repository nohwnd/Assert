#Get list source Functions
$srcFunctions = Get-ChildItem -Path $PSScriptRoot\src\ -Recurse -Filter *.ps1

#Dot Source Functions
$srcFunctions |
ForEach-Object{ 
   . $_.FullName
}

#Export ModuleMembers
Export-ModuleMember -Function $srcFunctions.BaseName
