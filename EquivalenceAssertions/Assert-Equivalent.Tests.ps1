. $PSScriptRoot\Assert-Equivalent.ps1
. $PSScriptRoot\..\testHelpers.ps1

Describe 'Test-Equivalent' {   
    It "Comparing the same values: '<Left>' and '<Right>' returns $null" -TestCases @(
        @{Left = 1; Right = 1},
        @{Left = 2; Right = 2},
        @{Left = "abc"; Right = "abc"}
        @{Left = -1.0; Right = -1}        
    ) { 
        param ($Left, $Right) 
        
        Test-Equivalent -Expected $Left -Actual $Right | Verify-NullOrEmpty
    }

    It "Comparing different values: '<Left>' and '<Right>' values returns report" -TestCases @(
        @{Left = 1; Right = 7},
        @{Left = 2; Right = 10},
        @{Left = "abc"; Right = "def"}
        @{Left = -1.0; Right = -99}        
    ) { 
        param ($Left, $Right) 
        
        Test-Equivalent -Expected $Left -Actual $Right | Verify-NotNullOrEmpty
    }

    It "Comparing the same instance of a psObject returns True"{ 
        $actual = $expected = New-PSObject @{ Name = 'Jakub' }
        Verify-Same -Expected $expected -Actual $actual

        Test-Equivalent -Expected $expected -Actual $actual | Verify-NullOrEmpty
    }

    It "Comparing different instances of a psObject returns True when the object has the same values" -TestCases @(
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
        Verify-NotSame -Expected $expected -Actual $actual

        Test-Equivalent -Expected $expected -Actual $actual | Verify-NullOrEmpty
    }

    It "Comparing psObjects returns False when the objects have different values" -TestCases @(
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

        Test-Equivalent -Expected $expected -Actual $actual | Verify-NotNullOrEmpty
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
    It "Comparing psObject with class returns True when the object has the same values" -TestCases @(
        @{
            Expected = New-Object -TypeName TestObjects.Person -Property @{ Name = 'Jakub'; Age  = 28}
            Actual =   New-PSObject @{ Name = 'Jakub'; Age = 28 } 
        }
    ) { 
        param ($Expected, $Actual)
        Verify-NotSame -Expected $expected -Actual $actual

        Test-Equivalent -Expected $expected -Actual $actual | Verify-NullOrEmpty
    }
}

