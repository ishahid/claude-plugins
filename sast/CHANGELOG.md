# Changelog

## 0.1.0

- Initial release, adapted from a third-party plugin published under the MIT License (see `THIRD-PARTY-NOTICES.md`).
- `run`: a read-only, multi-agent SAST review in four stages (scope, discovery, review, report) that returns a findings report with CVSS 4.0 scores in chat. The review method, guardrails, sub-agent prompts and CWE playbook are unchanged from the source; only skill frontmatter was edited.
- Manual invocation only (`disable-model-invocation: true`), matching the other plugins in this marketplace.
- `finding-authoring` is internal (`user-invocable: false`): loaded by the review and its sub-agents, not listed as a command.
- Dropped from the source: Codex support, the source's vulnerability disclosure policy, its own marketplace, and its tooling files.
- Removed the source's branding: organisation and product names in manifests, skill names and documentation. The README is new.
