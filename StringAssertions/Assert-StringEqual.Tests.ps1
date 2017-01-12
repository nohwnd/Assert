$here = $MyInvocation.MyCommand.Path | Split-Path
. $here\Assert-StringEqual.ps1
. $here\..\common.ps1

Describe "Test-StringEqual" {
    Context "Case insensitive matching" {
        It "strings with the same values are equal" {
            Test-StringEqual -Expected "abc" -Actual "abc" | Should Be $true
        }

        It "strings with different case and same values are equal. comparing '<l>':'<r>'" -TestCases @(
            @{l = "ABc"; r = "abc" },
            @{l = "aBc"; r = "abc" },
            @{l = "ABC"; r = "abc" }
        ) {
            param ($l, $r)
            Test-StringEqual -Expected $l -Actual $r | Should Be $true
        }

        It "strings with different values are not equal" { 
            Test-StringEqual -Expected "abc" -Actual "def" | Should Be $false
        }

        It "strings with different case and different values are not equal. comparing '<l>':'<r>'" -TestCases @(
            @{l = "ABc"; r = "def" },
            @{l = "aBc"; r = "def" },
            @{l = "ABC"; r = "def" }
        ) { 
            param ($l, $r)
            Test-StringEqual -Expected $l -Actual $r | Should Be $false
        }

         It "strings from which one is sorrounded by whitespace are not equal. comparing '<l>':'<r>'" -TestCases @(
            @{l = "abc "; r = "abc" },
            @{l = "abc "; r = "abc" },
            @{l = "ab c"; r = "abc" }
        ) { 
            param ($l, $r)
            Test-StringEqual -Expected $l -Actual $r | Should Be $false
        }
    }

    Context "Case sensitive matching" {
        It "strings with different case but same values are not equal. comparing '<l>':'<r>'" -TestCases @(
            @{l = "ABc"; r = "abc" },
            @{l = "aBc"; r = "abc" },
            @{l = "ABC"; r = "abc" }
        ) {
            param ($l, $r)
            Test-StringEqual -Expected $l -Actual $r -CaseSensitive | Should Be $false
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
            Test-StringEqual -Expected $l -Actual $r -IgnoreWhiteSpace | Should Be $true
        }
    }
}

Describe "Get-StringEqualDefaultFailureMessage" {
    It "returns correct default message" {
        $expected = "Expected the string to be 'abc' but got 'bde'."
        $actual = Get-StringEqualDefaultFailureMessage -Expected "abc" -Actual "bde"
        $actual | Should Be $expected
    }
}

Describe "Assert-StringEqual" {
    It "Does nothing when string are the same" { 
        Assert-StringEqual -Expected "abc" -Actual "abc"
    }

    It "Throws when strings are different" {
        { Assert-StringEqual -Expected "abc" -Actual "bde" } | Should -Throw 
    }

    It "Throws with default message when test fails" {
        $expected = Get-StringEqualDefaultFailureMessage -Expected "abc" -Actual "bde"
        { Assert-StringEqual -Expected "abc" -Actual "bde" } | Should -Throw -ExpectedMessage $expected
    }

    It "Throws with custom message when test fails" {
        $customMessage = "Test failed becasue it expected '<e>' but got '<a>'. What a shame!"
        $expected = Get-CustomFailureMessage -Message $customMessage -Expected "abc" -Actual "bde"
        { Assert-StringEqual -Expected "abc" -Actual "bde" -Message $customMessage } | Should -Throw -ExpectedMessage $expected
    }

    It "Allows expected to be passed from pipeline" {
        "abc" | Assert-StringEqual -Actual "abc"
    }

    It "Allows actual to be passed by position" {
        Assert-StringEqual -Expected "abc" -Actual "abc"
    }

    It "Allows expected to be passed by pipeline and actual by position" {
        "abc" | Assert-StringEqual "abc"
    }

    Context "String specific features" {
        It "Can compare strings in CaseSensitive mode" {
            { Assert-StringEqual -Expected "ABC" -Actual "abc" -CaseSensitive } | Should Throw
        }

        It "Can compare strings without whitespace" {
            Assert-StringEqual -Expected " a b c " -Actual "abc" -IgnoreWhitespace
        }
    }
}