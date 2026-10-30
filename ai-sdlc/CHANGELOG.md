# Changelog

## 0.3.0

- New `build` stage: implements `04-plan.md` one task at a time (failing test first, then code, then the task's done-when check) and keeps the plan in sync with what was built.
- New `verify` stage: an independent `verifier` agent runs the tests, checks, and the app, and the result is recorded in the plan.
- `review` now delegates to a read-only `reviewer` agent in a fresh context, so the agent that wrote the documents no longer approves them.
- New `agents/` with `reviewer` and `verifier`, both read-only.
- New opt-in `guardrails` option and `hooks/`: ask before a document is marked Approved, ask before a build task edits an unlisted file, deny test edits while a bug fix has its tests locked.
- New `scripts/trace.sh`, a mechanical goal → requirement → design → plan traceability check that `review` runs first.
- New `evals/run.sh` with fixture features: checks manifest versions, skill and agent frontmatter, `trace.sh`, and the hooks.
- Pipeline is now `intent → specs → design → plan → review → build → verify`.
- Removed the unused `icon` field and `icon.png`: Claude Code does not read it.

## 0.2.1

- Set the plugin `displayName` to "ai-sdlc".

## 0.2.0

- `review` no longer writes `05-review.md`. It presents findings in the conversation, applies approved fixes to the existing documents, and logs deferred or rejected findings in a dated `Review` entry in the plan's `Decisions` section.

## 0.1.1

- Show the plugin as "AI SDLC" (added `displayName`).

## 0.1.0

- Initial release with five stages: `intent`, `specs`, `design`, `plan`, `review`.
- `template_mode` option: `guide` (default) or `strict`.
