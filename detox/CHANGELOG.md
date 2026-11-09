# Changelog

## 0.1.0

- Initial release, adapted from a standalone `/detox` skill.
- `run`: audits a Claude setup in five parts (interface, memory, skills, connectors, scheduled tasks), publishes one checklist page, and applies only ticked rows after a confirmation in chat.
- Paths resolve through `${CLAUDE_PLUGIN_ROOT}`; scripts, references and the page template live at the plugin root.
- `/skill-doctor` is optional. Without it, skill use counts come from session transcripts and context cost is estimated from description length.
- Removed the original author's branding: logo, colour palette, web font, personal style rules, and the connector check that recommended specific third-party products (now a generic "switch to an official CLI" flag, and the `build_cli` action kind is gone).
- Manual invocation only (`disable-model-invocation: true`), matching the other plugins in this marketplace.
