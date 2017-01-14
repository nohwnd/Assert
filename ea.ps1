function isValue ($value) {
    $value -is [ValueType] -or $value -is [string]
}

function areSame ($left, $right) {
    [object]::ReferenceEquals($left, $right)
}

function arePsObjects ($value1, $value2) {
    $value1 -is [PsObject] -and $value1 -is [PsObject]
}

function equal ($left, $right) {
    $left -eq $right
}

function countProperties ([ System.Management.Automation.PSMemberInfoCollection[System.Management.Automation.PSPropertyInfo]] $value) { 
    $value | Measure-Object | select -ExpandProperty count
}

function Test-DeepEqual ($Actual, $Expected) { 
    $result = @()
    if ((arePsObjects $actual $expected)) 
    {   
        $a = $actual.PsObject.Properties
        $e = $expected.PsObject.Properties

        foreach ($property in $a)
        {
            $propertyName = $property.Name
            $ep = $e | Where { $_.Name -eq $propertyName}
            if (-not $ep)
            {
                $result += "Actual has property '$PropertyName' that the other object does not have"
                continue
            }
        
            if ($ep.Value -ne $property.Value)
            {
                $result += "Property '$PropertyName' differs in $($ep.Value) and $($property.Value)"
            }
        }

        #check if there are any extra expected object props
        $aNames = $a | select -expand name

        $eNotInActual =  $e | where {$aNames -notcontains $_.name }
            
        foreach ($no in $eNotInActual)
        {
            $result += "Expected has property '$($no.name)' that the other object does not have"
        }    
    }

    if ($result.Count -gt 0) {
        "The expected and actual objects are not equal. Got actual: `n`n$(($actual|fl|out-string).Trim())`n`n"+
        "and expected:`n`n$(($expected|fl|out-string).Trim())`n`nwith the following differences:`n`n$($result -join "`n")"
    }
}

function Assert-DeepEqual($Actual, $Expected) {
    $areDifferent = Test-DeepEqual $Actual $Expected
    if ($areDifferent)
    {
        throw [Assertions.AssertionException]"$areDifferent"
    }
}

$actual = New-PSObject @{ Name = 'Jakub'; Age = 28; PlaysGames = $false }
$expected = New-PSObject @{ Name = 'Jakub'; Age = "27"; DrinksCoffeeTooMuch = $true }


Assert-DeepEqual $actual $expected