# join-workstation.ps1
# Lab 1: points a Windows 11 workstation at DC01 for DNS and joins it to corp.govlab.internal.
# Run ON THE WORKSTATION, signed in as the local admin (.\wsadmin), in an admin PowerShell window.
#   WS01:  .\join-workstation.ps1 -ComputerName WS01 -IPAddress 10.10.10.101
#   WS02:  .\join-workstation.ps1 -ComputerName WS02 -IPAddress 10.10.10.102
# DC01 must be running. Prompts for GOVLAB\Administrator's password, then restarts.

param(
  [Parameter(Mandatory)][string]$ComputerName,
  [Parameter(Mandatory)][string]$IPAddress,
  [string]$InterfaceAlias = "Ethernet"
)

New-NetIPAddress -InterfaceAlias $InterfaceAlias -IPAddress $IPAddress -PrefixLength 24 -DefaultGateway 10.10.10.1
Set-DnsClientServerAddress -InterfaceAlias $InterfaceAlias -ServerAddresses 10.10.10.10

# Stop here if the domain can't be found; the join would fail with "domain could not be contacted".
$found = Resolve-DnsName corp.govlab.internal -ErrorAction SilentlyContinue
if (-not $found) {
  Write-Error "Can't resolve corp.govlab.internal. Check that DC01 is running and DNS points at 10.10.10.10."
  return
}

Add-Computer -DomainName corp.govlab.internal -NewName $ComputerName -Credential GOVLAB\Administrator -Restart

# After both workstations have joined, run this ON DC01 to move them into the Workstations OU:
#   $base = "DC=corp,DC=govlab,DC=internal"
#   Get-ADComputer -Filter 'Name -like "WS*"' | Move-ADObject -TargetPath "OU=Workstations,OU=GovLab,$base"
#   Get-ADComputer -Filter * | Select-Object Name, DistinguishedName
