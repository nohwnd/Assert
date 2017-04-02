function Format-Collection ($Value, [switch]$Pretty) { 
    $separator = ', '
    if ($Pretty){
        $separator = ",`n"
    }
    ($Value | % { Format-Custom -Value $_ -Pretty:$Pretty }) -join $separator
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
        $formattedValue = Format-Custom $Value.$_
        "$_=$formattedValue" }
    
    $head + ( $entries -join '; ') + $tail
}

function Format-Dictionary ($Value) {
    $head = 'Dictionary{'
    $tail = '}'

    $entries = $Value.Keys | sort | foreach { 
        $formattedValue = Format-Custom $Value.$_
        "$_=$formattedValue" }
    
    $head + ( $entries -join '; ') + $tail
}

function Format-Custom ($Value, [switch]$Pretty) { 
    if ($null -eq $Value) 
    { 
        return Format-Null -Value $Value
    }

    if ($Value -is [bool])
    {
        return Format-Boolean -Value $Value
    }

    if (Test-DecimalNumber -Value $Value) 
    {
        return Format-Number -Value $Value
    }

    if (Test-ScriptBlock -Value $Value)
    {
        return Format-ScriptBlock -Value $Value
    }

    if (Test-Value -Value $Value) 
    { 
        return $Value
    }

    if (Test-Hashtable -Value $Value)
    {
        return Format-Hashtable -Value $Value
    }
    
    if (Test-Dictionary -Value $Value)
    {
        return Format-Dictionary -Value $Value
    }

    if (Test-Collection -Value $Value) 
    { 
        return Format-Collection -Value $Value -Pretty:$Pretty
    }

    Format-Object -Value $Value -Property (Get-IdentityProperty ($Value.GetType())) -Pretty:$Pretty
}