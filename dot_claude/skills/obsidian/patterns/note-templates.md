# Note body templates

Per-`type` skeletons used in step 4 of the skill. All notes carry the standard frontmatter
first; these are the **body** that follows it. Adapt headings to the content — don't pad a
short note with empty sections.

## Standard frontmatter (every note)

```yaml
---
tags: [area/subarea]        # hierarchical, e.g. tech/docker, work/efsta
type: note                  # note | reference | runbook | decision | doc | recipe
created: 2026-06-05         # date +%F
updated: 2026-06-05         # bump on every edit
source: conversation        # repo path, Linear ticket, URL, or "conversation"
---
```

---

## type: note
Quick, free-form capture. Minimal structure.

```markdown
# {Title}

{The thought / observation / snippet.}

## Related
- [[Some Other Note]]
```

## type: reference
Durable knowledge you'll look up again (commands, configs, facts, gotchas).

```markdown
# {Title}

> {One-line summary of what this is and when you'd reach for it.}

## Details
{The content — commands, config blocks, explanation.}

## Gotchas
- {The thing that bit you.}

## Related
- [[...]]
```

## type: runbook
A repeatable procedure you'll follow step by step.

```markdown
# {Title}

**When to use:** {trigger}
**Prerequisites:** {access, tools, state}

## Steps
1. {step}
2. {step}

## Verify
- {how to confirm it worked}

## Rollback / if it fails
- {recovery}
```

## type: decision
An architecture/tooling/life decision, preserved with its reasoning.

```markdown
# {Title}

**Date:** {created}   **Status:** decided | revisit
**Context:** {the situation / problem forcing a choice}

## Options considered
| Option | Pros | Cons |
|---|---|---|
| A | | |
| B | | |

## Decision
{What was chosen and the one-line why.}

## Consequences
- {trade-offs accepted, follow-ups}
```

## type: doc
A project/feature write-up or spec generated while working in a repo.

```markdown
# {Title}

> {What this documents and for whom.}

## Overview
{...}

## Details
{architecture, flows, components}

## References
- {repo path, PR, ticket}
- [[Related Doc]]
```

## type: recipe
Cooking recipe (matches the `recetas/` folder style).

```markdown
# {Title}

**Raciones:** {n}   **Tiempo:** {min}

## Ingredientes
- {...}

## Pasos
1. {...}

## Notas
- {tweaks, substitutions}
```
