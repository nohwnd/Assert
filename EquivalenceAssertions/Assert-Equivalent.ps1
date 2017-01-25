function Test-Value ($Value) {
    $Value = $($Value)
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

function Get-ValueNotEquivalentMessage ($Expected, $Actual) { 
    $Expected = Format-Custom -Value $Expected 
    $Actual = Format-Custom -Value $Actual

    "Expected '$Expected' to be equivalent to the actual value, but got '$Actual'."
}

function Format-Collection ($Value) { 
    $Value -join ', '
}

function Format-PSObject ($Value) {
    [string]$Value -replace "^@","PSObject"
}

function Format-Object ($Value, $Property) {
    
    if ($null -eq $Property)
    {
        $Property = $Value.PSObject.Properties | Select-Object -ExpandProperty Name
    }
    $orderedProperty = $Property | Sort-Object
    ([string]([PSObject]$Value | Select-Object -Property $orderedProperty)) -replace "^@", ($Value.GetType().Name)
}

function Format-Null {
    '$null'
}

function Format-Boolean ($Value) {
    '$' + $Value.ToString().ToLower()
}

function Format-Custom ($Value) { 
    if ($null -eq $Value) 
    { 
        return Format-Null -Value $Value
    }

    if ($Value -is [bool])
    {
        return Format-Boolean -Value $Value
    }

    if (Test-Value -Value $Value) 
    { 
        return $Value
    }

    # dictionaries? (they are IEnumerable so they must go befor collections)
    # hashtables?

    if (Test-Collection -Value $Value) 
    { 
        return Format-Collection -Value $Value
    }

    if (Test-PSObjectExactly -Value $Value)
    {
       
        return Format-PSObject -Value $Value
    }

    Format-Object -Value $Value -Property (Get-IdentityProperty ($Value.GetType()))
}

function Test-PSObjectExactly ($Value) { 
    if ($null -eq $Value) 
    {
        return $false
    } 

    $Value.GetType() -eq [System.Management.Automation.PSCustomObject]
}

function Get-IdentityProperty ([Type]$Type) {
    # this will become more advanced, basically something along the lines of:
    # foreach type, try constructing the type, and if it exists then check if the 
    # incoming type is assingable to the current type, if so then return the properties,
    # this way I can specify the map from the most concrete type to the least concrete type
    # and for types that do not exist
 
    $propertyMap = @{
        'System.Diagnostics.Process' = 'Id', 'Name'
    }
    
    $propertyMap[$Type.FullName]
}

function Test-CollectionSize ($Expected, $Actual) {
    return $Expected.Length -eq $Actual.Length
}

function Get-CollectionSizeNotTheSameMessage ($Actual, $Expected) {
    $expectedLength = $Expected.Length
    $actualLength = $Actual.Length
    $Expected = Format-Collection -Value $Expected
    $Actual = Format-Collection -Value $Actual
    "Expected collection '$Expected' with length '$expectedLength' to be the same size as the actual collection, but got '$Actual' with length '$actualLength'."
}

function Compare-Collection ($Expected, $Actual) {
    $true
}

function New-ComparisonReport {
    param(
        $Actual = $null, $ActualAdapted = $null, [string]$ActualFormatted = "", 
        $Expected = $null, $ExpectedAdapted = $null, [string]$ExpectedFormatted = "", 
        [bool]$Equivalent = $false,
        [string]$Report = ""
    ) 

    New-PSObject @{
        Actual = $Actual
        ActualAdapted = $ActualAdapted
        ActualFormatted = $ActualFormatted

        Expected = $Expected
        ExpectedAdapted = $ActualAdapted
        ExpectedFormatted = $ExpectedFormatted

        Equivalent = $Equivalent
        Report = $Report
    }
}

function Compare-Object ($Actual, $Expected) {
    $result = ""
    $a = $Actual.PsObject.Properties
    $e = $Expected.PsObject.Properties

    foreach ($property in $a)
    {
        $propertyName = $property.Name
        $ep = $e | Where { $_.Name -eq $propertyName}
        if (-not $ep)
        {
            $result += "Actual has property '$PropertyName' that the other object does not have"
            continue
        }
    
        #$r = Compare-EquivalentObject $ep.Value $property.Value
        if ($ep.Value -ne $property.value)
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

function Compare-EquivalentObject ($Actual, $Expected) { 
    #start by null checks to avoid implementing null handling
    #logic in the functions that follow
    if ($null -eq $Expected)
    {
        return New-ComparisonReport -Equivalent ($Expected -eq $Actual)
    }

    #fix that string 'false' becomes $true boolean
    if ($Actual -is [Bool] -and $Expected -is [string] -and "$Expected" -eq 'False') 
    {
        $Expected = $false
        return  New-ComparisonReport -Equivalent ($Expected -eq $Actual)
    }

    if ($Expected -is [Bool] -and $Actual -is [string] -and "$Actual" -eq 'False') 
    {
        $Actual = $false
        return  New-ComparisonReport -Equivalent ($Expected -eq $Actual)
    }

    #fix that scriptblocks are compared by reference
    if (Test-ScriptBlock -Value $Expected) 
    {
        #forcing scriptblock to serialize to string and then comparing that
        return New-ComparisonReport -Equivalent ("$Expected" -eq $Actual)
    }

    #test value types, strings, and single item arrays with values in them as values
    #expand the single item array to get to the value in it
    if (Test-Value -Value $Expected) 
    {
        $Expected = $($Expected)
        return New-ComparisonReport -Equivalent ($Expected -eq $Actual)
    }

    #are the same instance
    if (Test-Same -Expected $Expected -Actual $Actual) 
    { 
        return New-ComparisonReport -Equivalent $true
    }

    #compare collection first
    # if (Test-Collection -Value $Expected) { 
    #    return Compare-Collection -Expected $Expected -Actual $Actual
    # }

    # dictionaries? (they are IEnumerable so they must go befor collections)
    # hashtables?

    # if (Test-Collection -Value $Value) 
    # { 
    #     return Format-Collection -Value $Value
    # }

    # if (Test-PSObjectExactly -Value $Value)
    # {
       
    #     return Format-PSObject -Value $Value
    # }

    # Format-Object -Value $Value -Property (Get-IdentityProperty ($Value.GetType()))
    #object comparisons from here on

    #here we got object on the expected side but what about the actual side? 
    
    # if (Test-Value -Value $Actual) {
    #     #Actual is value print message that says that we got value vs object and that they are different
    # }

    #same for collection

    #same for dictionary

    #here we have two distinct objects that we need to compare (ehm finally)
    Compare-Object -Expected $Expected -Actual $Actual
}

function arePsObjects ($value1, $value2) {
    $value1 -is [PsObject] -and $value1 -is [PsObject]
}

function equal ($left, $right) {
    $left -eq $right
}

function countProperties ([ System.Management.Automation.PSMemberInfoCollection[System.Management.Automation.PSPropertyInfo]] $value) { 
    if (Test-Collection -value $Expected) { 
        $value | Measure-Object | select -ExpandProperty count
    }
}

function Test-Equivalent ($Actual, $Expected) { 
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

    # if ($result.Count -gt 0) {
    #     "The expected and actual objects are not equal. Got actual: `n`n$(($actual|fl|out-string).Trim())`n`n"+
    #     "and expected:`n`n$(($expected|fl|out-string).Trim())`n`nwith the following differences:`n`n$($result -join "`n")"
    # }
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
