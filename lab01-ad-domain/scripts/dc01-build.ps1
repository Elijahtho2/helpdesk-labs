# dc01-build.ps1
# Lab 1: builds DC01 as the first domain controller for corp.govlab.internal.
# Run ON DC01 in an admin PowerShell window, one step at a time, in this order:
#   .\dc01-build.ps1 -Step Rename       (reboots)
#   .\dc01-build.ps1 -Step Network
#   .\dc01-build.ps1 -Step Promote      (take a VirtualBox snapshot first; reboots)
#   .\dc01-build.ps1 -Step PostPromote  (sign in as GOVLAB\Administrator first)

param(
  [Parameter(Mandatory)]
  [ValidateSet("Rename","Network","Promote","PostPromote")]
  [string]$Step,
  [string]$InterfaceAlias = "Ethernet"
)

switch ($Step) {
  "Rename" {
    # Check the adapter name first; pass -InterfaceAlias later if it isn't "Ethernet".
    Get-NetAdapter
    Rename-Computer -NewName DC01 -Restart
  }

  "Network" {
    New-NetIPAddress -InterfaceAlias $InterfaceAlias -IPAddress 10.10.10.10 -PrefixLength 24 -DefaultGateway 10.10.10.1
    Set-DnsClientServerAddress -InterfaceAlias $InterfaceAlias -ServerAddresses 127.0.0.1
    hostname
    ipconfig
    ping 10.10.10.1
  }

  "Promote" {
    # Prompts for the DSRM (Directory Services Restore Mode) password. Write it down.
    Install-WindowsFeature AD-Domain-Services -IncludeManagementTools
    Install-ADDSForest -DomainName "corp.govlab.internal" -DomainNetbiosName "GOVLAB" -InstallDns `
      -SafeModeAdministratorPassword (Read-Host -AsSecureString "DSRM password") -Force
    # Expected: two yellow DNS delegation warnings (no parent zone exists). No action needed.
  }

  "PostPromote" {
    # Lets the domain resolve internet names, then verifies the new domain.
    Add-DnsServerForwarder -IPAddress 1.1.1.1
    Resolve-DnsName microsoft.com
    Get-ADDomain | Select-Object DNSRoot, NetBIOSName, PDCEmulator
  }
}
