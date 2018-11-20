Get-Module Assert | remove-module ;
Import-module .\Assert.psd1

# messages:
# (in the result use $(Format-Nicely $variable) for the $Expected and $Actual messages so we can see what was actually there and detect errors better))
# expectation -> v "`$Expected is `$null, so we are expecting `$null."
# v -Difference "`$Actual is not equivalent to `$null, because it has a value of type $(Format-Nicely $Actual.GetType())."
# v -Equivalence "`$Actual is equivalent to `$null, because it is `$null."
& (Get-Module Assert) {
    function c ($a, $e) {
        Compare-Equivalent -Actual $a -Expected $e -Verbose
        "`n"
    }

    function mm ($string) { m "- $string" }
    function m ($string) { Write-Host -fore Cyan $string}
m ("-*"*40)
#mm "nulls"
#c -a 1 -e $null 
#c -a $null -e $null 


#mm "values"

#mm "bools"
#m "fixing bool for expected"
#c -a $false -e 'False' 
#c -a $true -e 'False' 

#m "fixing bool for actual"
#c -a 'False' -e $false 
#c -a 'False' -e $true 

#m compare scriptblocks by content
# c -a {} -e {} 
# c -a { "hello" } -e { "hello" }

# c -a { } -e {} 
# c -a { "hello"} -e { "hello" }

# m "normal boolean comparison"
c -a $true -e $true 
c -a $false -e $false 
c -a $true -e $false 
c -a $false -e $true 
c -a "" -e $true 
c -a 1 -e $true 
c -a 0 -e $true
c -a {} -e ""
c -a "" -e {}

m compare objects 

$expected = [PSCustomObject]@{ 
    Name = 'Jakub' 
    Age = 28
    KnowsPowerShell = $true
    Languages = 'Czech', 'English' 
}

$actual = [PSCustomObject]@{ 
    Name = 'Jkb'
    KnowsPowerShell = 0
    Languages = 'Czech', 'English', 'German'
}

c -a $actual -e $expected


}