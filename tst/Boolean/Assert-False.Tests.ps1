Describe "Assert-False" {
        It "Passes when given `$false" {
            $false | Assert-False
        }

        It "Passes when given falsy" -TestCases @(
            @{ Actual = 0 }
            @{ Actual = "" }
            @{ Actual = $null }
            @{ Actual = @() }
        ) {
            param($Actual)
            Assert-False -Actual $Actual
        }

    It "Fails for array input even if the last item is `$false" {
            {  $true,$true,$false | Assert-False } | Verify-AssertionFailed
    }

    It "Fails with custom message" {
            $error = { 9 | Assert-False -Message "<actual> is not false" } | Verify-AssertionFailed
            $error.Exception.Message | Verify-Equal "9 is not false"
    }

    Context "Validate messages" {
        It "Given value '<expected>' that is not `$false it returns expected message '<message>'" -TestCases @(
            @{ Actual = $true ; Message = "Expected bool '`$true' to be bool '`$false' or falsy value 0, """", `$null, @()."},
            @{ Actual = 10 ; Message = "Expected int '10' to be bool '`$false' or falsy value 0, """", `$null, @()."}
        ) { 
            param($Actual, $Message)
            $error = { Assert-False -Actual $Actual } | Verify-AssertionFailed
            $error.Exception.Message | Verify-Equal $Message
        }
    }

    It "Returns the value on output" {
        $expected = $false
        $expected | Assert-False | Verify-Equal $expected
    }
}
