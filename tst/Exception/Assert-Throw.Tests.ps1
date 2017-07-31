Describe "Assert-Throw" {
    It "Passes when exception is thrown" {
        { throw } | Assert-Throw
    }

    It "Fails when no exception is thrown" {
        { { } | Assert-Throw } | Verify-AssertionFailed
    }
}
