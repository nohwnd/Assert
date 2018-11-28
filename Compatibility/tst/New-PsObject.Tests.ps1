$here = $MyInvocation.MyCommand.Path | Split-Path
Import-Module -Force $here/../../Axiom/src/Axiom.psm1 -DisableNameChecking
. $here/../src/New-PSObject.ps1

Describe "New-PSObject" { 
    It "Creates a new object of type PSCustomObject" {
        $hashtable = @{ 
            Name = 'Jakub'
        }

        $object = New-PSObject $hashtable 
        $object | Verify-Type ([PSCustomObject])
    }

    It "Creates a new PSObject with the properties populated" {
        $hashtable = @{ 
            Name = 'Jakub'
        }

        $object = New-PSObject $hashtable 
        $object.Name | Verify-Equal $hashtable.Name
    }
}