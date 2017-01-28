InModuleScope -ModuleName Assert {
    Describe "Assert-CollectionContains" {
        It "Passes when collection of single item contains the expected item" {
            @(1) | Assert-CollectionContains 1
        }

        It "Fails when collection of single item does not contain the expected item" {
            { @(5) | Assert-CollectionContains 1 } | Verify-AssertionFailed
        }

        It "Passes when collection of multiple items contains the expected item" {
            @(1,2,3) | Assert-CollectionContains 1
        }

        It "Fails when collection of multiple items does not contain the expected item" {
            { @(5,6,7) | Assert-CollectionContains 1 } | Verify-AssertionFailed
        }

        It "Fails when the actual collection is null" {
            { @(5,6,7) | Assert-CollectionContains 1 } | Verify-AssertionFailed
        }

        It "Fails when the actual collection is null" {
            { $null | Assert-CollectionContains 1 } | Verify-AssertionFailed
        }

        It "Fails when the expected value is null" {
            { @(5,6,7) | Assert-CollectionContains $null } | Verify-AssertionFailed
        }
    }
}