# Plan: <Feature Name>

- **Slug:** <slug>
- **Status:** Draft | Approved
- **Date:** YYYY-MM-DD
- **Design:** [03-design.md](03-design.md)
- **Source of truth consulted:** <CLAUDE.md, AGENTS.md, other docs>

## Commands

| Purpose | Command |
|---|---|
| Single test | `<command>` |
| Full suite | `<command>` |
| Lint / types | `<command>` |
| Migrations | `<command>` |

## Critical path
T-1 → T-3 → T-5 → …

## Milestones

### M1: <Milestone name>
<What works, and is deployable, when this milestone is complete.>

- [ ] **T-1: <Spike — question to answer>** *(spike, time-box: <n>h)*
  - **Question:** <what we need to learn>
  - **Done when:** the answer is recorded in `Decisions` below.

- [ ] **T-2: <Task title>**
  - **Files:** `path/to/file` (new), `path/to/other`
  - **Delivers:** FR-1; design § <component>
  - **Depends on:** T-1
  - **Failing test first:** `tests/path::test_name` — asserts <behaviour>
  - **Steps:**
    1. Write the failing test and run it to see it fail.
    2. Implement <change>.
    3. Run the test to see it pass; run the related suite.
  - **Done when:** `<command>` passes
  - **Risk:** <low / medium / high — why> · **Parallel:** with T-3

### M2: <Milestone name>
- [ ] **T-n: <Rollout — migrate / backfill / enable flag>**
  - **Steps:** <…>
  - **Rollback:** <how>
  - **Done when:** <check>

- [ ] **T-n: Verification — end-to-end smoke test**
  - **Checks:** <each intent goal exercised end to end>
  - **Done when:** <command or manual checklist passes>

- [ ] **T-n: Docs sync**
  - **Files:** `CLAUDE.md`, `AGENTS.md`, `<contract doc>`
  - **Done when:** docs describe the shipped behaviour.

## Coverage

| Requirement / design element | Tasks |
|---|---|
| FR-1 | T-2 |
| <component / migration / interface> | T-2, T-4 |

## Risks during implementation
- <Risk> → <mitigation>

## Assumptions
- <Default applied without asking, so it can be vetoed>

## Open questions
- <Question> → <answer once resolved>

## Decisions
- YYYY-MM-DD — <decision and why>
