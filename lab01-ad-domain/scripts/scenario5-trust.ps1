# scenario5-trust.ps1
# Lab 1, Scenario 5: broken trust relationship. Write-up: ../breakfix/05-trust-relationship.md
#   Break            -> run ON DC01 (admin PowerShell)
#   Diagnose, Fix    -> run ON WS01, signed in as the local admin (.\wsadmin), admin PowerShell
# Symptom check (manual): sign in on WS01 as GOVLAB\Administrator. Don't test with a user whose
# password must change at next sign-in; Windows asks for the change before it checks the trust.

param(
  [Parameter(Mandatory)]
  [ValidateSet("Break","Diagnose","Fix")]
  [string]$Step,
  [string]$Computer = "WS01"
)

switch ($Step) {
  "Break" {
    # Resets the computer account's password on the domain side only, so it no longer matches
    # what the workstation holds (the same mismatch as restoring a PC from an old backup).
    $random = -join ((48..57) + (65..90) + (97..122) | Get-Random -Count 24 | ForEach-Object { [char]$_ })
    Get-ADComputer $Computer | Set-ADAccountPassword -Reset `
      -NewPassword (ConvertTo-SecureString "$random!" -AsPlainText -Force)
  }

  "Diagnose" {
    # Test-ComputerSecureChannel reports on the channel opened at boot, so force a fresh one first.
    nltest /sc_reset:corp.govlab.internal   # expected while broken: ERROR_ACCESS_DENIED
    Test-ComputerSecureChannel -Verbose     # expected while broken: False
  }

  "Fix" {
    # Repairs the trust in place, with no unjoin/rejoin. Prompts for GOVLAB\Administrator's password.
    Test-ComputerSecureChannel -Repair -Credential GOVLAB\Administrator
    Test-ComputerSecureChannel -Verbose     # expected: True
  }
}
