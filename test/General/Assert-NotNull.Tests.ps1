InModuleScope -ModuleName Assert {
    Describe "Assert-NotNull" {
        It "Given a value it passes" { 
            1 | Assert-NotNull 
        }

        It "Given `$null it fails" { 
            { $null | Assert-NotNull } | Verify-AssertionFailed
        }

        It "Returns the given value" { 
            1 | Assert-NotNull | Verify-NotNull
        }
    }
}