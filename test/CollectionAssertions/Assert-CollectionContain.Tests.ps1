InModuleScope -ModuleName Assert {
    Describe "Assert-CollectionContain" {
        It "Passes when collection of single item contains the expected item" {
            @(1) | Assert-CollectionContain 1
        }

        It "Fails when collection of single item does not contain the expected item" {
            $error = { @(5) | Assert-CollectionContain 1 } | Verify-AssertionFailed 
            $error.Exception.Message | Verify-Equal "Expected int '1' to be present in collection '5', but it was not there."
        }

        It "Passes when collection of multiple items contains the expected item" {
            @(1,2,3) | Assert-CollectionContain 1
        }

        It "Fails when collection of multiple items does not contain the expected item" {
            $error = { @(5,6,7) | Assert-CollectionContain 1 } | Verify-AssertionFailed
            $error.Exception.Message | Verify-Equal "Expected int '1' to be present in collection '5, 6, 7', but it was not there."
        }
    }
}