function Test-Same ($Expected, $Actual) {
    [object]::ReferenceEquals($Expected, $Actual)
}

function Is-CollectionSize ($Expected, $Actual) {
    if ($Expected.Length -is [Int] -and $Actual.Length -is [Int]) {
        return $Expected.Length -eq $Actual.Length
    }
    else {
        return $Expected.Count -eq $Actual.Count
    }
}

function Is-DataTableSize ($Expected, $Actual) {
        return $Expected.Rows.Count -eq $Actual.Rows.Count
}

function Get-ValueNotEquivalentMessage ($Expected, $Actual, $Property) {
    $Expected = Format-Nicely -Value $Expected
    $Actual = Format-Nicely -Value $Actual
    $propertyInfo = if ($Property) { " property $Property with value" }
    "Expected$propertyInfo '$Expected' to be equivalent to the actual value, but got '$Actual'."
}


function Get-CollectionSizeNotTheSameMessage ($Actual, $Expected, $Property) {
    $expectedLength = if ($Expected.Length -is [int]) {$Expected.Length} else {$Expected.Count}
    $actualLength = if ($Actual.Length -is [int]) {$Actual.Length} else {$Actual.Count}
    $Expected = Format-Collection -Value $Expected
    $Actual = Format-Collection -Value $Actual

    $propertyMessage = $null
    if ($property) {
        $propertyMessage = " in property $Property with values"
    }
    "Expected collection$propertyMessage '$Expected' with length '$expectedLength' to be the same size as the actual collection, but got '$Actual' with length '$actualLength'."
}

function Get-DataTableSizeNotTheSameMessage ($Actual, $Expected, $Property) {
    $expectedLength = $Expected.Rows.Count
    $actualLength = $Actual.Rows.Count
    $Expected = Format-Collection -Value $Expected
    $Actual = Format-Collection -Value $Actual

    $propertyMessage = $null
    if ($property) {
        $propertyMessage = " in property $Property with values"
    }
    "Expected DataTable$propertyMessage '$Expected' with length '$expectedLength' to be the same size as the actual DataTable, but got '$Actual' with length '$actualLength'."
}

function Compare-CollectionEquivalent ($Expected, $Actual, $Property) {
    if (-not (Is-Collection -Value $Expected))
    {
        throw [ArgumentException]"Expected must be a collection."
    }

    if (-not (Is-Collection -Value $Actual))
    {
        $expectedFormatted = Format-Collection -Value $Expected
        $expectedLength = $expected.Length
        $actualFormatted = Format-Nicely -Value $actual
        return "Expected collection '$expectedFormatted' with length '$expectedLength', but got '$actualFormatted'."
    }

    if (-not (Is-CollectionSize -Expected $Expected -Actual $Actual)) {
        return Get-CollectionSizeNotTheSameMessage -Expected $Expected -Actual $Actual -Property $Property
    }

    $eEnd = if ($Expected.Length -is [int]) {$Expected.Length} else {$Expected.Count}
    $aEnd = if ($Actual.Length -is [int]) {$Actual.Length} else {$Actual.Count}
    $taken = @()
    $notFound = @()
    for ($e=0; $e -lt $eEnd; $e++) {
        $currentExpected = $Expected[$e]
        $found = $false
        if ($StrictOrder) {
            $currentActual = $Actual[$e]
            if ((-not (Compare-Equivalent -Expected $currentExpected -Actual $currentActual -Path $Property)) -and $taken -notcontains $e)
            {
                $taken += $e
                $found = $true
            }
        }
        else {
            for ($a=0; $a -lt $aEnd; $a++) {
                $currentActual = $Actual[$a]
                if ((-not (Compare-Equivalent -Expected $currentExpected -Actual $currentActual -Path $Property)) -and $taken -notcontains $a)
                {
                    $taken += $a
                    $found = $true
                }
            }
        }
        if (-not $found)
        {
            $notFound += $currentExpected
        }
    }
    $Expected = Format-Nicely -Value $Expected
    $Actual = Format-Nicely -Value $Actual
    $notFoundFormatted = Format-Nicely -Value ( $notFound | % { Format-Nicely -Value $_ } )

    if ($notFound) {
        $propertyMessage = if ($Property) {" in property $Property which is"}
        return "Expected collection$propertyMessage '$Expected' to be equivalent to '$Actual' but some values were missing: '$notFoundFormatted'."
    }
}

function Compare-DataTableEquivalent ($Expected, $Actual, $Property) {
    if (-not (Is-DataTable -Value $Expected)) {
        throw [ArgumentException]"Expected must be a DataTable."
    }

    if (-not (Is-DataTable -Value $Actual)) {
        $expectedFormatted = Format-Collection -Value $Expected
        $expectedLength = $expected.Rows.Count
        $actualFormatted = Format-Nicely -Value $actual
        return "Expected DataTable '$expectedFormatted' with length '$expectedLength', but got '$actualFormatted'."
    }

    if (-not (Is-DataTableSize -Expected $Expected -Actual $Actual)) {
        return Get-DataTableSizeNotTheSameMessage -Expected $Expected -Actual $Actual -Property $Property
    }

    $eEnd = $Expected.Rows.Count
    $aEnd = $Actual.Rows.Count
    $taken = @()
    $notFound = @()
    for ($e = 0; $e -lt $eEnd; $e++) {
        $currentExpected = $Expected.Rows[$e]
        $found = $false
        if ($StrictOrder) {
            $currentActual = $Actual.Rows[$e]
            if ((-not (Compare-Equivalent -Expected $currentExpected -Actual $currentActual -Path $Property)) -and $taken -notcontains $e) {
                $taken += $e
                $found = $true
            }
        }
        else {
            for ($a = 0; $a -lt $aEnd; $a++) {
                $currentActual = $Actual.Rows[$a]
                if ((-not (Compare-Equivalent -Expected $currentExpected -Actual $currentActual -Path $Property)) -and $taken -notcontains $a) {
                    $taken += $a
                    $found = $true
                }
            }
        }
        if (-not $found) {
            $notFound += $currentExpected
        }
    }
    $Expected = Format-Nicely -Value $Expected
    $Actual = Format-Nicely -Value $Actual
    $notFoundFormatted = Format-Nicely -Value ( $notFound | % { Format-Nicely -Value $_ } )

    if ($notFound) {
        $propertyMessage = if ($Property) {" in property $Property which is"}
        return "Expected DataTable$propertyMessage '$Expected' to be equivalent to '$Actual' but some values were missing: '$notFoundFormatted'."
    }
}

function Compare-ValueEquivalent ($Actual, $Expected, $Property) {
    $Expected = $($Expected)
    if (-not (Is-Value -Value $Expected))
    {
        throw [ArgumentException]"Expected must be a Value."
    }

    if ($Expected.Psobject.TypeNames[0] -like '*System.DBNull' -and $null -ne $Actual -and $Actual.Psobject.TypeNames[0] -like '*System.DBNull' )
    {
        return
    }

    if ($StrictType -and $Actual -isnot $Expected.GetType())
    {
        $Expected = '[{0}]{1}' -f $Expected.GetType(), $Expected
        $Actual = '[{0}]{1}' -f $Actual.GetType(), $Actual
        Get-ValueNotEquivalentMessage -Expected $Expected -Actual $Actual -Property $Property
        return
    }

     #fix that string 'false' becomes $true boolean
    if ($Actual -is [Bool] -and $Expected -is [string] -and "$Expected" -eq 'False')
    {
        $Expected = $false
        if ($Expected -ne $Actual)
        {
            Get-ValueNotEquivalentMessage -Expected $Expected -Actual $Actual -Property $Property
        }
        return
    }

    if ($Expected -is [Bool] -and $Actual -is [string] -and "$Actual" -eq 'False')
    {
        $Actual = $false
        if ($Expected -ne $Actual)
        {
            Get-ValueNotEquivalentMessage -Expected $Expected -Actual $Actual -Property $Property
        }
        return
    }

    #fix that scriptblocks are compared by reference
    if (Is-ScriptBlock -Value $Expected)
    {
        #forcing scriptblock to serialize to string and then comparing that
        if ("$Expected" -ne $Actual)
        {
            Get-ValueNotEquivalentMessage -Expected $Expected -Actual $Actual -Property $Path
        }
        return
    }

    if ($Expected -ne $Actual)
    {
        Get-ValueNotEquivalentMessage -Expected $Expected -Actual $Actual -Property $Property
    }
}

function Compare-HashtableEquivalent ($Actual, $Expected, $Property) {
    if (-not (Is-Hashtable -Value $Expected))
    {
        throw [ArgumentException]"Expected must be a hashtable."
    }

    if (-not (Is-Hashtable -Value $Actual))
    {
        $expectedFormatted = Format-Nicely -Value $Expected
        $actualFormatted = Format-Nicely -Value $Actual
        return "Expected hashtable '$expectedFormatted', but got '$actualFormatted'."
    }

    $actualKeys = $Actual.Keys
    $expectedKeys = $Expected.Keys

    $result = @()
    foreach ($k in $expectedKeys)
    {
        $actualHasKey = $actualKeys -contains $k
        if (-not $actualHasKey)
        {
            $result += "Expected has key '$k' that the other object does not have."
            continue
        }

        $expectedValue = $Expected[$k]
        $actualValue = $Actual[$k]

        $result += Compare-Equivalent -Expected $expectedValue -Actual $actualValue -Path "$Property.$k"
    }

    $keysNotInExpected =  $actualKeys | where {$expectedKeys -notcontains $_ }
    foreach ($k in $keysNotInExpected)
    {
        $result += "Expected is missing key '$k' that the other object has."
    }

    if ($result)
    {
        $expectedFormatted = Format-Nicely -Value $Expected
        $actualFormatted = Format-Nicely -Value $Actual
        "Expected hashtable '$expectedFormatted', but got '$actualFormatted'.`n$($result -join "`n")"
    }
}

function Compare-DictionaryEquivalent ($Actual, $Expected, $Property) {
    if (-not (Is-Dictionary -Value $Expected))
    {
        throw [ArgumentException]"Expected must be a dictionary."
    }

    if (-not (Is-Dictionary -Value $Actual))
    {
        $expectedFormatted = Format-Nicely -Value $Expected
        $actualFormatted = Format-Nicely -Value $Actual
        return "Expected dictionary '$expectedFormatted', but got '$actualFormatted'."
    }

    $actualKeys = $Actual.Keys
    $expectedKeys = $Expected.Keys

    $result = @()
    foreach ($k in $expectedKeys)
    {
        $actualHasKey = $actualKeys -contains $k
        if (-not $actualHasKey)
        {
            $result += "Expected has key '$k' that the other object does not have."
            continue
        }

        $expectedValue = $Expected[$k]
        $actualValue = $Actual[$k]

        $result += Compare-Equivalent -Expected $expectedValue -Actual $actualValue -Path "$Property.$k"
    }

    $keysNotInExpected =  $actualKeys | where {$expectedKeys -notcontains $_ }
    foreach ($k in $keysNotInExpected)
    {
        $result += "Expected is missing key '$k' that the other object has."
    }

    if ($result)
    {
        $expectedFormatted = Format-Nicely -Value $Expected
        $actualFormatted = Format-Nicely -Value $Actual
        "Expected dictionary '$expectedFormatted', but got '$actualFormatted'.`n$($result -join "`n")"
    }
}

function Compare-ObjectEquivalent ($Actual, $Expected, $Property) {

    if (-not (Is-Object -Value $Expected))
    {
        throw [ArgumentException]"Expected must be an object."
    }

    if (-not (Is-Object -Value $Actual)) {
        $expectedFormatted = Format-Nicely -Value $Expected
        $actualFormatted = Format-Nicely -Value $Actual
        return "Expected object '$expectedFormatted', but got '$actualFormatted'."
    }

    $actualProperties = $Actual.PsObject.Properties
    $expectedProperties = $Expected.PsObject.Properties

    foreach ($p in $expectedProperties)
    {
        $propertyName = $p.Name
        $actualProperty = $actualProperties | Where { $_.Name -eq $propertyName}
        if (-not $actualProperty)
        {
            "Expected has property '$PropertyName' that the other object does not have."
            continue
        }

        Compare-Equivalent -Expected $p.Value -Actual $actualProperty.Value -Path "$Property.$propertyName"
    }

    #check if there are any extra actual object props
    $expectedPropertyNames = $expectedProperties | select -ExpandProperty Name

    $propertiesNotInExpected =  $actualProperties | where {$expectedPropertyNames -notcontains $_.name }

    foreach ($p in $propertiesNotInExpected)
    {
        "Expected is missing property '$($p.Name)' that the other object has."
    }
}

function Compare-DataRowEquivalent ($Actual, $Expected, $Property) {

    if (-not (Is-DataRow -Value $Expected))
    {
        throw [ArgumentException]"Expected must be a DataRow."
    }

    if (-not (Is-DataRow -Value $Actual)) {
        $expectedFormatted = Format-Nicely -Value $Expected
        $actualFormatted = Format-Nicely -Value $Actual
        return "Expected DataRow '$expectedFormatted', but got '$actualFormatted'."
    }

    $actualProperties = $Actual.PsObject.Properties | Where-Object Name -NotIn 'RowError','RowState','Table','ItemArray','HasErrors'
    $expectedProperties = $Expected.PsObject.Properties | Where-Object Name -NotIn 'RowError','RowState','Table','ItemArray','HasErrors'

    foreach ($p in $expectedProperties)
    {
        $propertyName = $p.Name
        $actualProperty = $actualProperties | Where { $_.Name -eq $propertyName}
        if (-not $actualProperty)
        {
            "Expected has property '$PropertyName' that the other object does not have."
            continue
        }

        Compare-Equivalent -Expected $p.Value -Actual $actualProperty.Value -Path "$Property.$propertyName"
    }

    #check if there are any extra actual object props
    $expectedPropertyNames = $expectedProperties | select -ExpandProperty Name

    $propertiesNotInExpected =  $actualProperties | where {$expectedPropertyNames -notcontains $_.name }

    foreach ($p in $propertiesNotInExpected)
    {
        "Expected is missing property '$($p.Name)' that the other object has."
    }
}

function Compare-Equivalent ($Actual, $Expected, $Path) {

    #start by null checks to avoid implementing null handling
    #logic in the functions that follow
    if ($null -eq $Expected)
    {
        if ($Expected -ne $Actual)
        {
           Get-ValueNotEquivalentMessage -Expected $Expected -Actual $Actual -Property $Path
        }
        return
    }

    #test value types, strings, and single item arrays with values in them as values
    #expand the single item array to get to the value in it
    if (Is-Value -Value $Expected)
    {
        Compare-ValueEquivalent -Actual $Actual -Expected $Expected -Property $Path
        return
    }

    #are the same instance
    if (Test-Same -Expected $Expected -Actual $Actual)
    {
        return
    }

    if (Is-Hashtable -Value $Expected)
    {
        Compare-HashtableEquivalent -Expected $Expected -Actual $Actual -Property $Path
        return
    }

    # dictionaries? (they are IEnumerable so they must go before collections)
    if (Is-Dictionary -Value $Expected)
    {
        Compare-DictionaryEquivalent -Expected $Expected -Actual $Actual -Property $Path
        return
    }

    #compare DataTable
    if (Is-DataTable -Value $Expected) {
        Compare-DataTableEquivalent -Expected $Expected -Actual $Actual -Property $Path
        return
    }

    #compare collection
    if (Is-Collection -Value $Expected) {
        Compare-CollectionEquivalent -Expected $Expected -Actual $Actual -Property $Path
        return
    }

    #compare DataRow
    if (Is-DataRow -Value $Expected) {
        Compare-DataRowEquivalent -Expected $Expected -Actual $Actual -Property $Path
        return
    }

    Compare-ObjectEquivalent -Expected $Expected -Actual $Actual -Property $Path
}

function Assert-Equivalent($Actual, $Expected, [Switch]$StrictOrder, [Switch]$StrictType) {
    $Option = $null
    $areDifferent = Compare-Equivalent -Actual $Actual -Expected $Expected | Out-String
    if ($areDifferent)
    {
        $message = Get-AssertionMessage -Actual $actual -Expected $Expected -Option $Option -Pretty -CustomMessage "Expected and actual are not equivalent!`nExpected:`n<expected>`n`nActual:`n<actual>`n`nSummary:`n$areDifferent`n<options>"
        throw [Assertions.AssertionException]$message
    }
}