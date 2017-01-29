InModuleScope -ModuleName Assert {
    Describe "Assert-Same" {
        It "Passes when two objects are the same instance" {
            $object = New-Object Diagnostics.Process
            $object | Assert-Same $object
        }

        It "Fails when two objects are different instance" {
            $object = New-Object Diagnostics.Process
            $object1 = New-Object Diagnostics.Process
            { $object | Assert-Same $object1 } | Verify-AssertionFailed
        }

        It "Fails for array input even if the last item is the same as expected" {
            $object = New-Object Diagnostics.Process
            { 1,2, $object | Assert-Same $object } | Verify-AssertionFailed
        }

        It "Fails with custom message" {
            $error = { 9 | Assert-Same 3 -Message "<expected> is not <actual>" } | Verify-AssertionFailed
            $error.Exception.Message | Verify-Equal "3 is not 9"
        }

        It "Given two values that are not the same instance '<expected>' and '<actual>' it returns expected message '<message>'" -TestCases @(
            @{ Expected = "a" ; Actual = "a" ; Message = "Expected string 'a', to be the same instance but it was not."}
        ) { 
            param($Expected, $Actual, $Message)
            $error = { Assert-Same -Actual $Actual -Expected $Expected } | Verify-AssertionFailed
            $error.Exception.Message | Verify-Equal $Message
        }

        It "Returns the value on output" {
            $expected = 1
            $expected | Assert-Same $expected | Verify-Equal $expected
        }
    }
}
