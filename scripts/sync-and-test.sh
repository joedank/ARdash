#!/usr/bin/env bash

# Synchronise the local ARdash checkout with GitHub.
# Optional extras:
#   --merge-branch <name>       Merge origin/<name> into main (fast-forward by default)
#   --merge-latest-claude       Merge the newest origin/claude/* branch into main
#   --allow-non-ff              Allow merge commits when the merge cannot fast-forward
#   --force                     Discard local changes (reset --hard / clean -fd)
#   --target <dir>              Use a custom checkout directory (defaults to repo root)

set -euo pipefail

REPO_URL="https://github.com/joedank/ARdash.git"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_TARGET="$(cd "${SCRIPT_DIR}/.." && pwd)"

FORCE_RESET=0
TARGET_DIR=""
MERGE_BRANCH=""
AUTO_LATEST_CLAUDE=0
ALLOW_NON_FF=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --force)
      FORCE_RESET=1
      shift
      ;;
    --merge-branch)
      if [[ $# -lt 2 ]]; then
        echo "Error: --merge-branch requires a branch name (e.g., claude/session-123)" >&2
        exit 1
      fi
      MERGE_BRANCH="$2"
      shift 2
      ;;
    --merge-latest-claude)
      AUTO_LATEST_CLAUDE=1
      shift
      ;;
    --allow-non-ff)
      ALLOW_NON_FF=1
      shift
      ;;
    --target)
      if [[ $# -lt 2 ]]; then
        echo "Error: --target requires a directory path" >&2
        exit 1
      fi
      TARGET_DIR="$2"
      shift 2
      ;;
    --)
      shift
      break
      ;;
    -*)
      echo "Error: Unknown option $1" >&2
      exit 1
      ;;
    *)
      TARGET_DIR="$1"
      shift
      ;;
  esac

done

TARGET_DIR="${TARGET_DIR:-$DEFAULT_TARGET}"

echo ">>> Target directory: ${TARGET_DIR}"

if [ ! -d "${TARGET_DIR}" ]; then
  echo "Target directory does not exist. Cloning repository..."
  git clone "${REPO_URL}" "${TARGET_DIR}"
fi

cd "${TARGET_DIR}"

if [ ! -d ".git" ]; then
  echo "Error: ${TARGET_DIR} exists but is not a git repository." >&2
  exit 1
fi

REMOTE_URL="$(git remote get-url origin)"
if [ "${REMOTE_URL}" != "${REPO_URL}" ]; then
  echo "Error: origin remote is '${REMOTE_URL}', expected '${REPO_URL}'." >&2
  echo "       Update the remote or pass --target to use another directory." >&2
  exit 1
fi

echo ">>> Fetching latest changes..."
git fetch --all --prune

CURRENT_BRANCH="$(git rev-parse --abbrev-ref HEAD)"
if [ "${CURRENT_BRANCH}" != "main" ]; then
  if [ "${FORCE_RESET}" -eq 1 ]; then
    echo ">>> Switching to main branch (was '${CURRENT_BRANCH}')..."
    git checkout main
  else
    echo "Error: currently on branch '${CURRENT_BRANCH}'. Switch to 'main' or re-run with --force." >&2
    exit 1
  fi
fi

if [ -n "$(git status --porcelain)" ]; then
  if [ "${FORCE_RESET}" -eq 1 ]; then
    echo ">>> Working tree dirty. Forcing reset to origin/main..."
    git reset --hard origin/main
    git clean -fd
  else
    echo "Working tree has uncommitted changes. Commit/stash them or rerun with --force to discard." >&2
    exit 1
  fi
else
  echo ">>> Working tree clean."
  git pull --ff-only origin main
fi

if [ "${AUTO_LATEST_CLAUDE}" -eq 1 ] && [ -z "${MERGE_BRANCH}" ]; then
  MERGE_BRANCH="$(git for-each-ref --sort=-committerdate --count=1 --format='%(refname:strip=3)' 'refs/remotes/origin/claude/' || true)"
  if [ -z "${MERGE_BRANCH}" ]; then
    echo "Error: --merge-latest-claude requested but no origin/claude/* branches were found." >&2
    exit 1
  fi
  echo ">>> Latest Claude branch detected: ${MERGE_BRANCH}"
fi

if [ -n "${MERGE_BRANCH}" ]; then
  if ! git show-ref --verify --quiet "refs/remotes/origin/${MERGE_BRANCH}"; then
    echo "Error: origin/${MERGE_BRANCH} does not exist. Aborting merge." >&2
    exit 1
  fi

  echo ">>> Merging origin/${MERGE_BRANCH} into main..."
  if [ "${ALLOW_NON_FF}" -eq 1 ]; then
    git merge --no-ff "origin/${MERGE_BRANCH}"
  else
    if ! git merge --ff-only "origin/${MERGE_BRANCH}"; then
      echo "Error: Failed to fast-forward merge origin/${MERGE_BRANCH}." >&2
      echo "       Re-run with --allow-non-ff to permit an explicit merge commit." >&2
      exit 1
    fi
  fi

  echo ">>> Pushing merged changes to origin/main..."
  git push origin main
fi

echo ">>> Installing npm dependencies..."
npm install

echo ">>> Running build (release)..."
./universal_build.sh --release

echo ">>> All done! Repository is up to date and the release build has completed."
