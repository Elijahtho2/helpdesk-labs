# Lab 1: Active Directory Domain

A Windows Server 2025 domain (`corp.govlab.internal`) with two Windows 11 Enterprise workstations, built from scratch in VirtualBox and used to practice the most common Tier 1 identity tickets.

## Build

1. **DC01:** renamed, static IP 10.10.10.10, promoted to a new forest (`corp.govlab.internal`, NetBIOS `GOVLAB`) with DNS and a forwarder to the internet.
2. **Directory structure:** OUs `Staff`, `Workstations`, `Groups` and `Disabled` under `GovLab`; global groups `GG-HelpDesk`, `GG-Finance` and `GG-HR`; four users provisioned with [`scripts/create-users.ps1`](scripts/create-users.ps1).
3. **Delegation:** on the Staff OU, `GG-HelpDesk` was given *Reset password* plus read/write on `lockoutTime`, so Tier 1 can reset and unlock without Domain Admin.
4. **Workstations:** WS01 (10.10.10.101) and WS02 (10.10.10.102) pointed at DC01 for DNS, joined to the domain, and moved to the Workstations OU.
5. **Checkpoint:** `GOVLAB\jsmith` signed in on WS01, and `whoami /groups` showed `GOVLAB\GG-Finance`.

| User | Name | Group |
| --- | --- | --- |
| jsmith | Jordan Smith | GG-Finance |
| mlopez | Maria Lopez | GG-HR |
| dchan | Derek Chan | GG-Finance |
| treed | Tasha Reed | GG-HelpDesk (Tier 1) |

## Scripts

Each scenario script takes a `-Step` parameter, so break, diagnose and fix run separately, the way a ticket is worked.

| Script | Runs on | What it does |
| --- | --- | --- |
| [`dc01-build.ps1`](scripts/dc01-build.ps1) | DC01 | Rename, static IP, forest promotion, DNS forwarder |
| [`create-users.ps1`](scripts/create-users.ps1) | DC01 | OUs, groups and the four lab users |
| [`join-workstation.ps1`](scripts/join-workstation.ps1) | WS01 / WS02 | IP and DNS, domain join |
| [`scenario1-lockout.ps1`](scripts/scenario1-lockout.ps1) | DC01 / WS01 | Lockout policy, diagnose (event 4740), unlock, Tier 1 test |
| [`scenario2-password-reset.ps1`](scripts/scenario2-password-reset.ps1) | DC01 | Check the account, reset with forced change |
| [`scenario3-wrong-dns.ps1`](scripts/scenario3-wrong-dns.ps1) | WS02 | Break DNS, diagnose with SRV lookup, fix |
| [`scenario4-offboarding.ps1`](scripts/scenario4-offboarding.ps1) | DC01 | Offboard, diagnose, rehire |
| [`scenario5-trust.ps1`](scripts/scenario5-trust.ps1) | DC01 / WS01 | Break the trust, diagnose, repair the secure channel |

## Break/fix scenarios

| # | Scenario | Key skill | Write-up |
| --- | --- | --- | --- |
| 1 | Account lockout | Event 4740 Caller Computer Name; unlock as Tier 1; cached-credential gotcha | [01-lockout.md](breakfix/01-lockout.md) |
| 2 | Forgotten password | Identity verification before reset; force change at next sign-in | [02-password-reset.md](breakfix/02-password-reset.md) |
| 3 | Wrong DNS server | SRV lookup and `nltest` to prove DNS is the cause | [03-wrong-dns.md](breakfix/03-wrong-dns.md) |
| 4 | Offboarding / rehire | Disable and move to the Disabled OU instead of deleting | [04-offboarding.md](breakfix/04-offboarding.md) |
| 5 | Broken trust relationship | `Test-ComputerSecureChannel -Repair` without unjoining | [05-trust-relationship.md](breakfix/05-trust-relationship.md) |

Screenshots for every step are in [`screenshots/`](screenshots/).

## What I'd tell an interviewer

- Check lockout status on the domain controller, not the workstation: cached credentials let a locked-out user in on WS01.
- "No logon servers" / "domain isn't available" is usually DNS. Clients find DCs through SRV records only AD DNS can answer.
- `Test-ComputerSecureChannel` reports on the channel opened at boot. Force a fresh check with `nltest /sc_reset` before trusting a "True."
