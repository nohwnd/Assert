. $PSScriptRoot\Assert-Equivalent.ps1
. $PSScriptRoot\..\testHelpers.ps1

Describe 'Test-Equivalent' {   
    It "Comparing single values: '<Actual>' and '<Expected>' returns $null" -TestCases @(
        @{Actual = 1; Expected = 1}, # same numbers
        @{Actual = 2.0; Expected = 2.0}, # same values
        @{Actual = "abc"; Expected = "abc"} # same strings
        @{Actual = -1.0; Expected = -1} # same values different types
        @{Actual = {abc}; Expected = "abc"} # actual serializes to the same value as expected
        @{Actual = @("abc"); Expected = "abc"} # single value in array is considered the same
        @{Actual = "abc"; Expected = @("abc")} # single value in array is considered the same
    ) { 
        param ($Actual, $Expected) 
        
        Test-Equivalent -Expected $Expected -Actual $Actual | Verify-Null
    }

    It "Comparing different values: '<Left>' and '<Right>' values returns report" -TestCases @(
        @{Left = 1; Right = 7},
        @{Left = 2; Right = 10},
        @{Left = "abc"; Right = "def"}
        @{Left = -1.0; Right = -99}        
    ) { 
        param ($Left, $Right) 
        
        Test-Equivalent -Expected $Left -Actual $Right | Verify-NotNull
    }

    It "Comparing the same instance of a psObject returns True"{ 
        $actual = $expected = New-PSObject @{ Name = 'Jakub' }
        Verify-Same -Expected $expected -Actual $actual

        Test-Equivalent -Expected $expected -Actual $actual | Verify-Null
    }

    It "Comparing different instances of a psObject returns $null when the objects have the same values" -TestCases @(
        @{
            Expected = New-PSObject @{ Name = 'Jakub' }
            Actual =   New-PSObject @{ Name = 'Jakub' } 
        },
        @{
            Expected = New-PSObject @{ Name = 'Jakub' } 
            Actual =   New-PSObject @{ Name = 'Jakub' } 
         },
        @{
            Expected = New-PSObject @{ Age = 28 } 
            Actual =   New-PSObject @{ Age = '28' } 
         },
        @{
            Expected = New-PSObject @{ Age = 28 } 
            Actual =   New-PSObject @{ Age = {28} } 
         }
    ) { 
        param ($Expected, $Actual)
        Verify-NotSame -Expected $expected -Actual $actual

        Test-Equivalent -Expected $expected -Actual $actual | Verify-Null
    }

    It "Comparing psObjects returns Report when the objects have different values" -TestCases @(
        @{
            Expected =  New-PSObject @{ Name = 'Jakub'; Age = 28 }
            Actual = New-PSObject @{ Name = 'Jakub'; Age = 19 } 
        },
        @{
            Expected =  New-PSObject @{ Name = 'Jakub'; Age = 28 } 
            Actual = New-PSObject @{ Name = 'Jakub'} 
         }
    ) { 
        param ($Expected, $Actual)
        Verify-NotSame -Expected $expected -Actual $actual

        Test-Equivalent -Expected $expected -Actual $actual | Verify-NotNull
    }

    Add-Type -TypeDefinition @"
    using System;

    namespace TestObjects {
        public class Person {
            public string Name {get;set;}
            public string Age {get;set;}
        }
    }
"@
    It "Comparing psObject with class returns $null when the objects have the same values" -TestCases @(
        @{
            Expected = New-Object -TypeName TestObjects.Person -Property @{ Name = 'Jakub'; Age  = 28}
            Actual =   New-PSObject @{ Name = 'Jakub'; Age = 28 } 
        }
    ) { 
        param ($Expected, $Actual)

        Test-Equivalent -Expected $expected -Actual $actual | Verify-Null
    }


    It "Comparing psObjects with collections returns report when the items in the collection differ" -TestCases @(
        @{
            Expected = New-PSObject @{ Numbers = 1,2,3 } 
            Actual =   New-PSObject @{ Numbers = 3,4,5 } 
        }
    ) { 
        param ($Expected, $Actual)

        Test-Equivalent -Expected $expected -Actual $actual | Verify-NotNull
    }

    It "Comparing psObjects with collections returns report when the items in the collection differ" -TestCases @(
        @{
            Expected = New-PSObject @{ Objects = (New-PSObject @{ Name = "Jan" }), (New-PSObject @{ Name = "Petr" }) }
            Actual =   New-PSObject @{ Objects = (New-PSObject @{ Name = "Jan" }), (New-PSObject @{ Name = "Tomas" }) }
        }
    ) { 
        param ($Expected, $Actual)

        Test-Equivalent -Expected $expected -Actual $actual | Verify-NotNull
    }
}

Describe "Test-Value" {
    It "Given value or string '<value>' it returns `$true" -TestCases @(
        @{ Value = 1 },
        @{ Value = 2 },
        @{ Value = 1.2 },
        @{ Value = 1.3 },
        @{ Value = "abc"},
        @{ Value = [System.DayOfWeek]::Monday}
    ){  
        param($Value)
        Test-Value -Value $Value | Verify-True
    }

    It "Given `$null it returns `$false" {
        Test-Value -Value $null | Verify-False
    }

    It "Given reference type (not string) '<value>' it returns `$false" -TestCases @(
        @{ Value = @() },
        @{ Value = @{} },
        @{ Value = {} },
        @{ Value = [type] },
        @{ Value = (New-Object -TypeName Diagnostics.Process) }
    ){  
        param($Value)
        Test-Value -Value $Value | Verify-False
    }
}

Describe "Test-Same" {
    It "Given the same instance of a reference type it returns `$true" -TestCases @(
        @{ Value = $null },
        @{ Value = @() },
        @{ Value = [Type] },
        @{ Value = (New-Object -TypeName Diagnostics.Process) }
    ){
        param($Value)
        Test-Same -Expected $Value -Actual $Value | Verify-True

    }

    It "Given different instances of a reference type it returns `$false" -TestCases @(
        @{ Actual = @(); Expected = @() },
        @{ Actual = (New-Object -TypeName Diagnostics.Process) ; Expected = (New-Object -TypeName Diagnostics.Process) }
    ){
        param($Expected, $Actual)
        Test-Same -Expected $Expected -Actual $Actual | Verify-False
    }
}


function Get-TestCase ($Value) {
    #let's see if this is useful, it's nice for values, but sucks for 
    #types that serialize to just the type name (most of them)
    if ($null -ne $Value)
    {
        @{
            Value = $Value
            Type = $Value.GetType()
        }
    }
    else 
    {
        @{
            Value = $null
            Type = '<none>'
        }
    }
}

Describe "Get-TestCase" {
    It "Given a value it returns the value and it's type in a hashtable" {
        $expected = @{
            Value = 1
            Type = [Int]
        }

        $actual = Get-TestCase -Value $expected.Value

        $actual.GetType().Name | Verify-Equal 'hashtable'
        $actual.Value | Verify-Equal $expected.Value
        $actual.Type | Verify-Equal $expected.Type
    }

    It "Given `$null it returns <none> as the name of the type" {
        $expected = @{
            Value = $null
            Type = 'none'
        }

        $actual = Get-TestCase -Value $expected.Value

        $actual.GetType().Name | Verify-Equal 'hashtable'
        $actual.Value | Verify-Null
        $actual.Type | Verify-Equal '<none>'
    }
}

Describe "Test-Collection" {
    It "Given a collection '<value>' of type '<type>' implementing IEnumerable it returns `$true" -TestCases @(
        (Get-TestCase "abc"),
        (Get-TestCase 1,2,3),
        (Get-TestCase ([Collections.Generic.List[Int]](1,2,3)))
    ) {
        param($Value)
        Test-Collection -Value $Value | Verify-True
    }

    It "Given an object '<value>' of type '<type>' that is not a collection it returns `$false" -TestCases @(
        (Get-TestCase 1),
        (Get-TestCase (New-Object -TypeName Diagnostics.Process))
    ) {
        param($Value)
        Test-Collection -Value $Value | Verify-False
    }
}

Describe "Test-ScriptBlock" { 
    It "Given a scriptblock '{<value>}' it returns `$true" -TestCases @(
        @{ Value = {} },
        @{ Value = {abc} },
        @{ Value = { Get-Process -Name Idle } }
    ) {
        param ($Value)
        Test-ScriptBlock -Value $Value | Verify-True 
    }

    It "Given a value '<value>' that is not a scriptblock it returns `$false" -TestCases @(
        @{ Value = $null },
        @{ Value = 1 },
        @{ Value = 'abc' },
        @{ Value = [Type] }
    ) {
        param ($Value)
        Test-ScriptBlock -Value $Value | Verify-False 
    }
}

Describe "Format-Collection" { 
    It "Formats collection of values '<value>' to '<expected>' using the default separator" -TestCases @(
        @{ Value = (1,2,3); Expected = "1, 2, 3" }
    ) { 
        param ($Value, $Expected)
        Format-Collection -Value $Value | Verify-Equal $Expected
    }

    It "Formats collection of values '<value>' to '<expected>' using the default separator" -TestCases @(
        @{ Value = (1,2,3); Expected = "1, 2, 3" }
    ) { 
        param ($Value, $Expected)
        Format-Collection -Value $Value | Verify-Equal $Expected
    }
}

Describe "Format-PSObject" {
    It "Formats PSObject '<value>' to '<expected>'" -TestCases @(
        @{ Value = (New-PSObject @{Name = 'Jakub'; Age = 28}); Expected = "PSObject{Age=28; Name=Jakub}" }
    ) { 
        param ($Value, $Expected)
        Format-PSObject -Value $Value | Verify-Equal $Expected
    }
}

Describe "Format-Object" {
    $null = Add-Type -TypeDefinition 'namespace Assertions.TestType { public class Person { public string Name {get;set;} public int Age {get;set;}}}'
    It "Formats object '<value>' to '<expected>'" -TestCases @(
        @{ Value = (New-PSObject @{Name = 'Jakub'; Age = 28}); Expected = "PSCustomObject{Age=28; Name=Jakub}"},
        @{ Value = (New-Object -Type Assertions.TestType.Person -Property @{Name = 'Jakub'; Age = 28}); Expected = "Person{Age=28; Name=Jakub}"}
    ) { 
        param ($Value, $Expected)
        Format-Object -Value $Value | Verify-Equal $Expected
    }

    It "Formats object '<value>' with selected properties '<selectedProperties>' to '<expected>'" -TestCases @(
        @{ Value = (New-PSObject @{Name = 'Jakub'; Age = 28}); SelectedProperties = "Age"; Expected = "PSCustomObject{Age=28}"},
        @{ Value = (Get-Process -Name Idle); SelectedProperties = 'Name','Id'; Expected = "Process{Id=0; Name=Idle}" },
        @{ 
            Value = (New-Object -Type Assertions.TestType.Person -Property @{Name = 'Jakub'; Age = 28})
            SelectedProperties = 'Name'
            Expected = "Person{Name=Jakub}"}
    ) { 
        param ($Value, $SelectedProperties, $Expected)
        Format-Object -Value $Value -Property $SelectedProperties | Verify-Equal $Expected
    }
}

Describe "Compare-Value" {
    It "Compares object to value with the correct message" { 
        $e = 'abc'
        $a = New-PSObject @{ Name = 'Jakub'; Age = 28 }
        Compare-Value -Actual $a  -Expected $e | Verify-Equal "Expected 'abc' but got 'PSObject{Age=28; Name=Jakub}'"
    }
}
