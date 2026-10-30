# claude-plugins

A [Claude Code](https://docs.claude.com/en/docs/claude-code) plugin marketplace.

## Plugins

| Plugin | Commands | Description |
|---|---|---|
| [ai-sdlc](ai-sdlc/) | `/ai-sdlc:intent`, `/ai-sdlc:specs`, `/ai-sdlc:design`, `/ai-sdlc:plan`, `/ai-sdlc:review`, `/ai-sdlc:build`, `/ai-sdlc:verify` | A staged, artifact-driven AI software development lifecycle. |

## Installation

Add the marketplace once, then install any plugin from it as `<plugin>@ishahid`. In Claude Code:

```
/plugin marketplace add ishahid/claude-plugins
/plugin install ai-sdlc@ishahid
```

Or from your shell:

```bash
claude plugin marketplace add ishahid/claude-plugins
claude plugin install ai-sdlc@ishahid
```

### For a whole team

Add this to a project's `.claude/settings.json` so everyone who opens it is offered the marketplace and its plugins:

```json
{
  "extraKnownMarketplaces": {
    "ishahid": {
      "source": { "source": "github", "repo": "ishahid/claude-plugins" }
    }
  },
  "enabledPlugins": {
    "ai-sdlc@ishahid": true
  }
}
```

### Updating and uninstalling

```
/plugin marketplace update ishahid
/plugin uninstall ai-sdlc@ishahid
```

## Repository layout

```
claude-plugins/
├── .claude-plugin/
│   └── marketplace.json     # Marketplace "ishahid": lists every plugin below
├── ai-sdlc/                 # One folder per plugin
│   ├── .claude-plugin/plugin.json
│   ├── skills/
│   ├── agents/
│   ├── hooks/
│   ├── scripts/
│   ├── evals/
│   ├── CHANGELOG.md
│   └── README.md
├── LICENSE
└── README.md
```

## Adding a plugin

1. Create `<plugin-name>/.claude-plugin/plugin.json` with at least a `name`.
2. Add components (`skills/`, `agents/`, `hooks/`, …) inside that folder.
3. Add an entry to `plugins` in `.claude-plugin/marketplace.json` with `"source": "./<plugin-name>"`.
4. Validate:

   ```bash
   claude plugin validate .
   claude plugin validate ./<plugin-name>
   ```

5. Add a row to the table above.

## Development

Load one plugin from your working copy without installing it:

```bash
claude --plugin-dir ./ai-sdlc
```

To release a new version of a plugin, bump `version` in both `<plugin>/.claude-plugin/plugin.json` and its entry in `.claude-plugin/marketplace.json`, and add an entry to the plugin's `CHANGELOG.md`.

## License

[MIT](LICENSE)
