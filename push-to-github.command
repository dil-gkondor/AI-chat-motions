#!/bin/bash
# One-time helper: clean up, then push this project to GitHub.
# Double-click, or run:  bash push-to-github.command
set -u
cd "$(dirname "$0")" || exit 1

REMOTE="https://github.com/dil-gkondor/AI-chat-motions.git"

echo "Repository: $(pwd)"
echo

# ---------------------------------------------------------------
# 1. Clear stale lock files.
#    The repo was initialised from a sandbox whose mount does not
#    allow unlink(), so git could not clean up after itself. These
#    are leftovers, not an actual running git process.
# ---------------------------------------------------------------
find .git -name '*.lock' -delete 2>/dev/null
find .git -name 'tmp_obj_*' -delete 2>/dev/null
echo "Cleared stale git lock files."

# ---------------------------------------------------------------
# 2. Sanity check
# ---------------------------------------------------------------
if ! git rev-parse --git-dir >/dev/null 2>&1; then
  echo "No git repository found here. Aborting." >&2
  exit 1
fi

git remote remove origin 2>/dev/null
git remote add origin "$REMOTE"

echo
echo "Commit to push:"
git --no-pager log --oneline -1
echo
echo "Files:"
git ls-files
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
