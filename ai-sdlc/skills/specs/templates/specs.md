# Specs: <Feature Name>

- **Slug:** <slug>
- **Status:** Draft | Approved
- **Date:** YYYY-MM-DD
- **Intent:** [01-intent.md](01-intent.md)
- **Source of truth consulted:** <CLAUDE.md, AGENTS.md, other docs>

## Glossary

| Term | Meaning |
|---|---|
| <term> | <canonical definition> |

## Functional requirements

### FR-1: <Title>
<One behaviour, stated plainly.>

- **Traces to:** G-1
- **Actors:** <roles>

**Acceptance criteria**
- Given <context>, when <action>, then <outcome>.
- Given <invalid input / missing permission / dependency failure>, when <action>, then <outcome>.

## Data requirements
- <Information created/read/updated/deleted; uniqueness, required, immutable; retention; deletion behaviour; effect on existing data>

## States and lifecycle

| From | Event / trigger | To | Who can trigger |
|---|---|---|---|
| <state> | <event> | <state> | <role / system> |

- **Illegal transitions:** <and what happens if attempted>
- **Cancellation / partial failure / retry / duplicates:** <behaviour>

## Permissions

| Action | <Role A> | <Role B> | Admin | API |
|---|---|---|---|---|
| <action> | ✓ | — | ✓ | ✓ |

## Interfaces
- **Inputs and validation:** <rules>
- **Outputs:** <what the caller or user receives>
- **Errors:** <condition → what the caller is told>
- **Notifications and events:** <emitted when>
- **Contract changes:** <published contracts that must change, or "none">

## External integrations
- <Service> — <behaviour relied on> — <behaviour when slow / down / erroring>

## Edge cases
- <Case> → <expected behaviour>

## UX requirements
- **Flows:** <steps>
- **Responsive:** <behaviour>
- **Empty / loading / error states:** <behaviour>
- **Accessibility:** <requirements>
- **Copy:** <key messages>

## Non-functional requirements

### NFR-1: <Title>
- **Target:** <measurable, e.g. p95 < 150 ms at 50 rps>
- **Traces to:** G-1
- **How verified:** <test or measurement>

## Out of scope
- <Item> — <why>

## Traceability

| Goal | Requirements |
|---|---|
| G-1 | FR-1, NFR-1 |

## Assumptions
- <Default applied without asking, so it can be vetoed>

## Open questions
- <Question> → <answer once resolved>

## Decisions
- YYYY-MM-DD — <decision and why>
