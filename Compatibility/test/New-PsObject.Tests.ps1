. $PSScriptRoot\..\src\New-PsObject.ps1

Describe "New-PSObject" { 
    It "Creates a new object of type PSObject" {
        $hashtable = @{ 
            Name = 'Jakub'
        }

        $object = New-PSObject $hashtable 
        $object | Assert-Type ([PsObject])
    }

    It "Creates a new PSObject with the properties populated" {
        $hashtable = @{ 
            Name = 'Jakub'
        }

        $object = New-PSObject $hashtable 
        $object.Name | Assert-Equal $hashtable.Name
    }
}