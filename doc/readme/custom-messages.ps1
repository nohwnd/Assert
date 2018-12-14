function Get-ActiveComputers () {
    $c = @(
        @{ HostName = "WKS1" },
        @{ HostName = "WKS2" },
        @{ HostName = "WKD" },
        @{ HostName = "WKA5" }
    )

    $c | ForEach-Object {[PSCustomObject]$_}
}

Describe "Active computers" {
    It "All our computer names start with WKS*" {
        Get-ActiveComputers |
            Select-Object -ExpandProperty HostName |
            Assert-All {$_ -like 'WKS*'} -CustomMessage `
            "<actualFilteredCount> computers do not start with WKS*:
            '<actualFiltered>'"
    }
}