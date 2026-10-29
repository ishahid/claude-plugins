# Changelog

## 0.2.0

- `review` no longer writes `05-review.md`. It presents findings in the conversation, applies approved fixes to the existing documents, and logs deferred or rejected findings in a dated `Review` entry in the plan's `Decisions` section.

## 0.1.1

- Show the plugin as "AI SDLC" (added `displayName`).

## 0.1.0

- Initial release with five stages: `intent`, `specs`, `design`, `plan`, `review`.
- `template_mode` option: `guide` (default) or `strict`.
