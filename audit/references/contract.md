# Audit contract

Every audit domain (`frontend`, and later `backend`, `infra`, `tests`, `e2e`, `assets`) follows this contract, and `/audit:all` relies on it to run several domains together and merge their results. A domain skill adds its own discovery, questions, and checks. It does not redefine anything here.

## Ground rules

- **Read-only.** Never edit, format, stage, commit, or push anything in the audited repositories. Never run fix commands (`npm audit fix`, `eslint --fix`, `prettier --write`, codemods, `ng update`, …).
- **Scratch space.** Create it with `mktemp -d` and delete it when you finish. Put nothing in the audited repos.
- **Commands that write or execute repo code** (install, build, test, lint with plugins, dev servers) run only after the user approves them at Gate 2. Even then:
  - Run them in a disposable export of the confirmed production ref (Gate 1), not the working tree: `git -C <repo> archive <prod-ref> | tar -x -C "$scratch/<repo>"`. If the build needs uncommitted config, record that as a finding and skip the step. Never copy `.env` or other secret files into scratch.
  - Install with lifecycle scripts disabled first (`npm ci --ignore-scripts`, `pnpm install --frozen-lockfile --ignore-scripts`, `yarn install --immutable --mode=skip-build`). If something only works with scripts on (native binaries such as esbuild, swc, sharp), ask before re-running. In delegated mode, don't re-run: record the step under `Could not verify` with the reason.
- **Audit the production ref.** If it isn't the checked-out `HEAD`, read files with `git show <ref>:<path>` and search with `git grep <pattern> <ref>`. Both are read-only and need no checkout. If the working tree has uncommitted changes or sits on a different ref, say so under `Could not verify`.
  - Use the lockfile (`ci`, `--frozen-lockfile`, `--immutable`). Never re-resolve dependencies.
  - Allow about 5 minutes per command. Stop anything longer and record it under "Could not verify".
- **Allowed without asking:** reading files, `git log`/`show`/`blame`, `grep`/`rg`/`find`, lockfile-only audits (`npm audit --package-lock-only`, `pnpm audit`, `osv-scanner` if already installed), and web search.
- **Never:** install anything globally, use credentials the user did not provide, contact production systems, or send repository content to any service other than the package registry and web search.
- **Secrets.** When you find a committed secret, cite its `path:line` and the kind of secret. Never print the value. Show at most the first 4 characters.

## Evidence and confidence

- Every finding cites evidence: `path:line`, or the command you ran plus the relevant lines of its output. A claim with no evidence is not a finding. Move it to "Open questions".
- Tag every claim with one of:
  - `[Certain]`: you saw it in the code or in command output.
  - `[Likely]`: a strong inference from what you saw. Say what you saw.
  - `[Guessing]`: filling a gap. If most of a section is `[Guessing]`, say so at the top of that section.
- Best-practice claims cite a source and its date (official docs, release notes, the EOL schedule). Recommendations from memory, used because web search was unavailable or failed, are tagged `[Guessing]` with "from memory, as of <your knowledge date>".
- Count instead of saying "many". `rg -c` beats "lots of `any`".

## Severity

| Severity | Meaning | Examples |
|---|---|---|
| **Critical** | Exploitable now, exposes credentials or user data in production, or blocks shipping. | Live secret committed; XSS sink fed by user input; production build broken. |
| **High** | Likely to cause an incident, a security issue, or a support crisis soon. | Framework past EOL; a direct dependency CVE with a reachable path; zero tests on auth; tokens in `localStorage` with no CSP. |
| **Medium** | A real, ongoing cost that isn't urgent. | No bundle budgets; lint not run in CI; major-version drift between repos. |
| **Low** | Hygiene. | Formatter not enforced; stale README commands. |

Rank findings by **severity, then breadth** (how many repos or how much of the code), **then confidence**. A `[Guessing]` finding never ranks above a `[Certain]` one of the same severity.

## Finding format

Record every finding with these fields. Domains return them in this shape so `/audit:all` can merge them.

| Field | Content |
|---|---|
| `ID` | `<DOMAIN>-<n>`, e.g. `FE-3` |
| `Severity` | Critical / High / Medium / Low |
| `Confidence` | Certain / Likely / Guessing |
| `Dimension` | e.g. Security, Dependencies, Accessibility |
| `Scope` | the repos or packages affected |
| `Finding` | one line |
| `Evidence` | `path:line` or command + output excerpt |
| `Why it matters` | one line, concrete impact |
| `Fix` | one line |
| `Effort` | S (< 1 h), M (< 1 day), L (more) |

## Gates

A domain run asks the user questions at exactly two points and proceeds on its own everywhere else.

- **Gate 1, after discovery:** confirm the inventory.
- **Gate 2, after the stack baseline:** priorities, permission to run commands, depth, and steering.

Ask with the AskUserQuestion tool: at most 4 questions per call, each with 2–4 options, your recommended option first and marked "(Recommended)". If the user skips or dismisses a question, use the domain's stated default and list every default you assumed in the next message.

## Delegated mode

`/audit:all` runs the gates once for every domain and then hands each domain to an `audit:auditor` agent. When a domain skill runs in delegated mode:

- The calling prompt gives you the confirmed inventory and the Gate 2 answers. Ask nothing and skip both gates.
- Run every phase after Gate 2.
- Return only the delegated report below, not the chat report.

**Delegated report**, exactly these sections:

1. `Inventory updates`: corrections to the inventory you were given.
2. `Baseline`: the "what good looks like" paragraph per stack, with sources.
3. `Findings`: every finding, in the finding format, ranked.
4. `Clean`: one line per dimension that came back clean, naming what you checked.
5. `Drift`: cross-repo differences as `dimension | repo: value | … | recommended baseline`.
6. `Could not verify`: each skipped check, why, and what it would take.
7. `Open questions`: things only the team can answer.

## Overlap between domains

When `/audit:all` tells you another domain is also running and one of your checks belongs to it (e.g. test quality when `tests` is running, or images and fonts when `assets` is running), do only a light pass on that check and record a one-line pointer: `See <domain> audit.` Keep anything specific to your domain.
