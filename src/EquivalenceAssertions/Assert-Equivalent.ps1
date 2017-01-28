function Test-Value ($Value) {
    $Value = $($Value)
    $Value -is [ValueType] -or $Value -is [string] -or $value -is [scriptblock]
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

function Test-DecimalNumber ($Value) { 
    $Value -is [float] -or $Value -is [single] -or $Value -is [double] -or $Value -is [decimal]
}

function Get-ValueNotEquivalentMessage ($Expected, $Actual, $Property) { 
    $Expected = Format-Custom -Value $Expected 
    $Actual = Format-Custom -Value $Actual
    $propertyInfo = if ($Property) { " property $Property with value" }
    "Expected$propertyInfo '$Expected' to be equivalent to the actual value, but got '$Actual'."
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

function Get-CollectionSizeNotTheSameMessage ($Actual, $Expected, $Property) {
    $expectedLength = $Expected.Length
    $actualLength = $Actual.Length
    $Expected = Format-Collection -Value $Expected
    $Actual = Format-Collection -Value $Actual
    
    $propertyMessage = $null
    if ($property) {
        $propertyMessage = " in property $Property with values"
    }
    "Expected collection$propertyMessage '$Expected' with length '$expectedLength' to be the same size as the actual collection, but got '$Actual' with length '$actualLength'."
}

function Compare-Collection ($Expected, $Actual, $Property) {
    if (-not (Test-Collection -Value $Expected)) 
    {
        throw [ArgumentException]"Expected must be a collection."
    }

    if (-not (Test-Collection -Value $Actual)) 
    { 
        $expectedFormatted = Format-Collection -Value $Expected 
        $expectedLength = $expected.Length
        $actualFormatted = Format-Custom -Value $actual
        return "Expected collection '$expectedFormatted' with length '$expectedLength', but got '$actualFormatted'."
    }

    if (-not (Test-CollectionSize -Expected $Expected -Actual $Actual)) {
        return Get-CollectionSizeNotTheSameMessage -Expected $Expected -Actual $Actual -Property $Property
    }

    $eEnd = $Expected.Length
    $aEnd = $Actual.Length
    $taken = @()
    $notFound = @()
    for ($e=0; $e -lt $eEnd; $e++) { 
        $currentExpected = $Expected[$e]
        $found = $false
        for ($a=0; $a -lt $aEnd; $a++) { 
            $currentActual = $Actual[$a]
            if ((-not (Compare-EquivalentObject -Expected $currentExpected -Actual $currentActual -Path $Property)) -and $taken -notcontains $a) 
            {
                $taken += $a
                $found = $true
            }
        }
        if (-not $found) 
        {
            $notFound += $currentExpected
        }
    }
    $Expected = Format-Custom -Value $Expected
    $Actual = Format-Custom -Value $Actual
    $notFoundFormatted = Format-Custom -Value ( $notFound | % { Format-Custom -Value $_ } )
    
    if ($notFound) {
        $propertyMessage = if ($Property) {" in property $Property which is"}
        return "Expected collection$propertyMessage '$Expected' to be equivalent to '$Actual' but some values were missing: '$notFoundFormatted'."
    }
}

function Compare-Value ($Actual, $Expected, $Property) { 
    $Expected = $($Expected)
    if (-not (Test-Value -Value $Expected)) 
    {
        throw [ArgumentException]"Expected must be a Value."
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
    if (Test-ScriptBlock -Value $Expected) 
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

function Test-Object ($Value) {
    #here we need to approximate that that object is not value or any special category of object, so other checks might need to be added (such as for hashtables)

    -not ($null -eq $Value -or (Test-Value -Value $Value) -or (Test-Collection -Value $Value))
}

function Compare-Object ($Actual, $Expected, $Property) {

    if (-not (Test-Object -Value $Expected))
    {
        throw [ArgumentException]"Expected must be an object."
    }

    if (-not (Test-Object -Value $Actual)) {
        $expectedFormatted = Format-Custom -Value $Expected
        $actualFormatted = Format-Custom -Value $Actual
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
    
        Compare-EquivalentObject -Expected $p.Value -Actual $actualProperty.Value -Path "$Property.$propertyName"
    }

    #check if there are any extra actual object props
    $expectedPropertyNames = $expectedProperties | select -ExpandProperty Name

    $propertiesNotInExpected =  $actualProperties | where {$expectedPropertyNames -notcontains $_.name }
        
    foreach ($p in $propertiesNotInExpected)
    {
        "Expected is missing property '$($p.Name)' that the other object has."
    }    
}

function Compare-EquivalentObject ($Actual, $Expected, $Path) { 

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
    if (Test-Value -Value $Expected) 
    {
        Compare-Value -Actual $Actual -Expected $Expected -Property $Path
        return
    }

    #are the same instance
    if (Test-Same -Expected $Expected -Actual $Actual)
    { 
        return
    }

    #compare collection
    if (Test-Collection -Value $Expected) { 

        return Compare-Collection -Expected $Expected -Actual $Actual -Property $Path
    }

    # dictionaries? (they are IEnumerable so they must go befor collections)
    # hashtables?

    Compare-Object -Expected $Expected -Actual $Actual -Property $Path
}

function Assert-Equivalent($Actual, $Expected) {
    $areDifferent = Compare-EquivalentObject -Actual $Actual -Expected $Expected
    if ($areDifferent)
    {
        throw [Assertions.AssertionException]"$areDifferent"
    }
}

# "`n`n"
# "Objects are not equivalent:"
# $expected = New-PSObject @{
#     Name = 'nohwnd'
#     HasNoFreeTime = $true
#     DrinksTooMuchCoffee = $true
#     VersionsOfPowershellInstalled = (
#         (New-PSObject @{ Version = 3; OS = 'Vista' }),
#         (New-PSObject @{ Version = 4; OS = 'Win7' }),
#         (New-PSObject @{ Version = 5; OS = 'Win10' })
#     )
#     VersionsOfPesterInstalled = 3.4, 4.0
# }
# $actual = New-PSObject @{
#     Name = "someGuy"
#     VersionsOfPowershellInstalled = (
#         (New-PSObject @{ Version = 5; OS = 'Win10' })
#     )
#     VersionsOfPesterInstalled = ,(3.4)
# }

# "expected: " + ("$expected" -replace '@{',"@{`n  " -replace ';',";`n " -replace '}',"`n}")
# "actual: " + ($actual -replace '@{',"@{`n  " -replace ';',";`n " -replace '}',"`n}")
# "Summary:"
# Compare-EquivalentObject -Expected $expected -Actual $actual 2> $null
# "`n`n"