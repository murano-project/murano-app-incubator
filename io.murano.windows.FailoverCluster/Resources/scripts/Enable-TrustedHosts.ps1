function Enable-TrustedHosts {
    begin {
        Show-InvocationInfo $MyInvocation
    }
    end {
        Show-InvocationInfo $MyInvocation -End
    }
    process {
        trap {
            &$TrapHandler
        }

        Set-Item WSMan:\localhost\Client\TrustedHosts -Value '*' -Force
    }
}