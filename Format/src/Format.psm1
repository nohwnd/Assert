Import-Module $PSScriptRoot/../../TypeClass/src/TypeClass.psm1 -DisableNameChecking

function Format-Collection ($Value, [switch]$Pretty) { 
    $separator = ', '
    if ($Pretty){
        $separator = ",`n"
    }
    ($Value | % { Format-Nicely -Value $_ -Pretty:$Pretty }) -join $separator
}

function Format-Object ($Value, $Property, [switch]$Pretty) {
    if ($null -eq $Property)
    {
        $Property = $Value.PSObject.Properties | Select-Object -ExpandProperty Name
    }
    $orderedProperty = $Property | Sort-Object
    $valueType = Get-ShortType $Value
    $valueFormatted = ([string]([PSObject]$Value | Select-Object -Property $orderedProperty))

    if ($Pretty) {
        $margin = "    "
        $valueFormatted = $valueFormatted `
            -replace '^@{',"@{`n$margin" `
            -replace '; ',";`n$margin" `
            -replace '}$',"`n}" `
    }

    $valueFormatted -replace "^@", $valueType
}

function Format-Null {
    '$null'
}

function Format-Boolean ($Value) {
    '$' + $Value.ToString().ToLower()
}

function Format-ScriptBlock ($Value) {
    '{' + $Value + '}'
}

function Format-Number ($Value) { 
    [string]$Value
}

function Format-Hashtable ($Value) {
    $head = '@{'
    $tail = '}'

    $entries = $Value.Keys | sort | foreach { 
        $formattedValue = Format-Nicely $Value.$_
        "$_=$formattedValue" }
    
    $head + ( $entries -join '; ') + $tail
}

function Format-Dictionary ($Value) {
    $head = 'Dictionary{'
    $tail = '}'

    $entries = $Value.Keys | sort | foreach { 
        $formattedValue = Format-Nicely $Value.$_
        "$_=$formattedValue" }
    
    $head + ( $entries -join '; ') + $tail
}

function Format-Nicely ($Value, [switch]$Pretty) { 
    if ($null -eq $Value) 
    { 
        return Format-Null -Value $Value
    }

    if ($Value -is [bool])
    {
        return Format-Boolean -Value $Value
    }

    if ($value -is [Reflection.TypeInfo])
    {
        return Format-Type -Value $Value
    }

    if (Is-DecimalNumber -Value $Value) 
    {
        return Format-Number -Value $Value
    }

    if (Is-ScriptBlock -Value $Value)
    {
        return Format-ScriptBlock -Value $Value
    }

    if (Is-Value -Value $Value) 
    { 
        return $Value
    }

    if (Is-Hashtable -Value $Value)
    {
        return Format-Hashtable -Value $Value
    }
    
    if (Is-Dictionary -Value $Value)
    {
        return Format-Dictionary -Value $Value
    }

    if (Is-Collection -Value $Value) 
    { 
        return Format-Collection -Value $Value -Pretty:$Pretty
    }

    Format-Object -Value $Value -Property (Get-DisplayProperty ($Value.GetType())) -Pretty:$Pretty
}

function Get-DisplayProperty ([Type]$Type) {
    # rename to Get-DisplayProperty?

    <# some objects are simply too big to show all of their properties, 
    so we can create a list of properties to show from an object 
    maybe the default info from Get-FormatData could be utilized here somehow
    so we show only stuff that would normally show in format-table view
    leveraging the work PS team already did #>

    # this will become more advanced, basically something along the lines of:
    # foreach type, try constructing the type, and if it exists then check if the 
    # incoming type is assignable to the current type, if so then return the properties,
    # this way I can specify the map from the most concrete type to the least concrete type
    # and for types that do not exist
 
    $propertyMap = @{
        'System.Diagnostics.Process' = 'Id', 'Name'
    }
    
    $propertyMap[$Type.FullName]
}

function Get-ShortType ($Value) {
    if ($null -ne $value)
    {
        Format-Type $Value.GetType()
    }
    else 
    {
        Format-Type $null
    }
}

function Format-Type ([Type]$Value) {
    if ($null -eq $Value) {
        return '<null>'
    }
    
    $type = [string]$Value 
    
    $type `
        -replace "^System\." `
        -replace "^Management\.Automation\.PSCustomObject$","PSObject" `
        -replace "^PSCustomObject$","PSObject" `
        -replace "^Object\[\]$","collection" `
}


Export-ModuleMember -Function @(
    'Format-Collection'
    'Format-Object'
    'Format-Null'
    'Format-Boolean'
    'Format-ScriptBlock'
    'Format-Number'
    'Format-Hashtable'
    'Format-Dictionary'
    'Format-Type'
    'Format-Nicely'
    'Get-DisplayProperty'
    'Get-ShortType'
)