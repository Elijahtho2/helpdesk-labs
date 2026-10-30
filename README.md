# Help Desk Labs: Active Directory + Jira Service Management

Hands-on Tier 1 / IT support labs built on my laptop: a Windows Server 2025 Active Directory domain with two Windows 11 workstations, then a Jira Service Management desk used to log and work tickets against that domain. Every scenario was broken on purpose, diagnosed, fixed and documented.

## Lab environment

| Machine | Role | OS | IP |
| --- | --- | --- | --- |
| DC01 | Domain controller + DNS (`corp.govlab.internal`) | Windows Server 2025 | 10.10.10.10 |
| WS01 | Domain-joined workstation | Windows 11 Enterprise | 10.10.10.101 |
| WS02 | Domain-joined workstation | Windows 11 Enterprise | 10.10.10.102 |

Hypervisor: VirtualBox, isolated NAT network (10.10.10.0/24). Ticketing: Jira Service Management Cloud.

## Labs

| Lab | What it covers |
| --- | --- |
| [Lab 1: AD domain](lab01-ad-domain/) | Domain build, OU/group/user provisioning in PowerShell, Help Desk delegation, 5 break/fix scenarios |
| [Lab 4: Jira service desk](lab04-jira-service-desk/) | Request types, priority-based SLAs, escalation workflow, queues, tickets worked end to end |

## Skills demonstrated

- Active Directory: users, groups, OUs, account lockout, password resets, offboarding and rehire
- Least-privilege delegation (Help Desk can reset and unlock, but can't change group membership)
- PowerShell administration (ActiveDirectory module, RSAT)
- DNS troubleshooting for domain sign-in (SRV records, `nltest`)
- Domain trust / secure channel repair
- Jira Service Management: request types, SLAs, queues, workflows, escalation
- Troubleshooting method: symptom → diagnosis → root cause → fix → verification → prevention
