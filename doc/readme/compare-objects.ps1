
Import-Module .\assert.psd1  -Force

$expected = [PSCustomObject]@{ 
    Name = 'Jakub' 
    Age = 28
    Languages = 'Czech', 'English' 
}

$actual = [PSCustomObject]@{ 
    Name = 'Jkb' 
    Languages = 'Czech', 'English', 'German'
}

Assert-Equivalent -Actual $actual -Expected $expected


