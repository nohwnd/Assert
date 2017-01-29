InModuleScope -ModuleName Assert {
    Describe "Get-ShortType" {
        It "Given '<value>' it returns the correct shortened type name '<expected>'" -TestCases @(
            @{ Value = 1; Expected = 'int' },
            @{ Value = 1.1; Expected = 'double' },
            @{ Value = 'a' ; Expected = 'string' },
            @{ Value = $null ; Expected = '<null>' },
            @{ Value = New-PSObject @{Name='Jakub'} ; Expected = 'PSObject'},
            @{ Value = [Object[]]1,2,3 ; Expected = 'collection' }
        ) {
            param($Value, $Expected)
            Get-ShortType -Value $Value | Verify-Equal $Expected
        }
    }
}