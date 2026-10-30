# scenario1-lockout.ps1
# Lab 1, Scenario 1: account lockout. Write-up: ../breakfix/01-lockout.md
#   Policy, Diagnose, Fix  -> run ON DC01 (admin PowerShell)
#   Tier1                  -> run ON WS01 in a PowerShell window started as GOVLAB\treed:
#                             runas /user:GOVLAB\treed powershell
#                             (WS01 needs RSAT first:
#                              Add-WindowsCapability -Online -Name Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0)
# Break (manual): on WS01, sign in as GOVLAB\jsmith with a wrong password 5 times.

param(
  [Parameter(Mandatory)]
  [ValidateSet("Policy","Diagnose","Fix","Tier1")]
  [string]$Step,
  [string]$User = "jsmith"
)

switch ($Step) {
  "Policy" {
    # 5 bad attempts within 15 minutes locks the account for 15 minutes.
    Set-ADDefaultDomainPasswordPolicy -Identity corp.govlab.internal -LockoutThreshold 5 `
      -LockoutDuration 00:15:00 -LockoutObservationWindow 00:15:00
  }

  "Diagnose" {
    Search-ADAccount -LockedOut
    Get-ADUser $User -Properties LockedOut,BadLogonCount,LastBadPasswordAttempt |
      Select-Object Name,LockedOut,BadLogonCount,LastBadPasswordAttempt
    # Event 4740's "Caller Computer Name" shows where the bad attempts came from.
    # If none appear: auditpol /set /subcategory:"User Account Management" /success:enable
    Get-WinEvent -FilterHashtable @{LogName='Security';Id=4740} -MaxEvents 5 |
      Format-List TimeCreated,Message
  }

  "Fix" {
    Unlock-ADAccount $User
    Get-ADUser $User -Properties LockedOut | Select-Object Name,LockedOut
  }

  "Tier1" {
    # Proves least-privilege delegation: the unlock succeeds, the group change is denied.
    Unlock-ADAccount $User
    Get-ADUser $User -Properties LockedOut | Select-Object Name,LockedOut
    Add-ADGroupMember GG-HR -Members $User   # expected: "Insufficient access rights"
  }
}
