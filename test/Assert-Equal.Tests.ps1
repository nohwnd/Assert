InModuleScope -ModuleName Assert {
    Describe "Assert-Equal" {
        Context "Comparing strings" {
            It "Passes when two strings are equal" {
                "abc" | Assert-Equal "abc"
            }

            It "Fails when two strings are different" {
                { "abc" | Assert-Equal "bde" } | Verify-AssertionFailed
            }
        }

        Context "Comparing integers" {
            It "Passes when two numbers are equal" {
                1 | Assert-Equal 1
            }

            It "Fails when two numbers are different" {
                { 1 | Assert-Equal 9 } | Verify-AssertionFailed
            }
        }

        Context "Comparing doubles" {
            It "Passes when two numbers are equal" {
                .1 | Assert-Equal .1
            }

            It "Fails when two numbers are different" {
                { .1 | Assert-Equal .9 } | Verify-AssertionFailed
            }
        }

        Context "Comparing decimals" {
            It "Passes when two numbers are equal" {
                .1D | Assert-Equal .1D
            }

            It "Fails when two numbers are different" {
                { .1D | Assert-Equal .9D } | Verify-AssertionFailed
            }
        }

        Context "Comparing objects" {
            It "Passes when two objects are equal" {
                $object = New-Object -TypeName PsObject -Property @{ Name = "Jakub" }
                $object | Assert-Equal $object
            }

            It "Fails when two objects are different" {
                $object = New-Object -TypeName PsObject -Property @{ Name = "Jakub" }
                $object1 = New-Object -TypeName PsObject -Property @{ Name = "Jakub" }
                { $object | Assert-Equal $object1 } | Verify-AssertionFailed
            }
        }
    }
}