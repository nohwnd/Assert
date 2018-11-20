$script:differenceCount = 0
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
        v -Difference "`$Actual is not a collection it is a $(Format-Nicely ($Actual.GetType())), so they are not equivalent."
        $expectedFormatted = Format-Collection -Value $Expected
        $expectedLength = $expected.Length
        $actualFormatted = Format-Nicely -Value $actual
        return "Expected collection '$expectedFormatted' with length '$expectedLength', but got '$actualFormatted'."
    }

    if (-not (Is-CollectionSize -Expected $Expected -Actual $Actual)) {
        v -Difference "`$Actual does not have the same size ($($Actual.Length)) as `$Expected ($($Expected.Length)) so they are not equivalent."
        return Get-CollectionSizeNotTheSameMessage -Expected $Expected -Actual $Actual -Property $Property
    }

    $eEnd = if ($Expected.Length -is [int]) {$Expected.Length} else {$Expected.Count}
    $aEnd = if ($Actual.Length -is [int]) {$Actual.Length} else {$Actual.Count}
    v "Comparing items in collection, `$Expected has lenght $eEnd, `$Actual has length $aEnd."
    $taken = @()
    $notFound = @()
    for ($e=0; $e -lt $eEnd; $e++) {
        v "`nSearching for `$Expected[$e]:"
        $currentExpected = $Expected[$e]
        $found = $false
        if ($StrictOrder) {
            $currentActual = $Actual[$e]
            if ((-not (Compare-Equivalent -Expected $currentExpected -Actual $currentActual -Path $Property)) -and $taken -notcontains $e)
            {
                $taken += $e
                $found = $true
                v -Equivalence "`Found `$Expected[$e]."
            }
        }
        else {
            for ($a=0; $a -lt $aEnd; $a++) {
                $currentActual = $Actual[$a]
                if ((-not (Compare-Equivalent -Expected $currentExpected -Actual $currentActual -Path $Property)) -and $taken -notcontains $a)
                {
                    $taken += $a
                    $found = $true
                    v -Equivalence "`Found `$Expected[$e]."
                }
            }
        }
        if (-not $found)
        {
            v -Difference "`$Actual does not contain `$Expected[$e]."
            $notFound += $currentExpected
        }
    }
    $Expected = Format-Nicely -Value $Expected
    $Actual = Format-Nicely -Value $Actual
    $notFoundFormatted = Format-Nicely -Value ( $notFound | % { Format-Nicely -Value $_ } )

    if ($notFound) {
        v -Difference "`$Actual and `$Expected arrays are not equivalent."
        $propertyMessage = if ($Property) {" in property $Property which is"}
        return "Expected collection$propertyMessage '$Expected' to be equivalent to '$Actual' but some values were missing: '$notFoundFormatted'."
    }
    v -Equivalence "`$Actual and `$Expected arrays are equivalent."
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

    # fix that string 'false' becomes $true boolean
    if ($Actual -is [Bool] -and $Expected -is [string] -and "$Expected" -eq 'False')
    {
        v "`$Actual is a boolean, and `$Expected is a 'False' string, which we consider equivalent to boolean `$false. Setting `$Expected to `$false."
        $Expected = $false
        if ($Expected -ne $Actual)
        {
            v -Difference "`$Actual is not equivalent to $(Format-Nicely $Expected) because it is $(Format-Nicely $Actual)."
            return Get-ValueNotEquivalentMessage -Expected $Expected -Actual $Actual -Property $Property
        }
        v -Equivalence "`$Actual is equivalent to $(Format-Nicely $Expected) because it is $(Format-Nicely $Actual)."
        return
    }

    if ($Expected -is [Bool] -and $Actual -is [string] -and "$Actual" -eq 'False')
    {
        v "`$Actual is a 'False' string, which we consider equivalent to boolean `$false. `$Expected is a boolean. Setting `$Actual to `$false."
        $Actual = $false
        if ($Expected -ne $Actual)
        {
            v -Difference "`$Actual is not equivalent to $(Format-Nicely $Expected) because it is $(Format-Nicely $Actual)."
            return Get-ValueNotEquivalentMessage -Expected $Expected -Actual $Actual -Property $Property
        }
        v -Equivalence "`$Actual is equivalent to $(Format-Nicely $Expected) because it is $(Format-Nicely $Actual)."
        return
    }

    #fix that scriptblocks are compared by reference
    if (Is-ScriptBlock -Value $Expected)
    {
        # todo: compare by equivalency like strings?
        v "`$Expected is a ScriptBlock, scriptblocks are considered equivalent when their content is equal. Converting `$Expected to string."
        #forcing scriptblock to serialize to string and then comparing that
        if ("$Expected" -ne $Actual)
        {
            # todo: difference on index?
            v -Difference "`$Actual is not equivalent to `$Expected because their contents differ."
            return Get-ValueNotEquivalentMessage -Expected $Expected -Actual $Actual -Property $Path
        }
        v -Equivalence "`$Actual is equivalent to `$Expected because their contents are equal."
        return
    }

    v "Comparing values as $(Format-Nicely ($Expected.GetType())) because `$Expected has that type."
    # todo: shorter messages when both sides have the same type (do not compare by using -is, instead query the type and compare it) because -is is true even for parent types
    $type = $Expected.GetType()
    $coalescedActual = $Actual -as $type
    if ($Expected -ne $Actual)
    {
        v -Difference "`$Actual is not equivalent to $(Format-Nicely $Expected) because it is $(Format-Nicely $Actual), and $(Format-Nicely $Actual) coalesced to $(Format-Nicely $type) is $(Format-Nicely $coalescedActual)."
        return Get-ValueNotEquivalentMessage -Expected $Expected -Actual $Actual -Property $Property
    }
    v -Equivalence "`$Actual is equivalent to $(Format-Nicely $Expected) because it is $(Format-Nicely $Actual), and $(Format-Nicely $Actual) coalesced to $(Format-Nicely $type) is $(Format-Nicely $coalescedActual)."
}

function Compare-HashtableEquivalent ($Actual, $Expected, $Property) {
    if (-not (Is-Hashtable -Value $Expected))
    {
        throw [ArgumentException]"Expected must be a hashtable."
    }

    if (-not (Is-Hashtable -Value $Actual))
    {
        v -Difference "`$Actual is not a hashtable it is a $(Format-Nicely ($Actual.GetType())), so they are not equivalent."
        $expectedFormatted = Format-Nicely -Value $Expected
        $actualFormatted = Format-Nicely -Value $Actual
        return "Expected hashtable '$expectedFormatted', but got '$actualFormatted'."
    }
    
    # todo: if either side or both sides are empty hashtable make the verbose output shorter and nicer

    $actualKeys = $Actual.Keys
    $expectedKeys = $Expected.Keys

    v "`Comparing all ($($expectedKeys.Count)) keys from `$Expected to keys in `$Actual."
    $result = @()
    foreach ($k in $expectedKeys)
    {
        $actualHasKey = $actualKeys -contains $k
        if (-not $actualHasKey)
        {   
            v -Difference "`$Actual is missing key '$k'."
            $result += "Expected has key '$k' that the other object does not have."
            continue
        }

        $expectedValue = $Expected[$k]
        $actualValue = $Actual[$k]
        v "Both `$Actual and `$Expected have key '$k', comparing thier contents."
        $result += Compare-Equivalent -Expected $expectedValue -Actual $actualValue -Path "$Property.$k"
    }

    $keysNotInExpected = $actualKeys | where {$expectedKeys -notcontains $_ }
    if ($keysNotInExpected) {
        v -Difference "`$Actual has $($keysNotInExpected.Count) keys that were not found on `$Expected: $(Format-Nicely @($keysNotInExpected))."
    }
    else {
        v "`$Actual has no keys that we did not find on `$Expected."
    }
    foreach ($k in $keysNotInExpected)
    {
        $result += "Expected is missing key '$k' that the other object has."
    }

    if ($result)
    {
        v -Difference "Hastables `$Actual and `$Expected are not equivalent."
        $expectedFormatted = Format-Nicely -Value $Expected
        $actualFormatted = Format-Nicely -Value $Actual
        return "Expected hashtable '$expectedFormatted', but got '$actualFormatted'.`n$($result -join "`n")"
    }
    v -Equivalence "Hastables `$Actual and `$Expected are equivalent."
}

function Compare-DictionaryEquivalent ($Actual, $Expected, $Property) {
    if (-not (Is-Dictionary -Value $Expected))
    {
        throw [ArgumentException]"Expected must be a dictionary."
    }

    if (-not (Is-Dictionary -Value $Actual))
    {
        v -Difference "`$Actual is not a dictionary it is a $(Format-Nicely ($Actual.GetType())), so they are not equivalent."
        $expectedFormatted = Format-Nicely -Value $Expected
        $actualFormatted = Format-Nicely -Value $Actual
        return "Expected dictionary '$expectedFormatted', but got '$actualFormatted'."
    }

    # todo: if either side or both sides are empty dictionary make the verbose output shorter and nicer

    $actualKeys = $Actual.Keys
    $expectedKeys = $Expected.Keys

    v "`Comparing all ($($expectedKeys.Count)) keys from `$Expected to keys in `$Actual."
    $result = @()
    foreach ($k in $expectedKeys)
    {
        $actualHasKey = $actualKeys -contains $k
        if (-not $actualHasKey)
        {
            v -Difference "`$Actual is missing key '$k'."
            $result += "Expected has key '$k' that the other object does not have."
            continue
        }

        $expectedValue = $Expected[$k]
        $actualValue = $Actual[$k]
        v "Both `$Actual and `$Expected have key '$k', comparing thier contents."
        $result += Compare-Equivalent -Expected $expectedValue -Actual $actualValue -Path "$Property.$k"
    }

    $keysNotInExpected =  $actualKeys | where {$expectedKeys -notcontains $_ }
    if ($keysNotInExpected) {
        v -Difference "`$Actual has $($keysNotInExpected.Count) keys that were not found on `$Expected: $(Format-Nicely @($keysNotInExpected))."
    }
    else {
        v "`$Actual has no keys that we did not find on `$Expected."
    }
    foreach ($k in $keysNotInExpected)
    {
        $result += "Expected is missing key '$k' that the other object has."
    }

    if ($result)
    {
        v -Difference "Hastables `$Actual and `$Expected are not equivalent."
        $expectedFormatted = Format-Nicely -Value $Expected
        $actualFormatted = Format-Nicely -Value $Actual
        return "Expected dictionary '$expectedFormatted', but got '$actualFormatted'.`n$($result -join "`n")"
    }
    v -Equivalence "Hastables `$Actual and `$Expected are equivalent."
}

function Compare-ObjectEquivalent ($Actual, $Expected, $Property) {

    if (-not (Is-Object -Value $Expected))
    {
        throw [ArgumentException]"Expected must be an object."
    }

    if (-not (Is-Object -Value $Actual)) {
        v -Difference "`$Actual is not an object it is a $(Format-Nicely ($Actual.GetType())), so they are not equivalent."
        $expectedFormatted = Format-Nicely -Value $Expected
        $actualFormatted = Format-Nicely -Value $Actual
        return "Expected object '$expectedFormatted', but got '$actualFormatted'."
    }

    $actualProperties = $Actual.PsObject.Properties
    $expectedProperties = $Expected.PsObject.Properties

    v "Comparing all ($(@($expectedProperties).Count)) properties of `$Expected to `$Actual."
    foreach ($p in $expectedProperties)
    {
        $propertyName = $p.Name
        $actualProperty = $actualProperties | Where { $_.Name -eq $propertyName}
        if (-not $actualProperty)
        {
            v -Difference "Property '$propertyName` was not found on `$Actual."
            "Expected has property '$PropertyName' that the other object does not have."
            continue
        }
        v "Property '$propertyName` was found on `$Actual, comparing them for equivalence."
        $differences = Compare-Equivalent -Expected $p.Value -Actual $actualProperty.Value -Path "$Property.$propertyName"
        if (-not $differences) {
            v -Equivalence "Property '$propertyName` is equivalent."
        }
        else {
            v -Difference "Property '$propertyName` is not equivalent."
        }
        return $differences
    }

    #check if there are any extra actual object props
    $expectedPropertyNames = $expectedProperties | select -ExpandProperty Name

    $propertiesNotInExpected =  $actualProperties | where {$expectedPropertyNames -notcontains $_.name }

    v -Difference "`$Actual has ($(@($propertiesNotInExpected).Count)) properties that `$Expected does not have: $(Format-Nicely @($propertiesNotInExpected))"
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

function v {
    [CmdletBinding()]
    param(
        [String] $String,
        [Switch] $Difference,
        [Switch] $Equivalence
    )
    
    # we are using implict variable $Path
    # from the parent scope, this is ugly
    # and bad practice, but saves us ton of
    # coding and boilerplate code

    $p = ""
    $p += if ($null -ne $Path) {
        "($Path)"
    }

    $p += if ($Difference) {
        " DIFFERENCE"+ (++$script:differenceCount)
    }

    $p += if ($Equivalence) {
        " EQUIVALENCE"
    }

    $p += if (""-ne $p) {
        " - "
    }

    Write-Verbose ("$p$String".Trim() + " ")
}

# compares two objects for equivalency and returns $null when they are equivalent
# or a string message when they are not
function Compare-Equivalent {
    [CmdletBinding()]
    param($Actual, $Expected, $Path)
    $script:differenceCount = 0
    #start by null checks to avoid implementing null handling
    #logic in the functions that follow
    if ($null -eq $Expected)
    {
        v "`$Expected is `$null, so we are expecting `$null."
        if ($Expected -ne $Actual)
        {
            v -Difference "`$Actual is not equivalent to $(Format-Nicely $Expected), because it has a value of type $(Format-Nicely $Actual.GetType())."
           return Get-ValueNotEquivalentMessage -Expected $Expected -Actual $Actual -Property $Path
        }
        # we terminate here, either we passed the test and return nothing, or we did not 
        # and the previous statement returned message
        v -Equivalence "`$Actual is equivalent to `$null, because it is `$null."
        return
    }

    v "`$Expected has type $($Expected.GetType()), `$Actual has type $($Actual.GetType()), they are both non-null."

    #test value types, strings, and single item arrays with values in them as values
    #expand the single item array to get to the value in it
    if (Is-Value -Value $Expected)
    {
        v "`$Expected is a value (value type, string, single value array, or a scriptblock), we will be comparing `$Actual to value types."
        Compare-ValueEquivalent -Actual $Actual -Expected $Expected -Property $Path
        return
    }

    #are the same instance
    if (Test-Same -Expected $Expected -Actual $Actual)
    {
        v -Equivalence "`$Expected and `$Actual are equivalent because they are the same object (by reference)."
        return
    }

    if (Is-Hashtable -Value $Expected)
    {
        v "`$Expected is a hashtable, we will be comparing `$Actual to hashtables."
        Compare-HashtableEquivalent -Expected $Expected -Actual $Actual -Property $Path
        return
    }

    # dictionaries? (they are IEnumerable so they must go before collections)
    if (Is-Dictionary -Value $Expected)
    {
        v "`$Expected is a dictionary, we will be comparing `$Actual to dictionaries."
        Compare-DictionaryEquivalent -Expected $Expected -Actual $Actual -Property $Path
        return
    }

    #compare DataTable
    if (Is-DataTable -Value $Expected) {
        # todo add verbose output to data table
        v "`$Expected is a datatable, we will be comparing `$Actual to datatables."
        Compare-DataTableEquivalent -Expected $Expected -Actual $Actual -Property $Path
        return
    }

    #compare collection
    if (Is-Collection -Value $Expected) {
        v "`$Expected is a collection, we will be comparing `$Actual to collections."
        Compare-CollectionEquivalent -Expected $Expected -Actual $Actual -Property $Path
        return
    }

    #compare DataRow
    if (Is-DataRow -Value $Expected) {
        # todo add verbose output to data row
        v "`$Expected is a datarow, we will be comparing `$Actual to datarows."
        Compare-DataRowEquivalent -Expected $Expected -Actual $Actual -Property $Path
        return
    }

    v "`$Expected is an object of type $($Expected.GetType()), we will be comparing `$Actual to objects."
    Compare-ObjectEquivalent -Expected $Expected -Actual $Actual -Property $Path
}

function Assert-Equivalent {
    [CmdletBinding()]
    param(
        $Actual, 
        $Expected, 
        [Switch]$StrictOrder
    )

    $Option = $null

    $areDifferent = Compare-Equivalent -Actual $Actual -Expected $Expected | Out-String
    
    v -Difference:([bool]$script:differenceCount) -Equivalence:(-not $script:differenceCount) "Found $($script:differenceCount) differences between `$Actual and `$Expected."

    if ($areDifferent)
    {
        $message = Get-AssertionMessage -Actual $actual -Expected $Expected -Option $Option -Pretty -CustomMessage "Expected and actual are not equivalent!`nExpected:`n<expected>`n`nActual:`n<actual>`n`nSummary:`n$areDifferent`n<options>"
        throw [Assertions.AssertionException]$message
    }
}