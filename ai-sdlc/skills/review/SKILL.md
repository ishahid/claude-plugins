---
name: review
description: Stage 5 of the AI SDLC. Final gate before implementation — rigorously review the intent, specs, design, and plan against each other and the codebase, resolve open questions with the user, and apply the approved fixes directly to those documents. Produces no new file.
argument-hint: "<feature slug>"
disable-model-invocation: true
---

# /ai-sdlc:review — Pre-Implementation Review

You are running **stage 5 of 5** of the AI SDLC (`intent → specs → design → plan → review`).
This is the **final check before any implementation starts**. Nothing gets built until these documents are right.
Be rigorous and specific. Don't praise, and don't pad.

## Input

`$ARGUMENTS` — the feature slug. If empty, list folders under `docs/ai-sdlc/` and ask which one.

## Preconditions

- `01-intent.md` through `04-plan.md` exist in `docs/ai-sdlc/<slug>/`. If any is missing, stop and point the user at the missing stage.
- This stage writes no document of its own: findings are presented in the conversation and fixes go straight into the existing documents.
- If `04-plan.md`'s `Decisions` section has an earlier `Review` entry, this is a re-review: read it, review everything afresh, and carry forward any findings still `Deferred` or `Rejected` so they aren't lost.

## 1. Load context

- Read every document in `docs/ai-sdlc/<slug>/`, including anything beyond the four stage documents.
- Read the project's own source of truth for architecture and conventions — `CLAUDE.md`, `AGENTS.md`, and whichever docs they point to that this feature touches (schema, API contracts, patterns, testing). Treat the invariants they state as rules the documents must not break.
- Spot-check the actual code wherever the documents make claims about the current state (models, services, endpoints, routes, config). Never assume something exists.

## 2. Review

Check each document against the others and against the codebase.

**Approvals**
- Each of `01-intent.md` to `04-plan.md` is `Status: Approved`. Any that isn't is a Blocker.

**Traceability**
- Every intent goal (`G-n`) is covered by a spec requirement, a design element, and at least one plan task.
- Flag orphans in both directions: a goal nothing covers, or a requirement, design element, or task that serves no goal (scope creep).
- Non-goals are stated, and nothing contradicts them.

**Correctness and consistency**
- Contradictions between documents: names, fields, states, numbers, flows, interfaces.
- Conflicts with the invariants in the project's source-of-truth docs.
- Claims about existing code that are wrong or stale.
- Design decisions the plan ignores.

**Completeness** — check whichever of these the feature touches:
- **Data model:** fields, constraints, indexes, migrations and their ordering, backfill or data migration, deletion behaviour.
- **State machines:** every state, transition, and illegal transition, including cancellation, partial failure, retries, and idempotency.
- **Edge cases:** concurrency and race conditions, timezones, limits and capacity, zero/empty values, deleted or suspended owners.
- **Permissions:** which roles can do what; admin and API-key scope.
- **Interfaces:** endpoints, error codes, wire format, events, and whether published contracts must change.
- **External integrations:** third-party flows, webhooks, failure and retry handling.
- **Non-functional:** measurable performance targets, N+1 and caching risks, security and PII, audit events, observability, feature flags, rollout and rollback.
- **UX:** responsive layouts, empty/error/loading states, accessibility, copy.
- Open questions left unresolved; acceptance criteria that aren't testable.

**Plan quality**
- Tasks are ordered by dependency (including across packages or repos) and small enough for a red/green TDD cycle.
- Each task names its files, the failing test to write first, and a concrete "done when" check.
- Dependencies, risky or unknown steps, and spikes are called out.
- There is a final verification/smoke-test task, and a docs-sync task for any source-of-truth docs this feature changes.
- Each milestone leaves the system working.

**Risks**
- Every risk named in the design or plan has a mitigation. Flag significant risks that aren't mentioned at all.

**Improvement opportunities**
- Simpler designs, reuse of existing code, and scope that could be cut or deferred.

## 3. Present findings

Don't edit any document yet, and don't write a review file. Present to the user in the conversation:

1. **Verdict** (one line): `Ready` / `Ready with fixes` / `Not ready`.
   - **Ready** — no findings above Suggestion.
   - **Ready with fixes** — only Minor findings, or Majors whose fixes are clear and don't need decisions.
   - **Not ready** — any Blocker, or Majors that need decisions or rework of a stage.
2. **Findings table**, sorted by severity:

   | # | Severity | Doc § location | Finding | Proposed fix |
   |---|---|---|---|---|

   Severity is `Blocker` / `Major` / `Minor` / `Suggestion`. Keep each finding to one or two sentences and cite the exact file and section. Group by document if there are more than 15.
3. **Traceability gaps:** a short list of goal ↔ spec ↔ design ↔ plan mismatches.
4. **Assumptions I'll apply:** things you can settle yourself with a sensible default, listed so the user can veto them.
5. **Open questions:** only things you cannot settle from the documents or the code. Ask them with the AskUserQuestion tool in batches of up to 4, highest severity first. Each question gets 2–4 concrete options, with your recommended option first and marked "(Recommended)".

Then stop and wait for answers and for approval of the proposed fixes.

## 4. Apply

Once the user has answered and approved:

- Update only the affected documents (`01-intent.md` to `04-plan.md`), with minimal targeted edits that keep each document's structure and voice. Fix the same fact in every document that states it, so they stay consistent.
- Record the decisions in the `Decisions` section of the most relevant document, dated today.
- Keep each edited document at `Status: Approved` — the user approved these edits as part of this review.
- If the project's source-of-truth docs (`CLAUDE.md`, `AGENTS.md`, and the docs they point to) must change because of this feature, add those changes as plan tasks. Don't edit those files now unless the user says so.
- If a finding needs a stage redone rather than patched, say which (e.g. `/ai-sdlc:design <slug>`) instead of rewriting it here.
- Add one dated entry to the `Decisions` section of `04-plan.md`, headed `Review <today>`, with the final verdict and a line for every finding left `Deferred` or `Rejected` and why. Fixed findings need no entry beyond the decisions already recorded.
- Don't create `05-review.md` or any other new file.
- Don't commit.
- Finish with `git diff --stat docs/ai-sdlc/<slug>/`, a summary of what changed in five bullets or fewer, and any findings left unresolved (deferred or rejected) with the reason.

If the final verdict is **Ready**, summarize the plan's milestones and ask the user whether to begin implementing `04-plan.md`.
