. $PSScriptRoot\Assert-Equivalent.ps1
. $PSScriptRoot\..\testHelpers.ps1

Add-Type -TypeDefinition 'namespace Assertions.TestType { public class Person { public string Name {get;set;} public int Age {get;set;}}}'

Describe "Test-Value" {
    It "Given '<value>', which is a value, string, enum, scriptblock or array with a single item of those types it returns `$true" -TestCases @(
        @{ Value = 1 },
        @{ Value = 2 },
        @{ Value = 1.2 },
        @{ Value = 1.3 },
        @{ Value = "abc"},
        @{ Value = [System.DayOfWeek]::Monday},
        @{ Value = @("abc")},
        @{ Value = @(1)},
        @{ Value = {abc}}
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

Describe "Test-DecimalNumber" { 
    It "Given a number it returns `$true" -TestCases @(
        @{ Value = 1.1; },
        @{ Value = [double] 1.1; },
        @{ Value = [float] 1.1; },
        @{ Value = [single] 1.1; },
        @{ Value = [decimal] 1.1; }
    ) { 
        param ($Value)
        Test-DecimalNumber -Value $Value | Verify-True
    }

    It "Given a string it returns `$false" { 
        Test-DecimalNumber -Value "abc" | Verify-False
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

Describe "Format-ScriptBlock" { 
    It "Formats scriptblock as string with curly braces" {
        Format-ScriptBlock -Value {abc} | Verify-Equal '{abc}'
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
        @{ Value = 1.1; Expected = '1.1' },
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

    It "Returns correct message for given property" { 
        $e = 1
        $a = 2
        Get-ValueNotEquivalentMessage -Actual 1 -Expected 2 -Property ".Age" | 
            Verify-Equal "Expected property .Age with value '2' to be equivalent to the actual value, but got '1'."
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

Describe "Compare-Value" { 
    It "Given expected that is not a value it throws ArgumentException" {
        $err = { Compare-Value -Actual "dummy" -Expected (Get-Process idle) } | Verify-Throw 
        $err.Exception -is [ArgumentException] | Verify-True
    }

    It "Given values '<expected>' and '<actual>' that are not equivalent it returns message '<message>'." -TestCases @(
        @{ Actual = $null; Expected = 1; Message = "Expected '1' to be equivalent to the actual value, but got '`$null'." },
        @{ Actual = $null; Expected = ""; Message = "Expected '' to be equivalent to the actual value, but got '`$null'." },
        @{ Actual = $true; Expected = $false; Message = "Expected '`$false' to be equivalent to the actual value, but got '`$true'." },
        @{ Actual = $true; Expected = 'False'; Message = "Expected '`$false' to be equivalent to the actual value, but got '`$true'." },
        @{ Actual = 1; Expected = -1; Message = "Expected '-1' to be equivalent to the actual value, but got '1'." },
        @{ Actual = "1"; Expected = 1.01; Message = "Expected '1.01' to be equivalent to the actual value, but got '1'." },
        @{ Actual = "abc"; Expected = "a b c"; Message = "Expected 'a b c' to be equivalent to the actual value, but got 'abc'." },
        @{ Actual = @("abc", "bde"); Expected = "abc"; Message = "Expected 'abc' to be equivalent to the actual value, but got 'abc, bde'." },
        @{ Actual = {def}; Expected = "abc"; Message = "Expected 'abc' to be equivalent to the actual value, but got '{def}'." },
        @{ Actual = (New-PSObject @{ Name = 'Jakub' }); Expected = "abc"; Message = "Expected 'abc' to be equivalent to the actual value, but got 'PSObject{Name=Jakub}'." },
        @{ Actual = (1,2,3); Expected = "abc"; Message = "Expected 'abc' to be equivalent to the actual value, but got '1, 2, 3'." }
    ) {
        param($Actual, $Expected, $Message)
        Compare-Value -Actual $Actual -Expected $Expected | Verify-Equal $Message
    }
}

Describe "Compare-Collection" {
    It "Given expected that is not a collection it throws ArgumentException" {
        $err = { Compare-Collection -Actual "dummy" -Expected 1 } | Verify-Throw 
        $err.Exception -is [ArgumentException] | Verify-True
    }

    It "Given two collections '<expected>' '<actual>' of different sizes it returns message '<message>'" -TestCases @(
        @{ Actual = (1,2,3); Expected = (1,2,3,4); Message = "Expected collection '1, 2, 3, 4' with length '4' to be the same size as the actual collection, but got '1, 2, 3' with length '3'."},
        @{ Actual = (1,2,3); Expected = (3,1); Message = "Expected collection '3, 1' with length '2' to be the same size as the actual collection, but got '1, 2, 3' with length '3'." }
    ) {
        param ($Actual, $Expected, $Message)
        Compare-Collection -Actual $Actual -Expected $Expected | Verify-Equal $Message
    }

    It "Given collection '<expected>' on the expected side and non-collection '<actual>' on the actual side it prints the correct message '<message>'" -TestCases @(
        @{ Actual = 3; Expected = (1,2,3,4); Message = "Expected collection '1, 2, 3, 4' with length '4', but got '3'."},
        @{ Actual = (New-PSObject @{ Name = 'Jakub' }); Expected = (1,2,3,4); Message = "Expected collection '1, 2, 3, 4' with length '4', but got 'PSObject{Name=Jakub}'."}
    ) {
        param ($Actual, $Expected, $Message)
        Compare-Collection -Actual $Actual -Expected $Expected | Verify-Equal $Message
    }

    It "Given two collections '<expected>' '<actual>' it compares each value with each value and returns `$null if all of them are equivalent" -TestCases @(
        @{ Actual = (1,2,3); Expected = (1,2,3)},
        @{ Actual = (1,2,3); Expected = (3,2,1)}
    ) {
        param ($Actual, $Expected)
        Compare-Collection -Actual $Actual -Expected $Expected | Verify-Null
    }

    It "Given two collections '<expected>' '<actual>' it compares each value with each value and returns message '<message> if any of them are not equivalent" -TestCases @(
        @{ Actual = (1,2,3); Expected = (4,5,6); Message = "Expected collection '4, 5, 6' to be equivalent to '1, 2, 3' but some values were missing: '4, 5, 6'."},
        @{ Actual = (1,2,3); Expected = (1,2,2); Message = "Expected collection '1, 2, 2' to be equivalent to '1, 2, 3' but some values were missing: '2'."}
    ) {
        param ($Actual, $Expected, $Message)
        Compare-Collection -Actual $Actual -Expected $Expected | Verify-Equal $Message
    }
}

Describe "Compare-Object" {
    It "Given expected '<expected>' that is not an object it throws ArgumentException" -TestCases @(
        @{ Expected = "a" },
        @{ Expected = "1" },
        @{ Expected = { abc } },
        @{ Expected = (1,2,3) }
    ) { 
        param($Expected) {}
        $err = { Compare-Object -Actual "dummy" -Expected $Expected } | Verify-Throw 
        $err.Exception -is [ArgumentException] | Verify-True
    }

    It "Given values '<expected>' and '<actual>' that are not equivalent it returns message '<message>'." -TestCases @(
        @{ Actual = 'a'; Expected = (New-PSObject @{ Name = 'Jakub' }); Message = "Expected object 'PSObject{Name=Jakub}', but got 'a'."}
    ) { 
        param ($Actual, $Expected, $Message) 
        Compare-Object -Expected $Expected -Actual $Actual | Verify-Equal $Message
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
        Compare-EquivalentObject -Expected $Expected -Actual $Actual | Verify-Null
    }

    It "Given values '<expected>' and '<actual>' that are not equivalent it returns message '<message>'." -TestCases @(
        @{ Actual = $null; Expected = 1; Message = "Expected '1' to be equivalent to the actual value, but got '`$null'." },
        @{ Actual = $null; Expected = ""; Message = "Expected '' to be equivalent to the actual value, but got '`$null'." },
        @{ Actual = $true; Expected = $false; Message = "Expected '`$false' to be equivalent to the actual value, but got '`$true'." },
        @{ Actual = $true; Expected = 'False'; Message = "Expected '`$false' to be equivalent to the actual value, but got '`$true'." },
        @{ Actual = 1; Expected = -1; Message = "Expected '-1' to be equivalent to the actual value, but got '1'." },
        @{ Actual = "1"; Expected = 1.01; Message = "Expected '1.01' to be equivalent to the actual value, but got '1'." },
        @{ Actual = "abc"; Expected = "a b c"; Message = "Expected 'a b c' to be equivalent to the actual value, but got 'abc'." },
        @{ Actual = @("abc", "bde"); Expected = "abc"; Message = "Expected 'abc' to be equivalent to the actual value, but got 'abc, bde'." },
        @{ Actual = {def}; Expected = "abc"; Message = "Expected 'abc' to be equivalent to the actual value, but got '{def}'." },
        @{ Actual = "def"; Expected = {abc}; Message = "Expected '{abc}' to be equivalent to the actual value, but got 'def'." },
        @{ Actual = {abc}; Expected = {def}; Message = "Expected '{def}' to be equivalent to the actual value, but got '{abc}'." },
        @{ Actual = (1,2,3); Expected = (1,2,3,4); Message = "Expected collection '1, 2, 3, 4' with length '4' to be the same size as the actual collection, but got '1, 2, 3' with length '3'."},
        @{ Actual = 3; Expected = (1,2,3,4); Message = "Expected collection '1, 2, 3, 4' with length '4', but got '3'."},
        @{ Actual = (New-PSObject @{ Name = 'Jakub' }); Expected = (1,2,3,4); Message = "Expected collection '1, 2, 3, 4' with length '4', but got 'PSObject{Name=Jakub}'."},
        @{ Actual = (New-PSObject @{ Name = 'Jakub' }); Expected = "a"; Message = "Expected 'a' to be equivalent to the actual value, but got 'PSObject{Name=Jakub}'." },
         @{ Actual = 'a'; Expected = (New-PSObject @{ Name = 'Jakub' }); Message = "Expected object 'PSObject{Name=Jakub}', but got 'a'."}      
    ) { 
        param ($Actual, $Expected, $Message) 
        Compare-EquivalentObject -Expected $Expected -Actual $Actual | Verify-Equal $Message
    }

    It "Comparing the same instance of a psObject returns True"{ 
        $actual = $expected = New-PSObject @{ Name = 'Jakub' }
        Verify-Same -Expected $expected -Actual $actual

        $report = Compare-EquivalentObject -Expected $expected -Actual $actual | Verify-Null
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
        
        Compare-EquivalentObject -Expected $Expected -Actual $Actual | Verify-Null
    }

    It "Given PSObjects '<expected>' and '<actual> that have different values in some of the properties it returns message '<message>'" -TestCases @(
        @{
            Expected = New-PSObject @{ Name = 'Jakub'; Age = 28 }
            Actual = New-PSObject @{ Name = 'Jakub'; Age = 19 }
            Message = "Expected property .Age with value '28' to be equivalent to the actual value, but got '19'."
        },
        @{
            Expected = New-PSObject @{ Name = 'Jakub'; Age = 28 } 
            Actual = New-PSObject @{ Name = 'Jakub'}
            Message = "Expected has property 'Age' that the other object does not have." 
         },
         @{
            Expected = New-PSObject @{ Name = 'Jakub'} 
            Actual = New-PSObject @{ Name = 'Jakub'; Age = 28 }
            Message = "Expected is missing property 'Age' that the other object has." 
         }
    ) { 
        param ($Expected, $Actual, $Message)
        Verify-NotSame -Expected $Expected -Actual $Actual

        Compare-EquivalentObject -Expected $Expected -Actual $Actual | Verify-Equal $Message
    }

    It "Given PSObject '<expected>' and object '<actual> that have the same values it returns `$null" -TestCases @(
        @{
            Expected = New-Object -TypeName Assertions.TestType.Person -Property @{ Name = 'Jakub'; Age  = 28}
            Actual =   New-PSObject @{ Name = 'Jakub'; Age = 28 } 
        }
    ) { 
        param ($Expected, $Actual)
        Compare-EquivalentObject -Expected $Expected -Actual $Actual | Verify-Null
    }


    It "Given PSObjects '<expected>' and '<actual> that contain different arrays in the same property returns the correct message" -TestCases @(
        @{
            Expected = New-PSObject @{ Numbers = 1,2,3 } 
            Actual =   New-PSObject @{ Numbers = 3,4,5 } 
        }
    ) { 
        param ($Expected, $Actual)

        $report = Compare-EquivalentObject -Expected $Expected -Actual $Actual | Verify-Equal "Expected collection in property .Numbers which is '1, 2, 3' to be equivalent to '3, 4, 5' but some values were missing: '1, 2'."
    }

    It "Comparing psObjects that have collections of objects returns `$null when the objects have the same value" -TestCases @(
        @{
            Expected = New-PSObject @{ Objects = (New-PSObject @{ Name = "Jan" }), (New-PSObject @{ Name = "Tomas" }) }
            Actual =   New-PSObject @{ Objects = (New-PSObject @{ Name = "Tomas" }), (New-PSObject @{ Name = "Jan" }) }
        }
    ) { 
        param ($Expected, $Actual)
        Compare-EquivalentObject -Expected $Expected -Actual $Actual | Verify-Null
    }

    It "Comparing psObjects that have collections of objects returns the correct message when the items in the collection differ" -TestCases @(
        @{
            Expected = New-PSObject @{ Objects = (New-PSObject @{ Name = "Jan" }), (New-PSObject @{ Name = "Petr" }) }
            Actual =   New-PSObject @{ Objects = (New-PSObject @{ Name = "Jan" }), (New-PSObject @{ Name = "Tomas" }) }
        }
    ) { 
        param ($Expected, $Actual)
        Compare-EquivalentObject -Expected $Expected -Actual $Actual | Verify-Equal "Expected collection in property .Objects which is 'PSObject{Name=Jan}, PSObject{Name=Petr}' to be equivalent to 'PSObject{Name=Jan}, PSObject{Name=Tomas}' but some values were missing: 'PSObject{Name=Petr}'."
    }
}
