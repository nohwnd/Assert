function Test-EquivalentTo($Expected, $Actual) {    
    if ($Expected -eq $Actual) { 
      return
    }

    if ([object]::ReferenceEquals($Expected, $Actual)) {
        return 
    }

    if ($Expected -is [PsObject] -and $Actual -is [psObject])
    {
        $result = @()
        $e = $Expected.psObject.properties
        $a = $Actual.psObject.properties

        foreach ($property in $e)
        {
            $a[$property.Name]
            if ($a -notcontains $property) 
            {
                $result += "$property is missing from actual"
            }

            
        }
        return $different
    }

    return "values differ"
}

function Assert-Same ([switch]$Not, $Expected, $Actual)
{
    $passed = [Object]::ReferenceEquals($Expected, $Actual)

    if ($not) { $passed = -not $passed }

    if (-not $passed) 
    { 
        throw "not the same instance"
    }
}

function New-PSObject ([hashtable]$Property) {
    New-Object -TypeName PSObject -Property $Property
}

Describe 'Test-EquivalentTo' {   
    It "Comparing the same values: '<Left>' and '<Right>' returns $null" -TestCases @(
        @{Left = 1; Right = 1},
        @{Left = 2; Right = 2},
        @{Left = "abc"; Right = "abc"}
        @{Left = -1.0; Right = -1}        
    ) { 
        param ($Left, $Right) 
        
        Test-EquivalentTo -Expected $Left -Actual $Right | Verify-NullOrEmpty
    }

    It "Comparing different values: '<Left>' and '<Right>' values returns report" -TestCases @(
        @{Left = 1; Right = 7},
        @{Left = 2; Right = 10},
        @{Left = "abc"; Right = "def"}
        @{Left = -1.0; Right = -99}        
    ) { 
        param ($Left, $Right) 
        
        Test-EquivalentTo -Expected $Left -Actual $Right | Verify-NotNullOrEmpty
    }

    It "Comparing the same instance of a psObject returns True"{ 
        $actual = $expected = New-PSObject @{ Name = 'Jakub' }
        Assert-Same -Expected $expected -Actual $actual

        Test-EquivalentTo -Expected $expected -Actual $actual | Verify-NullOrEmpty
    }

    It "Comparing different instances of a psObject returns True when the object has the same values" -TestCases @(
        @{
            Expected =  New-PSObject @{ Name = 'Jakub' }
            Actual = New-PSObject @{ Name = 'Jakub' } 
        },
        @{
            Expected =  New-PSObject @{ Name = 'Jakub' } 
            Actual = New-PSObject @{ Name = 'Jakub' } 
         }
    ) { 
        param ($Expected, $Actual)
        Assert-Same -Not -Expected $expected -Actual $actual

        Test-EquivalentTo -Expected $expected -Actual $actual | Verify-NullOrEmpty
    }

    It "Comparing different instances of a psObject returns False when the object has different values" -TestCases @(
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
        Assert-Same -Not -Expected $expected -Actual $actual

        Test-EquivalentTo -Expected $expected -Actual $actual | Verify-NotNullOrEmpty
    }
}