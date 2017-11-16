function Test-Value ($Value) {
    $Value = $($Value)
    $Value -is [ValueType] -or $Value -is [string] -or $value -is [scriptblock]
}

function Test-Collection ($Value) { 
    # check for value types and strings explicitly
    # because otherwise it does not work for decimal
    # so let's skip all values we definitely know
    # are not collections
    if ($Value -is [ValueType] -or $Value -is [string])
    {
        return $false
    }

    -not [object]::ReferenceEquals($Value, $($Value))
}

function Test-ScriptBlock ($Value) {
    $Value -is [ScriptBlock]
}

function Test-DecimalNumber ($Value) { 
    $Value -is [float] -or $Value -is [single] -or $Value -is [double] -or $Value -is [decimal]
}

function Test-Hashtable ($Value) { 
    $Value -is [hashtable] 
}

function Test-Dictionary ($Value) { 
    $Value -is [System.Collections.IDictionary] 
}


function Test-Object ($Value) {
    # here we need to approximate that that object is not value 
    # or any special category of object, so other checks might 
    #need to be added (such as for hashtables)

    -not ($null -eq $Value -or (Test-Value -Value $Value) -or (Test-Collection -Value $Value))
}

Export-ModuleMember -Function @( 
    'Test-Value'
    'Test-Collection'
    'Test-ScriptBlock'
    'Test-DecimalNumber'
    'Test-Hashtable'
    'Test-Dictionary'
    'Test-Object'
)