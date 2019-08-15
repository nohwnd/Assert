function Is-Null ($Value) {
    # Since PowerShell 7.0 [DBNull] -eq $null.
    $null -eq $Value -or $Value -is [DBNull] -or $Value.Psobject.TypeNames[0] -like '*System.DBNull'
}

function Is-Value ($Value) {
    $Value = $($Value)
    $Value -is [ValueType] -or $Value -is [string] -or $value -is [scriptblock]
}

function Is-Collection ($Value) {
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

function Is-DataTable ($Value) {
    $Value -is [Data.DataTable] -or $Value.Psobject.TypeNames[0] -like '*System.Data.DataTable'
}

function Is-ScriptBlock ($Value) {
    $Value -is [ScriptBlock]
}

function Is-DecimalNumber ($Value) {
    $Value -is [float] -or $Value -is [single] -or $Value -is [double] -or $Value -is [decimal]
}

function Is-Hashtable ($Value) {
    $Value -is [hashtable]
}

function Is-Dictionary ($Value) {
    $Value -is [System.Collections.IDictionary]
}


function Is-Object ($Value) {
    # here we need to approximate that that object is not value
    # or any special category of object, so other checks might
    #need to be added (such as for hashtables)

    -not ($null -eq $Value -or (Is-Value -Value $Value) -or (Is-Collection -Value $Value))
}

function Is-DataRow ($Value) {
    $Value -is [Data.DataRow] -or $Value.Psobject.TypeNames[0] -like '*System.Data.DataRow'
}

Export-ModuleMember -Function @(
    'Is-Null'
    'Is-Value'
    'Is-Collection'
    'Is-DataTable'
    'Is-ScriptBlock'
    'Is-DecimalNumber'
    'Is-Hashtable'
    'Is-Dictionary'
    'Is-Object'
    'Is-DataRow'
)