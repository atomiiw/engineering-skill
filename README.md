# engineering-skill

An **agent skill that enforces engineering discipline** — a repeatable loop with hard STOP gates that any AI coding agent runs *before* it edits code. Install it once and it triggers in **any repo you work in**, across **Claude Code, OpenAI Codex, and TRAE CLI**.

It doesn't teach an agent your codebase. It teaches it *how to work*: verify before asserting, find the root cause instead of patching the symptom, fix at the right layer, actually run the change, and be honest about what's left.

## Why

Most damage an agent does to a codebase comes not from hard problems but from **acting before understanding** — guessing a field name, patching where an error surfaced instead of where it was produced, or claiming "done" without running anything. This skill front-loads a checklist that catches those before an edit lands. It's written so that an agent with imperfect judgment, following it literally, ships a correct fix and *stops* before shipping a wrong one.

## What's inside

```
engineering-skill/
├── install.sh                              # symlink the skill into each engine's global skills dir
├── skills/engineering/
│   ├── SKILL.md                            # the enforced loop (self-sufficient)
│   └── references/
│       ├── engineering-playbook.md         # the gates, root-cause procedure, quality bar, self-audit
│       └── skill-style.md                  # how to write/edit skills consistently
├── README.md
└── LICENSE
```

The `references/` ship *with* the skill, so the full playbook is readable wherever it's installed — not just in this repo.

## Publish this repository

This directory is already a git repository on `main`. To publish it:

1. Create an empty remote repository named `engineering-skill` on GitHub, GitLab, or another git host. Do not initialize the remote with a README, license, or `.gitignore`; this repo already has those files.
2. Add the remote and push:

   ```bash
   git remote add origin git@github.com:atomiiw/engineering-skill.git
   git push -u origin main
   ```

   Prefer HTTPS?

   ```bash
   git remote add origin https://github.com/atomiiw/engineering-skill.git
   git push -u origin main
   ```

3. After the first push, the install command below will clone from the published repository.

If you use GitHub CLI, the same publish step can be done in one command:

```bash
gh repo create engineering-skill --public --source=. --remote=origin --push
```

## Install

```bash
git clone https://github.com/atomiiw/engineering-skill.git
cd engineering-skill
bash install.sh
```

`install.sh` drops a symlink into each engine's global skills directory:

| Engine        | Location                        |
|---------------|---------------------------------|
| Claude Code   | `~/.claude/skills/engineering`  |
| OpenAI Codex  | `~/.codex/skills/engineering`   |
| TRAE CLI      | `~/.agents/skills/engineering`  |

Because it's a **symlink** (not a copy), pulling updates in this repo updates the skill everywhere — no reinstall. The script is **idempotent and non-destructive**: re-running is safe, and if an `engineering` skill from somewhere else is already installed, it's left alone with a note instead of being clobbered.

Then **open a new session** in your engine — skills are discovered at startup.

Targeting a different skills dir? `SKILL_DIRS="/path/one /path/two" bash install.sh`.

## How to use

Once installed, the skill **auto-triggers** whenever you ask an agent to do engineering work — fix a bug, write or change a skill, edit code, add a tool, wire a data source, plan, refactor, or optimize. You can also invoke it explicitly (e.g. `/engineering` in Claude Code).

From then on, for each task the agent runs the loop:

1. **Reframe** the ask into the *class* of problem it points at.
2. **Entrance gate (STOP)** — six questions it must answer before editing.
3. **Investigate** independent unknowns in parallel.
4. **Localize** the root cause and confirm it with a real observation.
5. **Pick the right layer**, matched to the blast radius.
6. **Implement** minimally, idempotently, self-healingly.
7. **Verification gate (STOP)** — actually run it, prove it hits the *reported* symptom.
8. **Report residue** honestly.

## Make it yours

The playbook is general, but §9 of [`engineering-playbook.md`](skills/engineering/references/engineering-playbook.md) — "Your project's landmines" — is meant to be **filled in per project**: the non-obvious gotchas (identity/environment quirks, restart-to-apply traps, where your real API contract lives, self-rewriting config, secret handling). It ships with a worked example; replace it with your own so newcomers avoid the traps you already paid for.

## Uninstall

```bash
rm ~/.claude/skills/engineering ~/.codex/skills/engineering ~/.agents/skills/engineering
```

(Only removes the symlinks; this repo is untouched.)

## License

ISC — see [LICENSE](LICENSE).
