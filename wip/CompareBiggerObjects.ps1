Get-Module Assert | Remove-Module
Import-module ./Assert.psd1

$expected = [PSCustomObject]@{
    Name = 'Jakub'
    Age = 28
    KnowsPowerShell = $true
    Languages = 'Czech', 'English'
    ProgrammingLanguage =
        [PSCustomObject]@{
            Name = 'PowerShell'
            Type = 'Scripting'
        }
}

$actual = [PSCustomObject]@{
    Name = 'Jkb'
    KnowsPowerShell = 0
    Languages = 'Czech', 'English', 'German'
    ProgrammingLanguage =
        [PSCustomObject]@{
            Name = 'C#'
            Type = 'ObjectOriented'
        }
}

Assert-Equivalent -a $actual -e $expected -Verbose


