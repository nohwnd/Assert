InModuleScope Assert {
Describe Get-ChildException {
    Mock Get-ChildExceptionImpl -Verifiable {'return value'}
    try
    {
        throw 'message'
    }
    catch
    {
        $r = $_ | Get-ChildException -Recurse
    }
    It 'invokes Get-ChildExceptionImpl' {
        Assert-MockCalled Get-ChildExceptionImpl -Times 1 -Exactly {
            ($Exception.Message -eq 'message') -and
            $Recurse
        }
    }
    It 'returns value Get-ChildExceptionImpl' {
        $r | Verify-Equal 'return value'
    }
}
Describe Get-ChildExceptionImpl {
    Context 'no InnerException' {
        $r = [System.Exception]::new('message') |
            Get-ChildExceptionImpl
        It 'returns null' {
            $r | Verify-Null
        }
    }
    Context 'has InnerException' {
        $r = [System.Exception]::new(
                'outer',
                [System.Exception]::new('inner')
            ) |
            Get-ChildExceptionImpl
        It 'returns InnerException' {
            $r.Message | Verify-Equal 'inner'
        }
    }
    Context 'nested InnerException' {
        $e = [System.Exception]::new(
                'outermost',
                [System.Exception]::new(
                    'middle-outer',
                    [System.Exception]::new(
                        'middle-inner',
                        [System.Exception]::new('innermost')
                    )
                )
            )
        Context 'don''t -Recurse' {
            $r = $e | Get-ChildExceptionImpl
            It 'returns only first descendant' {
                $r.Count | Verify-Equal 1
                $r.Message | Verify-Equal 'middle-outer'
            }
        }
        Context '-Recurse' {
            $r = $e | Get-ChildExceptionImpl -Recurse
            It 'returns all descendents, outermost-first' {
                $r.Count | Verify-Equal 3
                $r[0].Message | Verify-Equal 'middle-outer'
                $r[1].Message | Verify-Equal 'middle-inner'
                $r[2].Message | Verify-Equal 'innermost'
            }
        }
    }
}
}