#!/bin/bash
# Commit any pending changes and push to GitHub.
# Double-click, or run:  bash push-to-github.command  ["commit message"]
set -u
cd "$(dirname "$0")" || exit 1

REMOTE="https://github.com/dil-gkondor/AI-chat-motions.git"

DEFAULT_MSG="Rebuild chips and add the Incident Response layout (XDS-5739)

New chat chips -> Chip / Outline / Large / Default:
- four chips, no icons (both icon slots are hidden in the component)
- labels match the quick actions: Appoint a director, Board
  resolution, Analyze data, Summarize
- white fill, 1px #888b9a (Outline/Default) border, full pill radius
- 16px effective side padding (8 root + 8 label), 36px tall, 8px gap
- label Label/Lg: Inter 14/20, weight 400, letter-spacing 0, #232429
- no elevation shadow; hover #eeeff5, pressed #dee0e9, focus ring
  Shadow/Focus/Default

Third view on the Incident Response sidebar item:
- the quick action cards move inside the chatbox, below the composer
  (112 + 24 + 140 + 24 + 16 = 316, matching the Figma node)
- one card row is relocated in the DOM rather than duplicated
- selected styling for sidebar child rows, with the indicator on the
  divider line
- New chat and Incident Response blocks are both exactly centred

Motion, glow and interaction code unchanged."

MSG="${1:-$DEFAULT_MSG}"

echo "Repository: $(pwd)"
echo

# ---------------------------------------------------------------
# 1. Clear stale lock files.
#    This repo is written from a sandbox whose mount does not allow
#    unlink(), so git cannot clean up after itself. These are
#    leftovers, not a running git process.
# ---------------------------------------------------------------
find .git \( -name '*.lock' -o -name 'tmp_obj_*' \) -delete 2>/dev/null
echo "Cleared stale git lock files."

if ! git rev-parse --git-dir >/dev/null 2>&1; then
  echo "No git repository found here. Aborting." >&2
  exit 1
fi

git remote remove origin 2>/dev/null
git remote add origin "$REMOTE"

# ---------------------------------------------------------------
# 2. Commit whatever is pending
# ---------------------------------------------------------------
git add -A
if git diff --cached --quiet; then
  echo "Nothing new to commit."
else
  echo
  echo "Committing:"
  git --no-pager diff --cached --stat
  git commit -q -m "$MSG" || { echo "Commit failed." >&2; exit 1; }
  echo "Committed."
fi

echo
echo "Commits ahead of the remote:"
git --no-pager log --oneline -5
echo

# ---------------------------------------------------------------
# 3. Push. Uses your existing git credentials (keychain, gh CLI or
#    SSH agent). This script never handles a token or password.
# ---------------------------------------------------------------
echo "Pushing to $REMOTE ..."
if git push -u origin main; then
  echo
  echo "Done. https://github.com/dil-gkondor/AI-chat-motions"
else
  echo
  echo "-----------------------------------------------------------"
  echo "Push was rejected."
  echo
  echo "If the repo already has commits (e.g. it was created with a"
  echo "README or .gitignore), pull them in first:"
  echo
  echo "    git pull --rebase origin main && git push -u origin main"
  echo
  echo "If you would rather replace whatever is on the remote — this"
  echo "DISCARDS the remote history, so check the repo first:"
  echo
  echo "    git push --force-with-lease -u origin main"
  echo
  echo "If it failed on authentication, sign in once with:"
  echo
  echo "    gh auth login          # GitHub CLI"
  echo
  echo "-----------------------------------------------------------"
  exit 1
fi
