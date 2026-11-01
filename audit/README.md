# audit

A Claude Code plugin for **read-only, evidence-based codebase audits**. Each audit discovers your stack instead of assuming it, checks it against current best practice for the exact versions it finds (researched on the web, with sources), asks you a few batched questions, and reports severity-ranked findings in chat. Every finding cites `path:line` or command output.

To install, see the [marketplace README](../README.md#installation).

## Commands

| Command | Audits | Status |
|---|---|---|
| `/audit:frontend [path …] [focus]` | Browser code: SPAs, SSR and meta-frameworks, server-rendered templates with bundles, web components, design systems, extensions | Available |
| `/audit:backend` | Services, APIs, data access | Planned |
| `/audit:infra` | IaC, containers, CI/CD, cloud config | Planned |
| `/audit:tests` | Test strategy and quality | Planned |
| `/audit:e2e` | End-to-end and integration suites | Planned |
| `/audit:assets` | Images, fonts, media, static files | Planned |
| `/audit:all [domain …] [--skip domain …]` | Every available domain, merged into one report | Available |

## How an audit runs

1. **Discover:** find every repo, workspace package, and app in scope, including nested and multi-repo layouts. Out-of-scope code is listed with the reason.
2. **Gate 1:** you confirm the inventory, the priorities, and which branch is production.
3. **Baseline:** for each stack, research current best practice for that exact major version (support/EOL dates, deprecated APIs, recommended lint, test, and build settings) and write a short "what good looks like" paragraph to measure against.
4. **Gate 2:** you choose priorities, what it may run (static only by default), depth, and anything to steer toward or away from.
5. **Audit:** dimension by dimension in your priority order, then cross-repo consistency.
6. **Report:** in chat: headline, inventory, top findings, per-unit notes, clean dimensions, drift, quick wins, what couldn't be verified, and open questions.

`/audit:all` runs discovery and both gates **once** for every domain, has an independent `auditor` agent audit each domain in parallel, then deduplicates, re-ranks, and adds cross-domain findings, such as a front end and back end that disagree on the auth model.

### Front-end dimensions

Security (including privacy), dependencies and supply chain, accessibility, test quality, performance, architecture and maintainability, and tooling and developer experience.

## Safety

Audits never edit, format, or commit your code. Without your approval at Gate 2 they only read files, run lockfile-only vulnerability audits, and search the web. If you allow installs, builds, or tests, they run in a disposable `git archive` export, never in your working tree, with lifecycle scripts disabled and the lockfile frozen. Committed secrets are reported by location, never printed.

## Severity and confidence

| Severity | Meaning |
|---|---|
| Critical | Exploitable now, exposes credentials or user data, or blocks shipping |
| High | Likely to cause an incident or security issue soon |
| Medium | A real, ongoing cost that isn't urgent |
| Low | Hygiene |

Every claim is tagged `[Certain]` (seen), `[Likely]` (strong inference), or `[Guessing]` (gap-filling).

## Adding a domain

1. Create `skills/<domain>/SKILL.md` with `disable-model-invocation: true`.
2. Have it read `references/contract.md` and follow its ground rules, finding format, gates, and delegated mode.
3. Give it `Phase 1: Discover` (ending in Gate 1), `Phase 2` (ending in Gate 2), its checks, and a report section that returns the delegated report in delegated mode.
4. Pick an ID prefix and add the domain to the table in `skills/all/SKILL.md`. `/audit:all` picks up any new `skills/` directory automatically. The table only fixes report order and prefixes.
5. Add an `Overlap` note if your checks overlap an existing domain.
