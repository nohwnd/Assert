InModuleScope -ModuleName Assert {
    Describe "Compare-Equivalent - Exclude path options" {

        It "Given a property name it ignores it on the Expected object" { 
            $expected = [PSCustomObject] @{
                Name = "Jakub"
                Age = 30
            }

            $actual = [PSCustomObject] @{
                Name = "Jakub"
            }

            $options = Get-EquivalencyOptions -ExcludePath "Age"
            Compare-Equivalent -Actual $actual -Expected $expected -Options $options| Verify-Null
        }

        It "Given a property name it ignores it on the Actual object" {
            $expected = [PSCustomObject] @{
                Name = "Jakub"
            }

            $actual = [PSCustomObject] @{
                Name = "Jakub"
                Age = 30
            }

            $options = Get-EquivalencyOptions -ExcludePath "Age"
            Compare-Equivalent -Actual $actual -Expected $expected -Options $options | Verify-Null
        }
    }
}