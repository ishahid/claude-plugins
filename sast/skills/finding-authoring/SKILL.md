---
name: finding-authoring
description:
  This skill should be used when the user asks to "score this finding with CVSS
  4.0", "write up this vulnerability" or "verify this scanner finding", for a
  security finding in source code from a code review, a scanner or an agent. It
  sets the rules for analysis rigour, the confidence and reachability scales,
  the CVSS 4.0 base metrics and the findings layout.
user-invocable: false
---

## Analysis rigour

- Try to disprove each candidate. State the hypothesis, trace the paths it rests
  on, consider the benign reading and look for the guard that defeats it.
  Discard it as a false positive only when the code refutes it at file and line.
  Record what can be neither confirmed nor refuted at the confidence its
  evidence supports, low included. Triage can still refute a recorded finding,
  but a discarded one is lost.
- Enumerate, do not sample. For each reported sink, find every caller and every
  producer of data that reaches it. A sink safe from one caller may be unsafe
  from another.
- Threat actors come from the threat model. A threat actor is a person or
  external system that the threat model names and that can reach the input.
  Without a threat model, state the one in use under `### Detail`. If only
  trusted parties or the system's own code set a value, a finding on it is
  `unreachable`. A party the code shows can reach the input is a threat actor
  too: name it under `### Detail`. Malicious code (CWE-506 and its children) is
  the exception: its author is the threat actor, so score reachability and PR
  from its trigger, not from who wrote it.
- Separate evidence from assumptions. A fact about how a language, framework,
  library or platform behaves is evidence when it cites a `file:line`, a cited
  source supplied with the brief or a vendor documentation section. It is an
  assumption when it cites none. A documentation section cited from memory can
  support a finding but never refutes one, since recall may be wrong. Verify an
  assumption where possible, and list under `Assumptions` every assumption the
  finding depends on. An assumption grants no reach and raises no confidence.
  Triage settles it.
- Controls reduce rather than eliminate. Authentication, validation or a
  compensating control invalidates a finding only when it provably closes every
  path to the sink. Short of that, it shows in the scores.
- A trusted identifier does not vouch for an untrusted one. Where an identifier
  a threat actor can influence is passed alongside a trusted one (a session user
  id, a validated token subject), score in full unless code or contract shows
  the downstream authorises off the trusted one, and name that trusted
  identifier.
- Design decisions are not vulnerabilities. Look for 5 signals, and cite each at
  file and line or by specification section:
  1. the README or security policy disclaims safe handling of untrusted input
     for this feature;
  2. a dedicated mitigation API exists (a resource loader, a disable flag, a
     callback);
  3. the governing specification requires the behaviour;
  4. the feature is opt-in and gated behind an explicit security warning;
  5. source comments acknowledge the limitation as a deliberate trade-off.

  Two or more signals make the behaviour a design decision, one alone an
  acknowledged weakness. Either way, record the finding with its scores
  unchanged and the signals cited under `### Detail`. Suppression is a triage
  decision.

- A clean area needs evidence. Call an area clean only after reading its source
  and checking the native extensions, bindings, FFI, unsafe blocks and
  dependencies it relies on. The language alone rules nothing out.

## Scales

Confidence is how certain it is that the finding is real.

- `high`: confirmed in the code, with a traced path and supporting evidence.
- `medium`: several indicators hold, but a critical detail is unconfirmed.
- `low`: plausible, but essential evidence is missing or the path does not
  match.

Reachability is how untrusted input reaches the sink. Record a finding at any
level. Authentication does not lower it: it sets PR.

- `reachable`: under normal operation.
- `conditional`: only if one barrier fails, such as one degraded state (memory
  exhausted, a full disk) or one bypassed defence-in-depth control. Choose it
  when the code does not settle the question. Do not choose it just because a
  barrier rests on an assumption.
- `unreachable`: no viable path, the system must already be compromised by
  another weakness, or several independent controls must fail together.

## CVSS 4.0

Give the 11 base metrics and nothing else. Threat and environmental metrics are
the consumer's. The score and severity follow from the vector, so state neither.

- An attack that needs no account is `PR:N`. Where the attack needs an account,
  PR is `N` only when open self-registration, with no approval, payment or
  invitation, gives it as part of the attack. Authentication never raises AC.
- AC is `H` only when the attack must evade an exploit mitigation or first
  obtain a target-specific secret that reconnaissance cannot reveal.
- A required non-default configuration does not set AT: score as if it were set,
  and state it in the first step to reproduce.
- There is no Scope metric. A data store or service only this application uses
  is part of the vulnerable system (VC, VI, VA), even when it looks external
  because its schema is not in the code under review.
- A deployment's own control (a WAF, a firewall rule, a proxy rate limit) stays
  out of the vector. Name it under `### Detail`.
- Score a chain at its end state.

## Findings layout

To report findings, unless the request asks for another format, answer in
markdown, in exactly this layout, one `## Finding N:` section per finding,
numbered from 1. Every line and section is required. Only `Assumptions` and
`### Related locations` may read `none`. When findings go to independent review,
reviewers see each finding without its scored lines and proof of concept, so
keep those out of the prose. Do not name the reporting agent or its brief.

```markdown
## Finding 1: SQL injection in order search exposes every customer's orders.

- Path: src/orders.py:14
- CWE: CWE-89
- Confidence: high
- Reachability: reachable
- CVSS: CVSS:4.0/AV:N/AC:L/AT:N/PR:L/UI:N/VC:H/VI:H/VA:N/SC:N/SI:N/SA:N
- Assumptions: none

### Detail

The threat actor, the input it controls and the trust boundary it crosses; then
the weakness, its flow from entry point to sink, and its impact here.

### Evidence

The code at the sink, quoted.

### Steps to reproduce

1. Every precondition (authentication, configuration, timing, the threat actor's
   earlier actions), or that there is none.
2. The next step.

### Flow

1. src/orders.py:11: the `q` parameter of GET /orders/search is read.
2. src/orders.py:14: it is concatenated into the query.

### Related locations

- src/routes.py:8: the route requires only a signed-in customer.

### Proof of concept

The request, command or snippet that triggers it, with concrete values.
```

The engineer triaging a finding decides from its title and `### Detail` whether
to open the file, so the title names the impact, not the CWE alone. Write plain
en-GB: what the code does and what a threat actor gains.

`Path` is the sink's file, relative to the root under review, and its line.
`CWE` is the most specific Base or Variant weakness the code holds: never a
Pillar or Category, and a Class only when no Base or Variant fits.
