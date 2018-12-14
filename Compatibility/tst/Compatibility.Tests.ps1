$here = $MyInvocation.MyCommand.Path | Split-Path
Import-Module -Force $here/../../Axiom/src/Axiom.psm1 -DisableNameChecking
. $here/../src/Compatibility.ps1

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

Describe "Test-NullOrWhiteSpace" {
    It "Returns `$true for `$null or whitespace" -TestCases @(
        @{ Value = $null }
        @{ Value = " " }
        @{ Value = "  " }
        @{ Value = "`t" }
        @{ Value = "`r" }
        @{ Value = "`n" }
        @{ Value = " `t `r `n" }
    ) {
        param($Value)
        Test-NullOrWhiteSpace $Value | Verify-True
    }

    It "Returns `$false for '<value>'" -TestCases @(
        @{ Value = "a" }
        @{ Value = " abc" }
        @{ Value = "`tabc`t" }
    ) {
        param ($Value)
        Test-NullOrWhiteSpace $Value | Verify-False
    }
}

Describe "Invoke-WithContext" {
    BeforeAll {
        Get-Module "Test-Module" | Remove-Module
        $body = {
            $a = "in test module"
            $context = "context"

            # all of these are functions returning scriptblocks
            # so we can test that they remain bounded to the state of
            # this module
            function sb1 { { "-$a-" } }
            function sb2 { { "-$a- -$b-" } }
            function sb3 { { "-$context- -$a-" } }
        }
        New-Module -Name "Test-Module" -ScriptBlock $body | Import-Module
    }

    AfterAll {
        Get-Module "Test-Module" | Remove-Module
    }

    It "Keeps the scriptblock attached to the original scope" {
        # we define variable $a here and in the module, and we must
        # resolve $a to the value in the module, not to the local value
        # or null
        $a = 100
        Invoke-WithContext -ScriptBlock (sb1) -Variables @{} |
            Verify-Equal "-in test module-"
    }

    It "Injects variable `$b into the scope while keeping `$a attached to the module scope" {
        Invoke-WithContext -ScriptBlock (sb2) -Variables @{ b = 'injected' } |
            Verify-Equal "-in test module- -injected-"
    }

    It "Does not conflict with `$Context variable that is used internally" {
        # internally we wrap the call in something like
        # & {
        #     param($context)
        #     & $context.ScriptBlock
        # }
        # and we need to make sure that the `$context variable
        # will not be seen by the original scriptblock to avoid
        # naming conflicts
        Invoke-WithContext -ScriptBlock (sb3) -Variables @{} |
            Verify-Equal "-context- -in test module-"
    }
}