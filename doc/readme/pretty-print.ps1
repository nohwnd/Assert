& (Get-Module Assert) { $global:formatCustom = get-command Format-Nicely  }

function Format-Nicely ($o){ &$f $o }

Format-Nicely $null
Format-Nicely $false
Format-Nicely $true
Format-Nicely ( @{ Name = 'Jakub' } )
Format-Nicely ( [PSCustomObject]@{ Name = 'Jakub' } )
Format-Nicely ( Get-Process Idle )