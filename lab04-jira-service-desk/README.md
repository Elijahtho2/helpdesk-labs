# Lab 4: Jira Service Management Help Desk

A Jira Service Management space (`GovLab Service Desk`, key `GLS`) set up like a Tier 1 desk, then used to log and work tickets against the Lab 1 Active Directory domain.

## Configuration

**Request types** (what users pick in the portal):

| Request type | Work type | Priority |
| --- | --- | --- |
| Account locked out | Incident | High |
| Reset my password | Service request | Medium |
| Onboard a new user | Service request | Medium |
| Offboard a user | Service request | Medium |
| Request access | Service request | Medium |
| Network or DNS problem | Incident | High |
| Workstation problem | Incident | High |
| Report a suspicious email | Incident | High |
| How-to question | Service request | Low |

**SLAs** (24/7 calendar):

| Priority | Time to first response | Time to resolution |
| --- | --- | --- |
| Highest (P1) | 15m | 4h |
| High (P2) | 1h | 8h |
| Medium (P3) | 4h | 24h |
| Low (P4) | 24h | 72h |

**Workflow:** added an **Escalated** status with *Escalate*, *Hand back* and *Resolve* transitions, so Tier 1 can pass a ticket to Tier 2 and get it back.

**Queues:** Tier 1 – open · Escalated to Tier 2 · P1/P2 open · Breaching soon.

**Agents:** Elijah Thomas (admin, Tier 1) and T2 Admin (Service Desk Team, Tier 2). The T2 agent can't change space configuration (least privilege).

## Tickets worked

Five tickets worked end to end, chosen to cover an incident fix, an identity-verified request, an access denial, a security escalation and a P1 outage.

| Ticket | Request type | Outcome |
| --- | --- | --- |
| "Back from vacation and it says I'm locked out" (jsmith) | Account locked out | Unlocked on DC01 after confirming lockout and source (event 4740); resolved *Done* |
| "I forgot my password" (mlopez) | Reset my password | Identity verified by callback, temporary password set with forced change; resolved *Done* |
| "Add Jordan to the HR group so he can see the HR share" (jsmith) | Request access | Not granted: needs HR data-owner approval (least privilege); closed as *Canceled*, no AD change |
| "Is this email from IT real? It wants my password" (mlopez) | Report a suspicious email | User told not to click; labeled `security`; escalated to Tier 2 |
| "Nobody in Finance can log in" (treed) | Account locked out → P1 | DC01 outage: scoped (cached sign-ins worked, new ones failed), escalated, timed updates; recovery verified with a fresh domain sign-in; resolved *Done* |

## How each ticket was worked

1. Logged on behalf of the user with the matching request type.
2. Assigned to myself and moved to In Progress.
3. Acknowledged inside the first-response SLA with a reply to the customer.
4. Fixed it on the lab VMs (or applied policy, for access requests).
5. Internal note with commands, key output and root cause.
6. Resolved as *Done*, closed as *Canceled* when the request wasn't fulfilled, or escalated to Tier 2 with a note Tier 2 could act on without asking questions.

Screenshots are in [`screenshots/`](screenshots/).
