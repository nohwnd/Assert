Describe "Assert-False" {
        It "Passes when cmdlet Assert-False is given `$false" {
            $false | Assert-False
        }

        It "Passes when cmdlet Assert-False is given an actual value of <Value>" -TestCases @(
            @{ Actual = 0 ;Value = '0'}
            @{ Actual = ""; Value = 'Empty String ""' }
            @{ Actual = $null; Value = '$null' }
            @{ Actual = @(); Value = 'Empty Collection @()' }
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
        It "Given value '<Actual>' that is not `$false it returns expected message '<message>'" -TestCases @(
            @{ Actual = $true ; Message = "Expected bool '`$true' to be bool '`$false' or falsy value 0, """", `$null, @()."},
            @{ Actual = 10 ; Message = "Expected int '10' to be bool '`$false' or falsy value 0, """", `$null, @()."}
        ) { 
            param($Actual, $Message)
            $error = { Assert-False -Actual $Actual } | Verify-AssertionFailed
            $error.Exception.Message | Verify-Equal $Message
        }
    }

    It 'Returns the value on output' {
        $expected = $false
        $expected | Assert-False | Verify-Equal $expected
    }

    It "Can be called with positional parameters" {
        { Assert-False $true } | Verify-AssertionFailed
    }
}
