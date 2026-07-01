#!/usr/bin/env bash
# Make the `engineering` skill globally available in Claude Code / OpenAI Codex / TRAE CLI
# (so it triggers in ANY directory / any repo you work in).
#
# How it works: each engine discovers skills from its own global skills dir. We drop a
# symlink for this repo's `engineering` skill into each one. A symlink is a live link, so
# edits to the skill take effect globally with no reinstall.
#   - Claude Code : ~/.claude/skills/engineering
#   - OpenAI Codex: ~/.codex/skills/engineering
#   - TRAE CLI    : ~/.agents/skills/engineering
#
# Idempotent and non-destructive: safe to re-run. It only touches a link that already
# points back at this repo (or a dead link); anything else it leaves alone with a note.
#
# Usage: after cloning,  bash install.sh   (run it from anywhere)

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_SRC="$REPO_ROOT/skills/engineering"

if [ ! -f "$SKILL_SRC/SKILL.md" ]; then
  echo "❌ $SKILL_SRC/SKILL.md not found — run this from inside the cloned repo." >&2
  exit 1
fi

# Global skills dir for each engine. Override with SKILL_DIRS="/a /b" to target others.
if [ -n "${SKILL_DIRS:-}" ]; then
  # shellcheck disable=SC2206
  TARGETS=($SKILL_DIRS)
else
  TARGETS=(
    "$HOME/.claude/skills"   # Claude Code
    "$HOME/.codex/skills"    # OpenAI Codex
    "$HOME/.agents/skills"   # TRAE CLI
  )
fi

echo "repo:  $REPO_ROOT"
echo "skill: engineering"
echo

for target_dir in "${TARGETS[@]}"; do
  mkdir -p "$target_dir"
  link="$target_dir/engineering"
  echo "→ $target_dir"

  if [ -L "$link" ]; then
    dest="$(readlink "$link" || true)"
    case "$dest" in
      "$SKILL_SRC")
        echo "   ✅ already linked here"
        continue ;;
      "$REPO_ROOT"/*)
        # our own stale link (e.g. an older layout of this repo) — safe to replace
        echo "   updating our stale link -> $dest"
        rm -f "$link" ;;
      *)
        # a link we don't own — never clobber it, even if it's dead
        if [ -e "$link" ]; then
          echo "   ⚠️  skipped: 'engineering' already links elsewhere:"
        else
          echo "   ⚠️  skipped: dead 'engineering' link to a foreign target:"
        fi
        echo "      $dest"
        echo "      To relink here:  rm '$link' && bash install.sh"
        continue ;;
    esac
  elif [ -e "$link" ]; then
    echo "   ⚠️  skipped: 'engineering' exists and is not a symlink. Move it aside first."
    continue
  fi

  ln -sfn "$SKILL_SRC" "$link"
  echo "   ✅ engineering -> $SKILL_SRC"
done

echo
echo "Done. Open a NEW session in each engine to pick it up."
echo "The skill auto-triggers on engineering work; you can also invoke it explicitly"
echo "(e.g. /engineering in Claude Code)."
