$here = $MyInvocation.MyCommand.Path | Split-Path
. $here\Assert-StringNotEqual.ps1
. $here\..\common.ps1

Describe "Test-StringNotEqual" {
    Context "Case insensitive matching" {
        It "strings with the same values are equal" {
            Test-StringNotEqual -Expected "abc" -Actual "abc" | Verify-False
        }

        It "strings with different case but same values are not . comparing '<l>':'<r>'" -TestCases @(
            @{l = "ABc"; r = "abc" },
            @{l = "aBc"; r = "abc" },
            @{l = "ABC"; r = "abc" }
        ) {
            param ($l, $r)
            Test-StringNotEqual -Expected $l -Actual $r | Verify-False
        }

        It "strings with different values are not equal" { 
            Test-StringNotEqual -Expected "abc" -Actual "def" | Verify-True
        }

        It "strings with different case and different values are not equal. comparing '<l>':'<r>'" -TestCases @(
            @{l = "ABc"; r = "def" },
            @{l = "aBc"; r = "def" },
            @{l = "ABC"; r = "def" }
        ) { 
            param ($l, $r)
            Test-StringNotEqual -Expected $l -Actual $r | Verify-True
        }

         It "strings from which one is sorrounded by whitespace are not equal. comparing '<l>':'<r>'" -TestCases @(
            @{l = "abc "; r = "abc" },
            @{l = "abc "; r = "abc" },
            @{l = "ab c"; r = "abc" }
        ) { 
            param ($l, $r)
            Test-StringNotEqual -Expected $l -Actual $r | Verify-True
        }
    }

    Context "Case sensitive matching" {
        It "strings with different case but same values are not equal. comparing '<l>':'<r>'" -TestCases @(
            @{l = "ABc"; r = "abc" },
            @{l = "aBc"; r = "abc" },
            @{l = "ABC"; r = "abc" }
        ) {
            param ($l, $r)
            Test-StringNotEqual -Expected $l -Actual $r -CaseSensitive | Verify-True
        }
    }

    Context "Case insensitive matching with ingoring whitespace" {
        It "strings sorrounded or containing whitespace are equal. comparing '<l>':'<r>'" -TestCases @(
            @{l = "abc "; r = "abc" },
            @{l = "abc "; r = "abc" },
            @{l = "ab c"; r = "abc" },
            @{l = "ab c"; r = "a b c" }
        ) { 
            param ($l, $r)
            Test-StringNotEqual -Expected $l -Actual $r -IgnoreWhiteSpace | Verify-False
        }
    }
}

Describe "Get-StringNotEqualDefaultFailureMessage" {
    It "returns correct default message" {
        $expected = "Expected the strings to be different but they were the same 'abc'."
        $actual = Get-StringNotEqualDefaultFailureMessage -Expected "abc" -Actual "abc"
        $actual | Verify-Equal $expected
    }
}

Describe "Assert-StringNotEqual" {
    It "Does nothing when string are different" { 
        Assert-StringNotEqual -Expected "abc" -Actual "bde"
    }

    It "Throws when strings are the same" {
        { Assert-StringNotEqual -Expected "abc" -Actual "abc" } | Verify-AssertionFailed 
    }

    It "Throws with default message when test fails" {
        $expected = Get-StringNotEqualDefaultFailureMessage -Expected "abc" -Actual "abc"
        $exception = { Assert-StringNotEqual -Expected "abc" -Actual "abc" } | Verify-AssertionFailed
        "$exception" | Verify-Equal $expected
    }

    It "Throws with custom message when test fails" {
        $customMessage = "Test failed becasue it expected '<e>' but got '<a>'. What a shame!"
        $expected = Get-CustomFailureMessage -Message $customMessage -Expected "abc" -Actual "abc"
        $exception = { Assert-StringNotEqual -Expected "abc" -Actual "abc" -Message $customMessage } | Verify-AssertionFailed
        "$exception" | Verify-Equal $expected
    }

    It "Allows actual to be passed from pipeline" {
        "abc" | Assert-StringNotEqual -Expected "bde"
    }

    It "Allows expected to be passed by position" {
        Assert-StringNotEqual "abc" -Actual "bde"
    }

    It "Allows actual to be passed by pipeline and expected by position" {
        "abc" | Assert-StringNotEqual "bde"
    }

    Context "String specific features" {
        It "Can compare strings in CaseSensitive mode" {
            Assert-StringNotEqual -Expected "ABC" -Actual "abc" -CaseSensitive
        }

        It "Can compare strings without whitespace" {
            { Assert-StringNotEqual -Expected " a b c " -Actual "abc" -IgnoreWhitespace } | Verify-AssertionFailed
        }
    }
}