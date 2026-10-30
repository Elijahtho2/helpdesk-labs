# create-users.ps1
# Lab 1 (corp.govlab.internal): builds the GovLab OU structure, groups and four users.
# Run on DC01 in an admin PowerShell window. Prompts once for the initial password.

$base = "DC=corp,DC=govlab,DC=internal"

New-ADOrganizationalUnit -Name "GovLab" -Path $base
"Staff","Workstations","Groups","Disabled" | ForEach-Object {
  New-ADOrganizationalUnit -Name $_ -Path "OU=GovLab,$base"
}

"GG-HelpDesk","GG-Finance","GG-HR" | ForEach-Object {
  New-ADGroup -Name $_ -GroupScope Global -Path "OU=Groups,OU=GovLab,$base"
}

$pw = Read-Host -AsSecureString "Initial password"

$users = @(
  @{F="Jordan";L="Smith";Sam="jsmith";G="GG-Finance"},
  @{F="Maria";L="Lopez";Sam="mlopez";G="GG-HR"},
  @{F="Derek";L="Chan";Sam="dchan";G="GG-Finance"},
  @{F="Tasha";L="Reed";Sam="treed";G="GG-HelpDesk"}
)

foreach ($u in $users) {
  New-ADUser -Name "$($u.F) $($u.L)" -GivenName $u.F -Surname $u.L `
    -SamAccountName $u.Sam -UserPrincipalName "$($u.Sam)@corp.govlab.internal" `
    -Path "OU=Staff,OU=GovLab,$base" -AccountPassword $pw -Enabled $true `
    -ChangePasswordAtLogon $true
  Add-ADGroupMember -Identity $u.G -Members $u.Sam
}

Get-ADUser -Filter * -SearchBase "OU=Staff,OU=GovLab,$base" | Select-Object Name, SamAccountName
