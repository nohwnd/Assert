function Get-ChildException
{
    param
    (
        [switch]
        $Recurse,

        [Parameter(Mandatory,
                   ValueFromPipeline)]
        [System.Management.Automation.ErrorRecord]
        $ErrorRecord
    )
    process
    {
        $ErrorRecord.Exception | Get-ChildExceptionImpl -Recurse:$Recurse
    }
}

function Get-ChildExceptionImpl
{
    param
    (
        [switch]
        $Recurse,

        [Parameter(Mandatory,
                   ValueFromPipeline)]
        [System.Exception]
        $Exception
    )
    process
    {
        if ($null -eq $Exception.InnerException)
        {
            return
        }
        $Exception.InnerException
        if ( $Recurse )
        {
            $Exception.InnerException | Get-ChildExceptionImpl -Recurse:$Recurse
        }
    }
}