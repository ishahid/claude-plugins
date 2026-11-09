# detox

A Claude Code plugin that **audits and declutters your Claude setup**. It looks at five parts (interface, memory and context, skills, connectors, scheduled tasks), builds one HTML checklist page of proposed changes, and applies only the rows you tick. Nothing changes without a tick and a confirmation in chat.

To install, see the [marketplace README](../README.md#installation).

## Command

| Command | Does | Status |
|---|---|---|
| `/detox:run` | Gathers read-only data, has one agent per part write findings, publishes the checklist page, then applies ticked rows after you type "go" | Available |

## Where it works

The full workflow needs the **Code tab in the Claude desktop app on macOS**: it reads session files under `~/Library/Application Support/Claude`, and uses the Code tab's session, sidebar, connector, artifact and scheduled-task tools. In Cowork or on the web it runs only the parts that need no desktop tools (skills, memory, and what `gather_local.py` can read from disk) and tells you what it skipped.

Optional: if a `/skill-doctor` skill is installed, it is used for per-skill use counts and context cost. Without it, use counts come from session transcripts and context cost is estimated from each skill's description length.

## What it checks

| Part | Checks |
|---|---|
| interface | idle and one-off chats, sidebar sections per active folder, pins, artifacts, mods |
| memory | global `CLAUDE.md` and memory folders, each active project's root `CLAUDE.md`, routing and index files, folders with no context file, conflicts between files |
| skills | loaded skills by category, unused, duplicates, overlaps, skills that fire by accident, biggest context cost, unused plugins |
| connectors | every server with its token cost, unused, broken logins, heavy, the same service twice, candidates for a CLI instead, risky write access |
| scheduled | every task, failing, stale, no longer useful, outdated model, tasks that a smaller model could run |

## Safety

- Every proposed change is a row on the page with a checkbox and an action dropdown. "Approve all" picks the safest useful default (Archive before Delete).
- After you save ticks, the skill lists them in chat and asks once more before touching anything.
- Removed skills and mods are moved to `~/.claude/detox-backup/YYYY-MM-DD/`, never deleted.
- Deleting a chat or an artifact is permanent. The page and the chat both say so.
- It stops on the first error and reports what is left.

## Files

- `skills/run/SKILL.md`: the workflow.
- `scripts/gather_local.py`: read-only scan of sessions, skills, mods, scheduled tasks, connector use and context files. Writes JSON only.
- `scripts/build_page.py`: turns the five findings files into the checklist page and checks them for duplicate ids, pre-ticked rows and bad token values.
- `assets/page.html`: the page template.
- `references/checks.md`: what each part checks and which action kinds it may propose.
- `references/findings-schema.md`: the findings file format every part agent writes.
