InModuleScope -ModuleName Assert {
    Describe "Compare-Equivalent - Exclude path options" {

        It "Given a full path to a property it ignores it on the Expected object" -TestCases @(
            @{ Path = $null }
            @{ Path = "ParentProperty1" }
            @{ Path = "ParentProperty1.ParentProperty2" }
        ) { 
            param ($Path)

            $expected = [PSCustomObject] @{
                Name = "Jakub"
                Age = 30
            }

            $actual = [PSCustomObject] @{
                Name = "Jakub"
            }

            $options = Get-EquivalencyOptions -ExcludePath ("$Path.Age".Trim('.'))
            Compare-Equivalent -Actual $actual -Expected $expected -Path $Path -Options $options  | Verify-Null
        }

        It "Given a full path to a property it ignores it on the Actual object"  -TestCases @(
            @{ Path = $null }
            @{ Path = "ParentProperty1" }
            @{ Path = "ParentProperty1.ParentProperty2" }
        ) { 
            param ($Path)
            $expected = [PSCustomObject] @{
                Name = "Jakub"
            }

            $actual = [PSCustomObject] @{
                Name = "Jakub"
                Age = 30
            }

            $options = Get-EquivalencyOptions -ExcludePath ("$Path.Age".Trim('.'))
            Compare-Equivalent -Actual $actual -Expected $expected -Path $Path -Options $options | Verify-Null
        }
    }

    It "Given a full path to a property on object that is in collection it ignores it on the Expected object" {
        $expected = [PSCustomObject] @{
            ProgrammingLanguages = @(
                [PSCustomObject] @{
                    Name = "C#"
                    Type = "OO"
                },
                [PSCustomObject] @{
                    Name = "PowerShell"
                }
            )
        }

        $actual = [PSCustomObject] @{
            ProgrammingLanguages = @(
                [PSCustomObject] @{
                    Name = "C#"
                },
                [PSCustomObject] @{
                    Name = "PowerShell"
                }
            )
        }

        
        $options = Get-EquivalencyOptions -ExcludePath "ProgrammingLanguages.Type"
        Compare-Equivalent -Actual $actual -Expected $expected -Options $options | Verify-Null
    }

    It "Given a full path to a property on object that is in collection it ignores it on the Actual object" {
        $expected = [PSCustomObject] @{
            ProgrammingLanguages = @(
                [PSCustomObject] @{
                    Name = "C#"
                },
                [PSCustomObject] @{
                    Name = "PowerShell"
                }
            )
        }

        $actual = [PSCustomObject] @{
            ProgrammingLanguages = @(
                [PSCustomObject] @{
                    Name = "C#"
                    Type = "OO"
                },
                [PSCustomObject] @{
                    Name = "PowerShell"
                }
            )
        }

        
        $options = Get-EquivalencyOptions -ExcludePath "ProgrammingLanguages.Type"
        Compare-Equivalent -Actual $actual -Expected $expected -Options $options | Verify-Null
    }

    It "Given a full path to a property on object that is in hashtable it ignores it on the Expected object" {
        $expected = [PSCustomObject] @{
            ProgrammingLanguages = @{
                Language1 = [PSCustomObject] @{
                    Name = "C#"
                    Type = "OO"
                }
                Language2 = [PSCustomObject] @{
                    Name = "PowerShell"
                }
            }
        }

        $actual = [PSCustomObject] @{
            ProgrammingLanguages =  @{
                Language1 = [PSCustomObject] @{
                    Name = "C#"
                }
                Language2 = [PSCustomObject] @{
                    Name = "PowerShell"
                }
            }
        }

        $options = Get-EquivalencyOptions -ExcludePath "ProgrammingLanguages.Language1.Type"
        Compare-Equivalent -Actual $actual -Expected $expected -Options $options | Verify-Null
    }

    # in the above tests we are not testing all the possible options of skippin in all possible
    # emumerable objects, but this many tests should still be enough. The Path unifies how different
    # collections are handled, and we filter out based on the path on the start of Compare-Equivalent
    # so the same rules should apply transitively no matter the collection type

    
    It "Given a full path to a key on a hashtable it ignores it on the Expected hashtable" {
        $expected = @{
            Name = "C#"
            Type = "OO"
        }

        $actual = @{
            Name = "C#"
        }

        $options = Get-EquivalencyOptions -ExcludePath "Type"
        Compare-Equivalent -Actual $actual -Expected $expected -Options $options | Verify-Null
    }

    It "Given a full path to a key on a hashtable it ignores it on the Actual hashtable" {
        $expected = @{
            Name = "C#"
        }

        $actual = @{
            Name = "C#"
            Type = "OO"
        }

        $options = Get-EquivalencyOptions -ExcludePath "Type"
        Compare-Equivalent -Actual $actual -Expected $expected -Options $options | Verify-Null
    }

    It "Given a full path to a key on a dictionary it ignores it on the Expected dictionary" {
        $expected = New-Dictionary @{
            Name = "C#"
            Type = "OO"
        }

        $actual = New-Dictionary @{
            Name = "C#"
        }

        $options = Get-EquivalencyOptions -ExcludePath "Type"
        Compare-Equivalent -Actual $actual -Expected $expected -Options $options | Verify-Null
    }

    It "Given a full path to a key on a dictionary it ignores it on the Actual dictionary" {
        $expected = New-Dictionary @{
            Name = "C#"
        }

        $actual = New-Dictionary @{
            Name = "C#"
            Type = "OO"
        }

        $options = Get-EquivalencyOptions -ExcludePath "Type"
        Compare-Equivalent -Actual $actual -Expected $expected -Options $options | Verify-Null
    }

}