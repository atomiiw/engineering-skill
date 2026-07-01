---
name: engineering
description: "Enter this skill before ANY engineering action in any repo/project — fixing a bug, writing or changing a skill, editing code, adding/changing an MCP tool, wiring a data source, planning, refactoring, optimizing, or running long/parallel tasks. It is an ENFORCED engineering loop + STOP gates + per-scenario procedure. Each time you touch something, work against `references/engineering-playbook.md` (the reasoning and gates live there; it ships with this skill). Triggers: fix a bug, edit code, write/change a skill, add a tool, write MCP, wire a data source, plan, refactor, optimize, debug, fix, implement, refactor, plan, write a tool, wire a data source. ⚠️ This is engineering discipline for changing a repo/project itself — not an end-user task skill."
---

# Engineering discipline (the enforced loop)

This is not advice, it is an operating procedure. **Run the loop below for every task. Do not skip the gates.** This file is self-sufficient — you can follow it with no other file. Deeper reasoning, the full gates, and the self-audit loop live in `references/engineering-playbook.md` (referenced below as §N); skill-writing style lives in `references/skill-style.md`. Both ship with this skill — readable wherever it's installed — and you should read them while running the loop, not just this summary.

## Run this loop for every task

0. **Reframe the problem before you act.** The user's sentence *reveals where a problem is*; it is not a literal patch order. Locate the *class* of problem it points at — fix the whole thing right, don't just paper over the one crack. (See "Understand what the user is saying".)
1. **Entrance gate (STOP).** If you can't answer the six questions in §3, you may not edit — ① what is the primary source of truth? ② who/what produced the symptom (the *producer*, not where it surfaced)? ③ can I reproduce it read-only? ④ whose identity / which environment does it run as? ⑤ does this rule/definition already have a home? ⑥ am I about to edit the biggest nearest file by reflex? Can't answer them all → your next step is investigation, not editing.
2. **Investigate in parallel.** Independent unknowns get probed in one message, in parallel (multiple tool calls; spin up read-only sub-agents for broad reads). Go serial only where there's a real dependency.
3. **Localize the root cause.** First localize to the layer that *produces* the wrong value/behavior (for a wrong value, trace back up the pipeline to the first stage where it's already wrong), then *confirm* with one tool call — never on a "plausible story" (§4).
4. **Pick the right layer + match the blast radius.** A fix that makes the whole *class* of bug disappear for everyone beats a local band-aid — but don't drag a genuine one-off up to the install layer. Decide by "who hits it / how hard to reverse" (§5).
5. **Implement.** Minimal, idempotent, self-healing (back up before repairing, touch only the *known-bad* shape, never silently rewrite user data). Deterministic work goes in scripts; judgment stays with the model.
6. **Verification gate (STOP).** *Actually run it* and paste the evidence. The result must hit the symptom the user *reported* (not some other bug you found along the way — if it's a different one, say so separately). Test the edges (empty / already-applied / wrong environment / missing token). Check for a *stale process* masking the result (a long-running server/MCP runs the code loaded at start — remind the user to restart/reconnect).
7. **Be honest about residue.** State what you did *not* fix, what you couldn't verify, and the next human step (reconnect, re-login, a missing scope). Never round "it opens now" up to "solved."

**Loop, don't one-shot:** re-check the gates after each step; when stuck, investigate instead of guessing; before you claim a fix, *try to falsify it yourself.*

## Agent / loop level

- **Parallelism:** independent work runs concurrently in one message (multiple tool calls, multiple read-only sub-agents); use a barrier only when you truly need to aggregate.
- **Long tasks:** track progress with todos, checkpoint in segments, don't lose the original intent across steps.
- **Falsify each round:** try to break your own solution first; ship only when you can't.

## Per-scenario procedure

- **Fix a bug** → run the main loop; root-cause classes in §4, quality bar in §5. Iron rule: fix the *producer*, not where it *surfaced*; prove it hits the *reported* symptom.
- **Write / change a skill** → follow the `references/skill-style.md` skeleton first; §7 for anti-bloat. Iron rule: one home per rule, detail goes in `references/`, don't feed the biggest file, don't invent members outside a closed set.
- **Planning** → describe the problem *class* first (not this one instance); put the right-layer options + trade-offs + residue on the table *before* coding; **confirm before expanding scope** — no silent scope-creep.
- **Parallel / long tasks** → read-only probes fully parallel; serial only for real dependencies; todos for progress, segmented checkpoints; verify each unit as it lands, not all at the end.
- **Understand what the user is saying (most important)** → the user's words are a *probe* revealing roughly where the problem is, not a spec to satisfy literally. Diagnose the underlying class and lift the whole thing; don't patch everywhere. **But match the blast radius:** confirm big changes first — don't use "holistic" as an excuse for unbounded expansion.
- **Write an MCP tool / wire a data source** → the contract's authority is the *primary source* (the server's struct/handler/schema, or its OpenAPI spec, defines the verbs and field names; if you can't check it out, reconstruct from a live sample and *label it inferred* — never silently guess a field). Replicate the UI's proven call/flow, don't invent a new one. Run across regions/tenants in parallel and use the *user's own identity* (personal login over a service account). Tools stay minimal, single-purpose, mutually exclusive; deterministic work in scripts; handle auth/scope failures gracefully with guidance. Landmines in §9.

## Never cross (STOP, any scenario)

- Entrance gate not fully answered → don't edit.
- Not actually run, or doesn't hit the reported symptom → don't say "done."
- Contract guessed → verify it or label it inferred; never silently hardcode.
- Reflex-editing the biggest file → place by ownership.
- Using a **destructive / outward-facing** action to reproduce or "test" → forbidden; use `--dry-run` / a scratch target.

Full reasoning, gates, and the self-audit loop: `references/engineering-playbook.md`. Skill-writing style: `references/skill-style.md`.
