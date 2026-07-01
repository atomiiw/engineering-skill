# Skill-writing style

Read this before writing a new skill or changing an existing one. Goal: what you write is **consistent** with the skills already in the project. This doc obeys its own rules — short, scannable, tabular, points instead of repeating.

## 0. The single most important rule

**Don't pile new logic into the biggest existing SKILL.md.** The oldest/largest file is the one everyone treats as scratch paper; models naturally append every new rule to it. Before writing, ask: which skill does this belong to? Is it main flow or a detail (details go in that skill's `references/`)? Is it already stated somewhere (if so, edit *that* spot, don't copy)?

## 1. The skeleton every skill follows (fixed section order)

1. **YAML frontmatter**: `name` + `description`. The description must be complete: exhaustive trigger words → one-line responsibility/scope → `⚠️` boundary (what it does *not* do, and how it differs from a sibling skill) → names of companion tools. This is the *only* basis for routing — write it in full.
2. **H1 title + one-line thesis.**
3. **When it triggers / activation & routing**: entry conditions + the boundary with sibling skills ("intent X goes to skill Y, not here").
4. **Main flow**: broken into stages (a pipeline) or layers (a decision), each step marked **deterministic script** vs **you decide**.
5. **Tool table**: `# | component | type | how to use | trigger`.
6. **Efficiency iron rules**: one pass; don't run every tool; keep references short (read only the relevant entry on demand — no `wc`/`ls`/size-check first).
7. **Output format**: a code block giving the **exact skeleton** + a few **hard-rule** bullets.
8. **Auth** (if any): reuse the shared auth path; on a missing scope, point the user at how to grant it.
9. **Response style**: concise; report progress **one line per batch of tools** (not per tool); output auth/token guidance verbatim; if data can't be fetched, leave it blank / say "none" — never fabricate.

Details, edge-case rulings, examples → the skill's `references/*.md`. SKILL.md keeps only the main flow.

## 2. Language & layout

- Concise, imperative.
- **Bold only load-bearing words** — don't bold whole paragraphs, don't overuse brackets/`⚠️`. Load-bearing examples: closed sets, verdict words, high-risk (delete-class) actions.
- Enumerations, mappings, truth tables → **always a table**, not a long bullet list.
- Natural words over jargon (`problem → conclusion`, not "contradiction").
- Human-facing output uses **parallel structure** (two isomorphic lines), not a different shape per line.

## 3. Hard prohibitions

- **One home per rule.** Don't state the same rule three times in SKILL.md, and don't copy the full text into both SKILL.md and a reference — SKILL.md keeps the terse version, the reference keeps detail + examples, a pointer connects them.
- **Don't pile real war-stories in the body.** War-stories go in a `worked-examples.md`; the body keeps only the principle.
- **Don't re-teach what a reference already owns** — point to it ("see diagnosis-rules C7"), don't restate the definition.
- **Don't invent labels outside a closed set.** Names/verdict words are closed sets; a missing/unbound object still uses the in-set name, with the "why missing / who owns it" written into an error or suggestion field — don't mint a new category.
- **No special cases for user-defined objects.** Anything user-configured (a skill/tool/template not in the built-in set) is resolved and handled through the *same* tooling and flow — no separate branch.
- **No patch-smell.** If it reads like "one more caveat bolted on," that's the signal — go back, dedup, merge, delete examples, reduce bold.

## 4. Tool conventions (scripts & MCP)

- **Minimal, single-purpose, mutually exclusive.** One script does one thing (`fetch` / `plan` / `write` stay distinct, no bleed-through).
- **Deterministic work → scripts; judgment → the model.** Scripts don't do attribution/classification/summarization; those are done inline by the model.
- **Heavy operations get an efficiency rule**: state when to call them *only* (e.g. "this returns the whole transcript — call it only when you actually need to convert a session, not to 'check it's valid'").
- MCP tool descriptions state: what it does, when to use it, and the boundary with neighboring tools. Cross-skill shared pieces (auth, a shared server) reuse one implementation — don't write a copy per skill.
- **Resolve by name globally, auto-detect across regions/tenants** (run them in parallel, use whichever resolves); don't hardcode a region or identity; always use the *user's own* token (personal login over a service account).

## 5. Human-facing output copy

- One-line summary uses a two-part, explicitly separated form: `problem: … → conclusion: …`, on one line.
- Multi-line info uses parallel prefixes (isomorphic lines), dates in parentheses only.
- Fields meant for the AI vs fields meant for a human are kept separate — don't mix.

## 6. Scenario → where it goes

| What you're adding | Where |
|---|---|
| A standalone new workflow | a new `skills/<name>/`, following the §1 skeleton |
| A skill's edge-case ruling / example / war-story | that skill's `references/*.md`, not SKILL.md |
| An enumerable rule / mapping / truth table | a table |
| Cross-skill shared logic (auth, MCP, region detection) | one shared implementation + one auth section, everything else points to it |
| Deterministic multi-step data processing | one script; the model only judges, doesn't haul |
| An output format | an exact skeleton code block + terse hard rules |
| Install/environment fix (e.g. a tool that crashes on bad config) | the installer, seeded idempotently — don't make the user configure by hand |
