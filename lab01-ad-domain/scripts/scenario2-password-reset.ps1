# scenario2-password-reset.ps1
# Lab 1, Scenario 2: forgotten password. Write-up: ../breakfix/02-password-reset.md
# Run ON DC01 (admin PowerShell).
# BEFORE the Fix step: verify the caller's identity (callback to the number on file,
# or manager confirmation) and record the method in the ticket.

param(
  [Parameter(Mandatory)]
  [ValidateSet("Diagnose","Fix")]
  [string]$Step,
  [string]$User = "mlopez"
)

switch ($Step) {
  "Diagnose" {
    # Confirms it's a forgotten password, not a lockout or a disabled account.
    Get-ADUser $User -Properties Enabled,PasswordLastSet,PasswordExpired,LockedOut |
      Select-Object Name,Enabled,PasswordLastSet,PasswordExpired,LockedOut
  }

  "Fix" {
    # Prompts for a temporary password; give it to the user by phone, never by email.
    Set-ADAccountPassword $User -Reset -NewPassword (Read-Host -AsSecureString "Temporary password")
    Set-ADUser $User -ChangePasswordAtLogon $true
    Get-ADUser $User -Properties pwdLastSet | Select-Object Name,@{n="MustChangeAtNextLogon";e={$_.pwdLastSet -eq 0}}
  }
}
