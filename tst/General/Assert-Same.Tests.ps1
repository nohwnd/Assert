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
            $error = { "text" | Assert-Same "some other text" -Message "'<expected>' is not '<actual>'" } | Verify-AssertionFailed
            $error.Exception.Message | Verify-Equal "'some other text' is not 'text'"
        }

        It "Given two values that are not the same instance '<expected>' and '<actual>' it returns expected message '<message>'" -TestCases @(
            @{ Expected = New-Object -TypeName PSObject ; Actual = New-Object -TypeName PSObject ; Message = "Expected PSObject '', to be the same instance but it was not."}
        ) { 
            param($Expected, $Actual, $Message)
            $error = { Assert-Same -Actual $Actual -Expected $Expected } | Verify-AssertionFailed
            $error.Exception.Message | Verify-Equal $Message
        }

        It "Returns the value on output" {
            $expected = "text"
            $expected | Assert-Same $expected | Verify-Equal $expected
        }

        Context "Throws when `$expected is integer to warn user about unexpected behavior" {
            It "a" {
                $err = { "some text" | Assert-Same -Expected 1 } | Verify-Throw
                $err.Exception | Verify-Type ([ArgumentException])
                $err.Exception.Message | Verify-Equal "Assert-Throw provides unexpected results for low integers. See https://github.com/nohwnd/Assertions/issues/6"
            }
        }
    }
}
