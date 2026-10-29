# ai-sdlc

A Claude Code plugin that walks a feature through a staged, artifact-driven **AI software development lifecycle**:

```
/ai-sdlc:intent  →  /ai-sdlc:specs  →  /ai-sdlc:design  →  /ai-sdlc:plan  →  /ai-sdlc:review
     why               what               how               steps             ready to build?
```

Each stage reads the approved output of the previous one, interviews you to fill gaps, and writes a Markdown document into your repo. Nothing moves forward until you sign off, so code only gets written once intent, requirements, design, and tasks are all agreed, and the review has checked them all together as the final gate before implementation.

To install, see the [marketplace README](../README.md#installation).

---

## Contents

- [Quick start](#quick-start)
- [The stages](#the-stages)
- [Output layout](#output-layout)
- [How it works](#how-it-works)
- [Configuration](#configuration)
- [Customizing](#customizing)

---

## Quick start

```
/ai-sdlc:intent user invitations
```

Answer the questions, approve the intent, then continue with the slug it gives you:

```
/ai-sdlc:specs user-invitations
/ai-sdlc:design user-invitations
/ai-sdlc:plan user-invitations
/ai-sdlc:review user-invitations
```

The review presents its findings, asks you about anything it can't settle, and — once you approve — fixes the documents itself. When the verdict is **Ready**, Claude offers to start implementing the plan task by task.

---

## The stages

| Command | Question it answers | Reads | Writes |
|---|---|---|---|
| `/ai-sdlc:intent <idea>` | **Why** are we building this, for whom, and how will we know it worked? | project docs, codebase | `01-intent.md` |
| `/ai-sdlc:specs <slug>` | **What** must the system do, in testable terms? | intent, project docs, codebase | `02-specs.md` |
| `/ai-sdlc:design <slug>` | **How** will we build it, and what trade-offs are we accepting? | intent, specs, project docs, codebase | `03-design.md` |
| `/ai-sdlc:plan <slug>` | **In what steps** do we implement it, and how is each step verified? | intent, specs, design, project docs, codebase | `04-plan.md` |
| `/ai-sdlc:review <slug>` | **Are we ready to build?** Do all documents hold together? | every document in the feature folder, project docs, codebase | updates the existing documents; no new file |

Stages 1–4 share the same rigour as the review:

- **Grounded in your project.** Each reads your `CLAUDE.md` / `AGENTS.md` (and the docs they point to) as the source of truth for architecture and invariants, and checks the real code before making any claim about it.
- **Questions with a recommendation.** Anything it can't settle is asked as multiple choice, up to four at a time, with a recommended option first. Things it can decide itself are listed as assumptions you can veto.
- **Self-check before you see it.** Each stage checks its own traceability, testability, consistency, and feasibility before presenting.
- **Stable IDs and revise mode.** Goals (`G-n`), requirements (`FR-n`, `NFR-n`), decisions (`D-n`), and tasks (`T-n`) keep their IDs. Re-running a stage on an existing document makes minimal edits, records a dated decision, and tells you which later stages need re-running.
- **Never commits.** Each stage ends with a `git diff --stat` of the feature folder.

### 1. Intent

Problem and its evidence, users, current workaround, why now, desired outcome, numbered goals (`G-n`) each with a measurable metric (baseline → target), non-goals, scope, stakeholders, constraints and applicable invariants, dependencies, prior art in the codebase, risks, and open questions. Outcomes only — no solutions yet.

### 2. Specs

A glossary of canonical terms; functional requirements (`FR-n`) each traced to a goal with Given/When/Then criteria for happy **and** failure paths; data requirements; states and lifecycle including illegal transitions, retries, and idempotency; a permissions matrix; interfaces and errors; external integrations and their failure behaviour; edge cases; UX requirements; and non-functional requirements (`NFR-n`) with measurable targets. Behaviour, not implementation.

### 3. Design

Two or three approaches with trade-offs and a recommended choice; then architecture (Mermaid), components with real file paths, data model with constraints, indexes, migrations and backfills, state machines, interfaces and error codes, integrations, permission enforcement, concurrency, error handling, security and privacy, performance against each NFR, observability and audit, UX implementation, rollout and rollback, testing strategy, impact on your source-of-truth docs, ADR-style decisions (`D-n`), and a requirement-to-design mapping. Every referenced file is verified or marked **new**.

### 4. Plan

Milestones that each leave the system deployable, with spikes for unknowns first. Every task (`T-n`) is one red/green TDD cycle and lists its files, the requirements and design elements it delivers, its dependencies, the failing test to write first, and a **done when** check that is a real command from your project. Includes rollout tasks with rollbacks, a final end-to-end verification task, a docs-sync task, the critical path, parallelizable tasks, and a coverage table.

### 5. Review

The final gate before any code is written. It works in four phases:

1. **Load context** — reads every document for the feature, your project's `CLAUDE.md` / `AGENTS.md` (and the docs they point to) as the source of truth for architecture and invariants, and spot-checks the real code wherever the documents describe it.
2. **Review** — checks approvals; traceability in both directions (every goal covered, nothing untraced); contradictions between documents, with your project's invariants, or with the current code; completeness across data model, state machines, edge cases, permissions, interfaces, integrations, non-functional targets, and UX; plan quality (dependency order, test-first tasks, done-when checks, spikes, a smoke-test and docs-sync task); risks; and opportunities to simplify, reuse, or cut scope.
3. **Present findings** — shows, in the conversation, a verdict (**Ready** / **Ready with fixes** / **Not ready**), a findings table ranked `Blocker` / `Major` / `Minor` / `Suggestion` with a proposed fix for each, traceability gaps, and the assumptions it will apply unless you veto them. Questions it can't settle from the docs or code are asked as multiple choice, with a recommended option. Then it stops for your answers and approval.
4. **Apply** — makes minimal edits to the affected documents, fixing the same fact everywhere it appears; records decisions in a dated `Decisions` section; adds plan tasks for any changes your source-of-truth docs need; logs the verdict and any `Deferred` / `Rejected` findings in a dated `Review` entry in the plan's `Decisions` section; and finishes with a `git diff --stat` and a short summary. It never commits.

---

## Output layout

All documents live in your project, so they're versioned and reviewable in pull requests:

```
docs/ai-sdlc/
└── user-invitations/
    ├── 01-intent.md
    ├── 02-specs.md
    ├── 03-design.md
    └── 04-plan.md
```

Documents 01–04 have a `Status: Draft | Approved` header; `review` writes no document of its own and edits these in place. Stages 2–4 warn you if the previous document is not yet approved; the review treats any unapproved document as a Blocker. Re-running a stage revises its existing document rather than starting over.

---

## How it works

- **Skills, namespaced by plugin.** Each stage is a skill in `skills/<stage>/SKILL.md`. Claude Code prefixes plugin skills with the plugin name, which is what produces `/ai-sdlc:<stage>`.
- **User-invoked only.** Every skill sets `disable-model-invocation: true`, so Claude never jumps into a stage on its own — you decide when to advance.
- **Arguments.** Text after the command is passed to the skill as `$ARGUMENTS` (the idea for `intent`, the slug for the rest). If you omit the slug, the skill lists existing features and asks.
- **Templates.** Each stage except `review` ships a Markdown template in its `templates/` folder that defines the document's shape. How closely it is followed depends on the [template mode](#configuration).
- **Gates.** Each stage checks that the prior documents exist and are approved, traces its output back to them in both directions, and ends by asking for your sign-off.

---

## Configuration

The plugin has one option, **Template mode**, which controls how closely each stage follows its template:

| Mode | Behaviour |
|---|---|
| `guide` (default) | The template is a starting point. Claude adds, merges, reorders, or leaves out sections to suit the feature, but always keeps the parts later stages rely on: the header lines, the IDs (`G-n`, `FR-n`, `NFR-n`, `D-n`, `T-n`), the traceability and coverage tables, and the `Decisions` section. |
| `strict` | Every section of the template, in order, with its headings, tables, and ID formats. Sections that don't apply say "Not applicable — <reason>". |

Change it in Claude Code with `/config` or `/plugin configure ai-sdlc@ishahid`, or from your shell:

```bash
echo '{"template_mode": "strict"}' | claude plugin configure ai-sdlc@ishahid --values-stdin
```

The value is saved per user, and takes effect the next time you run a stage.

---

## Customizing

- **Change a document's shape:** edit the template in `skills/<stage>/templates/`.
- **Change a stage's behavior:** edit the steps and exit criteria in `skills/<stage>/SKILL.md`.
- **Change where documents go:** replace `docs/ai-sdlc/` in the five `SKILL.md` files.
- **Let Claude invoke stages automatically:** remove `disable-model-invocation: true` from a skill's frontmatter.
- **Add a stage** (e.g. `/ai-sdlc:build` or `/ai-sdlc:release`): create `skills/<name>/SKILL.md` with `name`, `description`, and `argument-hint` frontmatter, and have it read the previous stage's document.

---

## License

[MIT](../LICENSE)
