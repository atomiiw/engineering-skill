# Engineering Playbook — how to work on a codebase without breaking it

For whoever comes after me. Read this before you touch code. It's written defensively, because most damage comes not from hard problems but from **acting before understanding**. If you follow nothing else, follow the STOP gates in §3 and §6.

Companion: [`skill-style.md`](skill-style.md) covers *how to write/edit skills*. This covers *how to think, diagnose, fix, and verify* anywhere in a codebase.

> The `code`/parenthetical examples below are drawn from the project this playbook was extracted from. They illustrate the *pattern* — substitute your own project's specifics (especially in §9).

---

## 1. The five ways this gets broken (name the enemy)

Every mess traces to one of these. Assume you're about to commit one:

1. **Guessing instead of checking** — inventing a field name, an API shape, an error's meaning, a file's contents.
2. **Fixing the symptom, not the cause** — patching where the error *surfaced*, not where it was *produced*.
3. **Patching in the wrong place / bloating** — stacking a fix onto the biggest nearest file instead of its real home; duplicating a rule.
4. **Claiming victory without proof** — "fixed it" without running it, or without checking the fix explains the *reported* symptom.
5. **Losing the user's actual intent** — solving the literal words when the real ask was underneath (they said "A→A not A→B" — the real ask was "why no delivery at all").

---

## 2. Prime directives (memorize)

- **Verify, don't assert.** No claim about code/data/errors leaves you until you've read the primary source or reproduced it.
- **Root cause, not surface.** An error message is a *symptom with a location*, not an explanation. Ask "what produced this, one layer down" until the answer is a system fact you can point at.
- **Fix at the right layer, once.** The best fix makes the whole class of the bug impossible, for everyone, idempotently — not a local band-aid.
- **Prove it hits the symptom.** A real bug you found ≠ the cause of the thing you were asked to fix. Test against the *reported* case.
- **Be honest about residue.** State what you did *not* fix, what you couldn't verify, and what still needs a human. Never round "opens now" up to "solved."
- **Use the user's identity and their proven path.** If they can do it in the UI, the difference is environment/identity/flow — replicate that, don't reinvent.

---

## 3. STOP-gate: before you change any code

Do not edit until you can answer all of these.

| Gate | How to satisfy it |
|---|---|
| **What is the primary source of truth?** | API shapes → the server's type definitions / handlers / schema (or its OpenAPI spec), not memory. Field values → a **live call**. File contents → `Read` it, don't assume. |
| **Who/what/where produced the symptom?** | Trace the call, decode the token, read the actual returned data. Locate the *producing* line, not the *surfacing* one. |
| **Can I reproduce it?** | Run the smallest repro (a throwaway snippet hitting the real function, or the script with real args). **Read-only only** — never reproduce or "test" via a destructive/outward-facing action (delete / write / send) against real data; use `--dry-run` or a scratch target. If you can't reproduce safely, you can't claim a fix. |
| **Whose identity / which environment is this running as?** | Decode the auth token / inspect the active identity and environment (user, region, tenant). "Works in the UI, not in my code" is almost always identity or environment, not capability. |
| **Is the change already stated/owned somewhere else?** | Grep for it. If a rule/def exists, edit *that* home; don't add a second copy. |
| **Am I about to edit the biggest nearest file by reflex?** | If yes, stop — find the correct home (a `references/*.md`, a script, the install step). See §7. |

If you cannot satisfy a gate, your next action is *investigation*, not *editing*.

---

## 4. Root-cause procedure (the verified 5-whys)

Generic "5 whys" fails because dumb operators accept unverified whys. Each "why" here must be **backed by a primary-source observation**, not a plausible story.

**First localize, then explain.** For a wrong *value*: trace it backward through the pipeline stages to the first stage where it's *already* wrong, and fix there — don't edit the last, most-visible stage by reflex (the wrong number may come from source data, a tool response, or arithmetic, not the prompt you're staring at). For a wrong *behavior*: find the instruction/config that produced it.

Symptom-class playbook (examples illustrate the *pattern*, not your rules):

- **`permission denied` / auth error** → *don't* accept "no access." Decode the token actually being sent. Compare identity to the one that works (the UI = the user's personal login). A common real cause: a **service-account token shadowing the personal login**; the fix was token *precedence*, not permissions.
- **"works in the UI but not my code"** → identity or environment mismatch, or the code queries a different endpoint/scope than the UI. Replicate the UI's exact call (find it in the frontend source), don't guess a new one.
- **crash / "won't start" (e.g. `invalid transport`)** → something wrote a malformed config. Find *what writes it* and *when* (real case: a tool's per-action "always allow" wrote an orphaned config block). Verify the asymmetry (create-from-scratch crashes, append doesn't) before designing the fix.
- **timeout** → find the unbounded/sequential loop (real case: a sync stage probed candidates serially). But then **check the fix actually explains the timeout** — in that case the reported task had *0 candidates*, so the true cause was a **stale running server**, not the loop. Say that.
- **wrong output / wrong verdict** → find the *instruction that produced it*. Real case: a doc rule conflicted with a naming closed-set and *caused* invented labels. Fix the conflicting source, not each output.

Rule: **when two explanations fit, the one you can falsify with a tool call wins.** Go run the call.

---

## 5. What qualifies as an ultimate-good fix (the quality bar)

Rank your fix against this. Aim for the top.

1. **Right layer.** Does it make the bug impossible for *all* users, or just this machine? (A per-machine crash → fixed at *install time* in the installer, seeding the config for everyone — not a local `rm`.)
2. **Root, not symptom.** Does it remove the *producer* of the bug? (Token precedence, not per-call token passing; the conflicting doc rule, not each bad output.)
3. **Idempotent & self-healing.** Re-running does no harm; a machine already in the broken state gets repaired. Self-healing must **back up before it repairs** and touch **only the exact known-bad shape** — never silently rewrite user data or anything you don't positively recognize. (A config seeder: fresh → write; broken → back up + repair + preserve; already-good → leave.)
4. **Minimal & mutually exclusive.** Smallest change that does the job; no overlap with existing mechanisms; deterministic work in scripts, judgment left to the model.
5. **Edge-tested.** You ran the fresh case, the already-broken case, and the idempotent re-run — and showed the outputs.
6. **Honest residue.** You named what it does *not* solve.

**Match reach to the bug's reach.** The bar above is the target for anything others will hit or that's hard to reverse — reach for it there. A genuine one-off throwaway needn't be generalized to the install layer; but then *say* that's what it is, don't dress a band-aid as a root fix. The failure to avoid is the reverse: shipping a local patch for a bug that everyone will hit.

A fix that's clever but local (for a shared bug), or that works but you didn't run, does **not** clear the bar.

---

## 6. STOP-gate: before you say "done"

- Did you **run** it (script, live call, or the exact repro)? Paste the evidence.
- Does the result address the **reported** symptom, not just a bug you happened to find? If not, say which is which.
- Did you check the **edges** (empty input, already-applied, wrong environment, missing token)?
- Is there a **stale process** masking your result? (Long-running servers/daemons — including MCP servers — run the code loaded at start until restarted/reconnected. Always flag "restart to apply.")
- What did you **not** fix or **not** verify? State it plainly.

Never let "it should work" stand in for "I ran it and it did."

---

## 7. Consistency & anti-bloat

- **One home per rule.** Before adding a rule, grep for it; if it exists, edit that spot. Detail + examples live in `references/*.md`; main flow stays in `SKILL.md`; canonical rule stated once, everything else points to it.
- **Don't feed the biggest file.** New logic gravitates to the largest nearest file. Resist; place by *ownership*, not proximity.
- **Closed sets stay closed.** Verdict words, naming forms are fixed. Missing/unbound objects still use the in-set name; the "why/who-owns" goes in a description field, never a new invented label.
- **No special-casing** when a general path works (user-defined objects go through the *same* resolve/handle path as official ones).
- **Patch-smell test:** if a passage reads like "and one more caveat bolted on," collapse it — dedup, merge, drop inline war-stories, remove decorative bold. See `skill-style.md`.

---

## 8. Communication standard

- Report faithfully: if a step was skipped or a test failed, say so with the output. Done-and-verified is stated plainly; uncertain is flagged as uncertain.
- Surface the residue and the next required human action (reconnect, re-login, a scope you lack).
- Confirm before hard-to-reverse or outward-facing actions; don't assume prior approval carries to a new context.
- When the user corrects you, treat it as **high-signal about reality**, not just an instruction — extract the general principle behind the correction and apply it beyond the one spot.
- A correction points you to the right *area*; still verify the *mechanism* from the primary source. The user's stated cause can be directionally right but incomplete — honor the redirect, then confirm the real mechanism yourself.

---

## 9. Your project's landmines (keep your own list here)

Every codebase has a handful of gotchas that aren't obvious from the code and that bite newcomers repeatedly — environment/identity quirks, a restart-to-apply trap, where the real API contract lives, config that gets rewritten out from under you, secret handling. **Maintain your own list here.** A newcomer (human or agent) should be able to read this section and avoid the traps you already paid for.

Prompts to build yours:
- **Identity / environment.** How does the app decide *who* it runs as and *where* (region/tenant/account)? What's the difference between "works in the UI" and "works in my code"?
- **Restart-to-apply.** What long-running processes cache code/config at start (servers, daemons, MCP servers, watchers) and must be restarted/reconnected before your change takes effect?
- **Primary sources for the contract.** Which file/spec is the authority for API request/response shapes and route verbs? Where does the frontend show the *exact* call the UI makes?
- **Config that rewrites itself.** Any file a tool regenerates (so a committed copy is unreliable)? Seed/repair it at install time, idempotently.
- **Scripts vs model.** Which work is deterministic (belongs in scripts) vs judgment (belongs to the model)? Keep the split.
- **Secrets.** Where do tokens/caches live, and with what permissions? What must *never* be committed?

<details>
<summary>Worked example — the landmine list from the project this was extracted from</summary>

- **Dual-region + identity.** Every backend call is region A **or** region B; resolve by trying both in parallel and using whichever returns the object. Auth must use the **user's personal login**, not a service account — token precedence is deliberate; don't "simplify" it.
- **MCP restart.** The running MCP server executes the code loaded at connect time. Edits to library code do nothing until the client reconnects. Test via a fresh snippet, and tell the user to reconnect.
- **Primary sources for API shape.** The backend's Go structs/handlers define the real request/response contracts and route verbs (GET vs POST). Read them before constructing a call. The frontend shows the *exact* filter/scope the UI uses — replicate it. If those repos aren't checked out, reconstruct from a **live sample response** and label it *inferred*.
- **Scope keys.** Project resources are keyed `space:project:type`; list scoped resources with a `key` filter, in the object's home region. `get`-by-name is global.
- **Scripts vs model.** Scripts do deterministic work (fetch/merge/diff/write); classification, summarization, attribution are the model's job.
- **Tool-managed config is gitignored** and rewritten by the tool; never rely on a committed file there — seed/repair it at install.
- **Install path** seeds skills + config for every user; environment/onboarding fixes belong there so everyone gets them, idempotently.
- **Secrets: none, ever.** Per-user login only; tokens/caches live under a `0700`/`0600` home dir.

</details>

---

## 10. Keep this document honest (the self-audit loop)

This file is only as good as its last stress-test. To improve it:

1. **Replay a real incident** against these gates. Would following them have prevented it? If a gate was silent, add it.
2. **Invent an adversarial scenario** — one where a gate could *mislead* (e.g., "fix at the highest layer" tempting you to over-engineer a one-off). Add the counter-balance.
3. **Watch for new failure modes** the five in §1 don't cover; name and add them.
4. Prefer deleting a stale line to adding a redundant one. This doc obeys its own §7.

The measure of success is not that this reads well. It's that someone with less judgment, following it literally, ships a correct fix and stops before shipping a wrong one.
