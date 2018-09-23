Import-Module .\Assert.psd1

function Get-Word ([string]$Filter) 
{
    $words = @( 
        'apple'
        'alphabet'
        'armadillo'
        'baby'
        'bag'
        'car'
    )

    $words
}

Describe "Get-Word" {
    It "Only returns words starting with 'a'" {
        Get-Word -Filter 'a*' | Assert-All { $_ -like 'a*' }   
    }
}