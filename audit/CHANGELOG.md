# Changelog

## 0.1.0

- Initial release.
- `frontend`: a read-only front-end audit for any stack. It discovers every unit that ships browser code, researches current best practice for the exact versions found, asks two batched gates, and reports severity-ranked, evidence-backed findings on security, dependencies and supply chain, accessibility, tests, performance, architecture, and tooling, plus cross-repo drift.
- `all`: runs every available domain as one audit. It discovers once, asks the gates once, has one `auditor` agent audit each domain in parallel, then deduplicates, re-ranks, and adds cross-domain findings.
- New `references/contract.md`: the shared ground rules, evidence and confidence tags, severity scale, finding format, gates, and delegated mode that every domain follows.
- New `auditor` agent: read-only, runs one domain in delegated mode.
- Commands that install, build, or test run only with permission, in a disposable `git archive` export, with lifecycle scripts off.
