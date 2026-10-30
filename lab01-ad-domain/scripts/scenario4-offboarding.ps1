# scenario4-offboarding.ps1
# Lab 1, Scenario 4: offboarding and rehire. Write-up: ../breakfix/04-offboarding.md
# Run ON DC01 (admin PowerShell).
# Leavers are disabled and moved, never deleted, so history and group memberships are kept.

param(
  [Parameter(Mandatory)]
  [ValidateSet("Offboard","Diagnose","Rehire")]
  [string]$Step,
  [string]$User = "dchan"
)

$base = "DC=corp,DC=govlab,DC=internal"

switch ($Step) {
  "Offboard" {
    Disable-ADAccount $User
    Get-ADUser $User | Move-ADObject -TargetPath "OU=Disabled,OU=GovLab,$base"
  }

  "Diagnose" {
    Get-ADUser $User -Properties Enabled | Select-Object Name,Enabled,DistinguishedName
  }

  "Rehire" {
    Enable-ADAccount $User
    Get-ADUser $User | Move-ADObject -TargetPath "OU=Staff,OU=GovLab,$base"
    Get-ADUser $User -Properties Enabled | Select-Object Name,Enabled,DistinguishedName
  }
}
