function Format-Collection ($Value, [switch]$Pretty) { 
    ($Value | % { Format-Custom -Value $_ -Pretty:$Pretty }) -join ', '
}

function Format-PSObject ($Value, [switch]$Pretty) {
    $Value = [string]$Value
    
    if ($Pretty) {
        $margin = "    "
        $Value = $Value `
            -replace '^@{',"@{`n$margin" `
            -replace '; ',";`n$margin" `
            -replace '}$',"`n}" `
    }
    
    $Value -replace '^@','PSObject'
}

function Format-Object ($Value, $Property, [switch]$Pretty) {
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

function Format-ScriptBlock ($Value) {
    '{' + $Value + '}'
}

function Format-Number ($Value) { 
    [string]$Value
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

    # dictionaries? (they are IEnumerable so they must go befor collections)
    # hashtables?

    if (Test-Collection -Value $Value) 
    { 
        return Format-Collection -Value $Value -Pretty:$Pretty
    }

    if (Test-PSObjectExactly -Value $Value)
    {
       
        return Format-PSObject -Value $Value -Pretty:$Pretty
    }

    Format-Object -Value $Value -Property (Get-IdentityProperty ($Value.GetType())) -Pretty:$Pretty
}