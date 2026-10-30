# scenario3-wrong-dns.ps1
# Lab 1, Scenario 3: wrong DNS server on a workstation. Write-up: ../breakfix/03-wrong-dns.md
# Run ON WS02, signed in as the local admin (.\wsadmin), in an admin PowerShell window.
# Test the symptom with a user who has never signed in on WS02 (dchan), so cached
# credentials can't hide the failure.

param(
  [Parameter(Mandatory)]
  [ValidateSet("Break","Diagnose","Fix")]
  [string]$Step,
  [string]$InterfaceAlias = "Ethernet"
)

switch ($Step) {
  "Break" {
    Set-DnsClientServerAddress -InterfaceAlias $InterfaceAlias -ServerAddresses 8.8.8.8
    # Windows caches where the DC is; without a flush and restart, sign-ins may still reach DC01.
    ipconfig /flushdns
    Restart-Computer
  }

  "Diagnose" {
    ipconfig /all
    nslookup corp.govlab.internal
    nltest /dsgetdc:corp.govlab.internal
    # Key test: clients find domain controllers through this SRV record.
    Resolve-DnsName _ldap._tcp.dc._msdcs.corp.govlab.internal -Type SRV
  }

  "Fix" {
    Set-DnsClientServerAddress -InterfaceAlias $InterfaceAlias -ServerAddresses 10.10.10.10
    ipconfig /flushdns
    nltest /dsgetdc:corp.govlab.internal   # expected: \\DC01.corp.govlab.internal
  }
}
