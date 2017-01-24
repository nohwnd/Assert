function Test-Value ($Value) {
    $Value -is [ValueType] -or $Value -is [string]
}

function Test-Same ($Expected, $Actual) {
    [object]::ReferenceEquals($Expected, $Actual)
}

function Test-Collection ($Value) { 
    $Value -is [Array] -or $Value -is [Collections.IEnumerable]
}

function Test-ScriptBlock ($Value) {
    $Value -is [ScriptBlock]
}


function Format-Collection ($Value) { 
    $OFS = ', '
    "$Value"
}

function Format-PSObject ($Value) {
    [string]$Value -replace "^@","PSObject"
}

function Format-Object ($Value, $Property) {
    
    if ($null -eq $Property)
    {
        $Property = $Value.PSObject.Properties | select -ExpandProperty Name
    }
    $orderedProperty = $Property | Sort-Object
    ([string]([PSObject]$Value | Select-Object -Property $orderedProperty)) -replace "^@", ($Value.GetType().Name)
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

function Test-Equivalent ($Actual, $Expected) { 
    $result = @()
    if ((arePsObjects $actual $expected)) 
    {   
        if (Test-Same $actual $expected) {return}

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
        
            $r = Test-Equivalent $ep.Value $property.Value
            if ($r)
            {
                $result += "Property '$PropertyName' differs in $($ep.Value) and $($property.Value) $r"
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
    else # <-- add case where this is collection and then expand the collection and compare each item with each other item.
    {
        if ($expected -ne $actual) { 
            $result += "Expected '$expected' but got '$actual'"
        }
    }

    if ($result.Count -gt 0) {
        "The expected and actual objects are not equal. Got actual: `n`n$(($actual|fl|out-string).Trim())`n`n"+
        "and expected:`n`n$(($expected|fl|out-string).Trim())`n`nwith the following differences:`n`n$($result -join "`n")"
    }
}

function Assert-Equivalent($Actual, $Expected) {
    $areDifferent = Test-Equivalent $Actual $Expected
    if ($areDifferent)
    {
        throw [Assertions.AssertionException]"$areDifferent"
    }
}

#$actual = New-PSObject @{ Name = 'Jakub'; Age = 28; PlaysGames = $false }
#$expected = New-PSObject @{ Name = 'Jakub'; Age = "27"; DrinksCoffeeTooMuch = $true }


#Assert-DeepEqual $actual $expected


function Test-ValueEqual ($Expected) {
    if (Test-Value -eq $Expected) { 

    }
}