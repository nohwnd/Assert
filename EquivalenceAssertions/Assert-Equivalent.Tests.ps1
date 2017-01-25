. $PSScriptRoot\Assert-Equivalent.ps1
. $PSScriptRoot\..\testHelpers.ps1

Add-Type -TypeDefinition 'namespace Assertions.TestType { public class Person { public string Name {get;set;} public int Age {get;set;}}}'

Describe "Test-Value" {
    It "Given '<value>', which is a value, string, enum or array with a single item of those types it returns `$true" -TestCases @(
        @{ Value = 1 },
        @{ Value = 2 },
        @{ Value = 1.2 },
        @{ Value = 1.3 },
        @{ Value = "abc"},
        @{ Value = [System.DayOfWeek]::Monday},
        @{ Value = @("abc")},
        @{ Value = @(1)}
    ) {  
        param($Value)
        Test-Value -Value $Value | Verify-True
    }

    It "Given `$null it returns `$false" {
        Test-Value -Value $null | Verify-False
    }

    It "Given reference type (not string) '<value>' it returns `$false" -TestCases @(
        @{ Value = @() },
        @{ Value = @(1,2) },
        @{ Value = @{} },
        @{ Value = {} },
        @{ Value = [type] },
        @{ Value = (New-Object -TypeName Diagnostics.Process) }
    ) {  
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
    ) {
        param($Value)
        Test-Same -Expected $Value -Actual $Value | Verify-True

    }

    It "Given different instances of a reference type it returns `$false" -TestCases @(
        @{ Actual = @(); Expected = @() },
        @{ Actual = (New-Object -TypeName Diagnostics.Process) ; Expected = (New-Object -TypeName Diagnostics.Process) }
    ) {
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

Describe "Test-PSObjectExacly" { 
    It "Given a PSObject '{<value>}' it returns `$true" -TestCases @(
        @{ Value = New-PSObject @{ Name = 'Jakub' } },
        @{ Value = [PSCustomObject]@{ Name = 'Jakub'} }
    ) {
        param ($Value)
        Test-PSObjectExactly -Value $Value | Verify-True 
    }

    It "Given a value '<value>' that is not a PSObject it returns `$false" -TestCases @(
        @{ Value = $null },
        @{ Value = 1 },
        @{ Value = 'abc' },
        @{ Value = [Type] }
    ) {
        param ($Value)
        Test-PSObjectExactly -Value $Value | Verify-False 
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

Describe "Format-Custom" {
    It "Formats value '<value>' correctly to '<expected>'" -TestCases @(
        @{ Value = $null; Expected = '$null'}
        @{ Value = $true; Expected = '$true'}
        @{ Value = $false; Expected = '$false'}
        @{ Value = 'a' ; Expected = 'a'},
        @{ Value = 1; Expected = '1' },
        @{ Value = (1,2,3); Expected = '1, 2, 3' },
        @{ Value = New-PSObject @{ Name = "Jakub" }; Expected = 'PSObject{Name=Jakub}' },
        @{ Value = (Get-Process Idle); Expected = 'Process{Id=0; Name=Idle}'},
        @{ Value = (New-Object -Type Assertions.TestType.Person -Property @{Name = 'Jakub'; Age = 28}); Expected = "Person{Age=28; Name=Jakub}"}
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

Describe "Get-ValueNotEquivalentMessage" {
    It "Returns correct message when comparing value to an object" { 
        $e = 'abc'
        $a = New-PSObject @{ Name = 'Jakub'; Age = 28 }
        Get-ValueNotEquivalentMessage -Actual $a -Expected $e | 
            Verify-Equal "Expected 'abc' to be equivalent to the actual value, but got 'PSObject{Age=28; Name=Jakub}'."
    }

    It "Returns correct message when comparing object to a value" { 
        $e = New-PSObject @{ Name = 'Jakub'; Age = 28 }
        $a = 'abc'
        Get-ValueNotEquivalentMessage -Actual $a -Expected $e | 
            Verify-Equal "Expected 'PSObject{Age=28; Name=Jakub}' to be equivalent to the actual value, but got 'abc'."
    }

    It "Returns correct message when comparing value to an array" { 
        $e = 'abc'
        $a = 1,2,3
        Get-ValueNotEquivalentMessage -Actual $a -Expected $e | 
            Verify-Equal "Expected 'abc' to be equivalent to the actual value, but got '1, 2, 3'."
    }

    It "Returns correct message when comparing value to null" { 
        $e = 'abc'
        $a = $null
        Get-ValueNotEquivalentMessage -Actual $a -Expected $e | 
            Verify-Equal "Expected 'abc' to be equivalent to the actual value, but got '`$null'."
    }
}

Describe "Test-CollectionSize" {
    It "Given two collections '<expected>' '<actual>' of the same size it returns `$true" -TestCases @(
        @{ Actual = (1,2,3); Expected = (1,2,3)},
        @{ Actual = (1,2,3); Expected = (3,2,1)}
    ) {
        param ($Actual, $Expected)
        Test-CollectionSize -Actual $Actual -Expected $Expected | Verify-True
    }

    It "Given two collections '<expected>' '<actual>' of different sizes it returns `$false" -TestCases @(
        @{ Actual = (1,2,3); Expected = (1,2,3,4)},
        @{ Actual = (1,2,3); Expected = (1,2)}
        @{ Actual = (1,2,3); Expected = @()}
    ) {
        param ($Actual, $Expected)
        Test-CollectionSize -Actual $Actual -Expected $Expected | Verify-False
    }
}

Describe "Get-CollectionSizeNotTheSameMessage" {
    It "Given two collections of differrent sizes it returns the correct message" {
        Get-CollectionSizeNotTheSameMessage -Expected (1,2,3) -Actual (1,2) | Verify-Equal "Expected collection '1, 2, 3' with length '3' to be the same size as the actual collection, but got '1, 2' with length '2'."
    }
}

Describe "Compare-Collection" {
    It "Given two collections '<expected>' '<actual>' of different sizes it returns `$false" -TestCases @(
        @{ Actual = (1,2,3); Expected = (1,2,3)},
        @{ Actual = (1,2,3); Expected = (3,2,1)}
    ) {
        param ($Actual, $Expected)
        Compare-Collection -Actual $Actual -Expected $Expected | Verify-True
    }

    It "Given two collections '<expected>' '<actual>' it compares each value with each value and returns `$true if all of them are equivalent" -TestCases @(
        @{ Actual = (1,2,3); Expected = (1,2,3)},
        @{ Actual = (1,2,3); Expected = (3,2,1)}
    ) {
        param ($Actual, $Expected)
        Compare-Collection -Actual $Actual -Expected $Expected | Verify-True
    }

    It "Given two collections '<expected>' '<actual>' it compares each value with each value and returns `$false if any of them are not equivalent" -TestCases @(
        @{ Actual = (1,2,3); Expected = (4,5,6)},
        @{ Actual = (1,2,3); Expected = (1,2,2)},
        @{ Actual = (1,2,3); Expected = (3,2,1)}
    ) {
        param ($Actual, $Expected)
        Compare-Collection -Actual $Actual -Expected $Expected | Verify-False
    }
}

Describe "New-ComparisonReport" { 
    It "Given no values it returns empty report" { 
        $report = New-ComparisonReport

        #assertion roulette but I am fine with it
        $report.Actual | Verify-Null
        $report.ActualAdapted | Verify-Null
        $report.ActualFormatted | Verify-Equal ""

        $report.Expected | Verify-Null
        $report.ExpectedAdapted | Verify-Null
        $report.ExpectedFormatted | Verify-Equal ""

        $report.Equivalent = $false
        $report.Report | Verify-Equal -Expected ""
    }

    It "Given all value it returns populated report" { 
        $report = New-ComparisonReport -Actual "false" -ActualAdapted $false -ActualFormatted '$false' -Expected "false" -ExpectedAdapted $false -ExpectedFormatted '$false' -Equivalent $true -Report "result"

        #assertion roulette but I am fine with it
        $report.Actual | Verify-Equal 'false'
        $report.ActualAdapted | Verify-Equal $false
        $report.ActualFormatted | Verify-Equal '$false'

        $report.Expected | Verify-Equal 'false'
        $report.ExpectedAdapted | Verify-Equal $false
        $report.ExpectedFormatted | Verify-Equal '$false'

        $report.Equivalent = $true
        $report.Report | Verify-Equal "result"
    }
}

Describe "Compare-EquivalentObject" { 
    It "Given values '<expected>' and '<actual>' that are equivalent returns report with Equivalent set to `$true" -TestCases @(
        @{ Actual = $null; Expected = $null },
        @{ Actual = ""; Expected = "" },
        @{ Actual = $true; Expected = $true },
        @{ Actual = $true; Expected = 'True' },
        @{ Actual = 'True'; Expected = $true },
        @{ Actual = $false; Expected = 'False' },
        @{ Actual = 'False'; Expected = $false},
        @{ Actual = 1; Expected = 1 },
        @{ Actual = "1"; Expected = 1 },
        @{ Actual = "abc"; Expected = "abc" },
        @{ Actual = @("abc"); Expected = "abc" },
        @{ Actual = "abc"; Expected = @("abc") },
        @{ Actual = {abc}; Expected = "abc" },
        @{ Actual = "abc"; Expected = {abc} },
        @{ Actual = {abc}; Expected = {abc} }
    ) { 
        param ($Actual, $Expected) 
        $report = Compare-EquivalentObject -Expected $Expected -Actual $Actual 
        $report.Equivalent | Verify-True 
    }

    It "Given values '<expected>' and '<actual>' that are not equivalent it returns report with Equivalent set to `$false and " -TestCases @(
        @{ Actual = $null; Expected = 1 },
        @{ Actual = $null; Expected = "" },
        @{ Actual = $true; Expected = $false },
        @{ Actual = $true; Expected = 'False' },
        @{ Actual = 1; Expected = -1 },
        @{ Actual = "1"; Expected = 1.01 },
        @{ Actual = "abc"; Expected = "a b c" },
        @{ Actual = @("abc", "bde"); Expected = "abc" },
        @{ Actual = {def}; Expected = "abc" },
        @{ Actual = "def"; Expected = {abc} },
        @{ Actual = {abc}; Expected = {def} }       
    ) { 
        param ($Actual, $Expected) 
        $report = Compare-EquivalentObject -Expected $Expected -Actual $Actual 
        $report.Equivalent | Verify-False
    }

    It "Comparing the same instance of a psObject returns True"{ 
        $actual = $expected = New-PSObject @{ Name = 'Jakub' }
        Verify-Same -Expected $expected -Actual $actual

        $report = Compare-EquivalentObject -Expected $expected -Actual $actual 
        $report.Equivalent | Verify-True
    }

    It "Given PSObjects '<expected>' and '<actual> that are different instances but have the same values it returns report with Equivalent set to `$true" -TestCases @(
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
         }
    ) { 
        param ($Expected, $Actual)
        Verify-NotSame -Expected $Expected -Actual $Actual

        $report = Compare-EquivalentObject -Expected $Expected -Actual $Actual
        $report.Equivalent | Verify-True
    }

    It "Given PSObjects '<expected>' and '<actual> that have different values in some of the properties it returns report with Equivalent set to `$false" -TestCases @(
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
        Verify-NotSame -Expected $Expected -Actual $Actual

        $report = Compare-EquivalentObject -Expected $Expected -Actual $Actual
        $report.Equivalent | Verify-False
    }

    It "Given PSObject '<expected>' and object '<actual> that have the same values it returns report with Equivalent set to `$true" -TestCases @(
        @{
            Expected = New-Object -TypeName Assertions.TestType.Person -Property @{ Name = 'Jakub'; Age  = 28}
            Actual =   New-PSObject @{ Name = 'Jakub'; Age = 28 } 
        }
    ) { 
        param ($Expected, $Actual)

        $report = Compare-EquivalentObject -Expected $Expected -Actual $Actual
        $report.Equivalent | Verify-True
    }


    It "Given PSObjects '<expected>' and '<actual> that contain different arrays in the same property returns report with Equivalent set to `$false" -TestCases @(
        @{
            Expected = New-PSObject @{ Numbers = 1,2,3 } 
            Actual =   New-PSObject @{ Numbers = 3,4,5 } 
        }
    ) { 
        param ($Expected, $Actual)

        $report = Compare-EquivalentObject -Expected $Expected -Actual $Actual
        $report.Equivalent | Verify-False
    }

    It "Comparing psObjects with collections returns report when the items in the collection differ" -TestCases @(
        @{
            Expected = New-PSObject @{ Objects = (New-PSObject @{ Name = "Jan" }), (New-PSObject @{ Name = "Petr" }) }
            Actual =   New-PSObject @{ Objects = (New-PSObject @{ Name = "Jan" }), (New-PSObject @{ Name = "Tomas" }) }
        }
    ) { 
        param ($Expected, $Actual)

        $report = Compare-EquivalentObject -Expected $Expected -Actual $Actual
        $report.Equivalent | Verify-False
    }
}

Describe "Compare-Object" { 
    It "Given PSObjects '<expected>' and '<actual> that are different instances but have the same values it returns report with Equivalent set to `$true" -TestCases @(
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
         }
    ) { 
        param ($Expected, $Actual)
        Verify-NotSame -Expected $Expected -Actual $Actual

        $report = Compare-Object -Expected $Expected -Actual $Actual
        $report.Equivalent | Verify-True
    }

    It "Given PSObjects '<expected>' and '<actual> that have different values in some of the properties it returns report with Equivalent set to `$false" -TestCases @(
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
        Verify-NotSame -Expected $Expected -Actual $Actual

        $report =  -Expected $Expected -Actual $Actual
        $report.Equivalent | Verify-False
    }

    It "Given PSObject '<expected>' and object '<actual> that have the same values it returns report with Equivalent set to `$true" -TestCases @(
        @{
            Expected = New-Object -TypeName Assertions.TestType.Person -Property @{ Name = 'Jakub'; Age  = 28}
            Actual =   New-PSObject @{ Name = 'Jakub'; Age = 28 } 
        }
    ) { 
        param ($Expected, $Actual)

        $report =  -Expected $Expected -Actual $Actual
        $report.Equivalent | Verify-True
    }


    It "Given PSObjects '<expected>' and '<actual> that contain different arrays in the same property returns report with Equivalent set to `$false" -TestCases @(
        @{
            Expected = New-PSObject @{ Numbers = 1,2,3 } 
            Actual =   New-PSObject @{ Numbers = 3,4,5 } 
        }
    ) { 
        param ($Expected, $Actual)

        $report =  -Expected $Expected -Actual $Actual
        $report.Equivalent | Verify-False
    }

    It "Comparing psObjects with collections returns report when the items in the collection differ" -TestCases @(
        @{
            Expected = New-PSObject @{ Objects = (New-PSObject @{ Name = "Jan" }), (New-PSObject @{ Name = "Petr" }) }
            Actual =   New-PSObject @{ Objects = (New-PSObject @{ Name = "Jan" }), (New-PSObject @{ Name = "Tomas" }) }
        }
    ) { 
        param ($Expected, $Actual)

        $report =  -Expected $Expected -Actual $Actual
        $report.Equivalent | Verify-False
    }
}