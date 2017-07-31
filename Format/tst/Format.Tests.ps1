Get-Module Format | Remove-Module
Import-Module $PSScriptRoot\..\src\Format.psm1 -Force

. $PSScriptRoot\..\..\Compatibility\src\New-PSObject.ps1

Add-Type -TypeDefinition 'namespace Assertions.TestType { public class Person { public string Name {get;set;} public int Age {get;set;}}}'
Describe "Format-Collection" { 
    It "Formats collection of values '<value>' to '<expected>' using the default separator" -TestCases @(
        @{ Value = (1, 2, 3); Expected = "1, 2, 3" }
    ) { 
        param ($Value, $Expected)
        Format-Collection -Value $Value | Verify-Equal $Expected
    }

    It "Formats collection of values '<value>' to '<expected>' using the default separator" -TestCases @(
        @{ Value = (1, 2, 3); Expected = "1, 2, 3" }
    ) { 
        param ($Value, $Expected)
        Format-Collection -Value $Value | Verify-Equal $Expected
    }
}

Describe "Format-Number" { 
    It "Formats number to use . separator (tests anything only on non-english systems --todo)" -TestCases @(
        @{ Value = 1.1; },
        @{ Value = [double] 1.1; },
        @{ Value = [float] 1.1; },
        @{ Value = [single] 1.1; },
        @{ Value = [decimal] 1.1; }
    ) { 
        param ($Value)
        Format-Number -Value $Value | Verify-Equal "1.1"
    }
}

Describe "Format-Object" {
    It "Formats object '<value>' to '<expected>'" -TestCases @(
        @{ Value = (New-PSObject @{Name = 'Jakub'; Age = 28}); Expected = "PSObject{Age=28; Name=Jakub}"},
        @{ Value = (New-Object -Type Assertions.TestType.Person -Property @{Name = 'Jakub'; Age = 28}); Expected = "Assertions.TestType.Person{Age=28; Name=Jakub}"}
    ) { 
        param ($Value, $Expected)
        Format-Object -Value $Value | Verify-Equal $Expected
    }

    It "Formats object '<value>' with selected properties '<selectedProperties>' to '<expected>'" -TestCases @(
        @{ Value = (New-PSObject @{Name = 'Jakub'; Age = 28}); SelectedProperties = "Age"; Expected = "PSObject{Age=28}"},
        @{ Value = (Get-Process -Name Idle); SelectedProperties = 'Name', 'Id'; Expected = "Diagnostics.Process{Id=0; Name=Idle}" },
        @{ 
            Value              = (New-Object -Type Assertions.TestType.Person -Property @{Name = 'Jakub'; Age = 28})
            SelectedProperties = 'Name'
            Expected           = "Assertions.TestType.Person{Name=Jakub}"
        }
    ) { 
        param ($Value, $SelectedProperties, $Expected)
        Format-Object -Value $Value -Property $SelectedProperties | Verify-Equal $Expected
    }
}

Describe "Format-Boolean" {
    It "Formats boolean '<value>' to '<expected>'" -TestCases @(
        @{ Value = $true; Expected = '$true' },
        @{ Value = $false; Expected = '$false' }
    ) {
        param($Value, $Expected)
        Format-Boolean -Value $Value | Verify-Equal $Expected
    }
}

Describe "Format-Null" { 
    It "Formats null to '`$null'" {
        Format-Null | Verify-Equal '$null'
    }
}

Describe "Format-ScriptBlock" { 
    It "Formats scriptblock as string with curly braces" {
        Format-ScriptBlock -Value {abc} | Verify-Equal '{abc}'
    }
}

Describe "Format-Hashtable" { 
    It "Formats empty hashtable as @{}" {
        Format-Hashtable @{} | Verify-Equal '@{}'
    }

    It "Formats hashtable as '<expected>'" -TestCases @(
        @{ Value = @{Age = 28; Name = 'Jakub'}; Expected = '@{Age=28; Name=Jakub}' }
        @{ Value = @{Z = 1; H = 1; A = 1}; Expected = '@{A=1; H=1; Z=1}' }
        @{ Value = @{Hash = @{Hash = 'Value'}}; Expected = '@{Hash=@{Hash=Value}}' }
    ) {
        param ($Value, $Expected)
        Format-Hashtable $Value | Verify-Equal $Expected
    }
}

Describe "Format-Dictionary" { 
    It "Formats empty dictionary as @{}" {
        Format-Dictionary (New-Dictionary @{}) | Verify-Equal 'Dictionary{}'
    }

    It "Formats dictionary as '<expected>'" -TestCases @(
        @{ Value = New-Dictionary @{Age = 28; Name = 'Jakub'}; Expected = 'Dictionary{Age=28; Name=Jakub}' }
        @{ Value = New-Dictionary @{Z = 1; H = 1; A = 1}; Expected = 'Dictionary{A=1; H=1; Z=1}' }
        @{ Value = New-Dictionary @{Dict = ( New-Dictionary @{Dict = 'Value'})}; Expected = 'Dictionary{Dict=Dictionary{Dict=Value}}' }
    ) {
        param ($Value, $Expected)
        Format-Dictionary $Value | Verify-Equal $Expected
    }
}

Describe "Format-Custom" {
    It "Formats value '<value>' correctly to '<expected>'" -TestCases @(
        @{ Value = $null; Expected = '$null'}
        @{ Value = $true; Expected = '$true'}
        @{ Value = $false; Expected = '$false'}
        @{ Value = 'a' ; Expected = 'a'},
        @{ Value = 1; Expected = '1' },
        @{ Value = (1, 2, 3); Expected = '1, 2, 3' },
        @{ Value = 1.1; Expected = '1.1' },
        @{ Value = New-PSObject @{ Name = "Jakub" }; Expected = 'PSObject{Name=Jakub}' },
        @{ Value = (Get-Process Idle); Expected = 'Diagnostics.Process{Id=0; Name=Idle}'},
        @{ Value = (New-Object -Type Assertions.TestType.Person -Property @{Name = 'Jakub'; Age = 28}); Expected = "Assertions.TestType.Person{Age=28; Name=Jakub}"}
        @{ Value = @{Name = 'Jakub'; Age = 28}; Expected = '@{Age=28; Name=Jakub}' }
        @{ Value = New-Dictionary @{Age = 28; Name = 'Jakub'}; Expected = 'Dictionary{Age=28; Name=Jakub}' }
    ) { 
        param($Value, $Expected)
        Format-Custom -Value $Value | Verify-Equal $Expected
    }
}

Describe "Get-IdentityProperty" {
    It "Returns '<expected>' for '<type>'" -TestCases @(
        @{ Type = "Diagnostics.Process"; Expected = ("Id", "Name") }
    ) {
        param ($Type, $Expected)
        $Actual = Get-IdentityProperty -Type $Type
        "$Actual" | Verify-Equal "$Expected"
    }
}

Describe "Get-ShortType" {
    It "Given '<value>' it returns the correct shortened type name '<expected>'" -TestCases @(
        @{ Value = 1; Expected = 'int' },
        @{ Value = 1.1; Expected = 'double' },
        @{ Value = 'a' ; Expected = 'string' },
        @{ Value = $null ; Expected = '<null>' },
        @{ Value = New-PSObject @{Name = 'Jakub'} ; Expected = 'PSObject'},
        @{ Value = [Object[]]1, 2, 3 ; Expected = 'collection' }
    ) {
        param($Value, $Expected)
        Get-ShortType -Value $Value | Verify-Equal $Expected
    }
}
 