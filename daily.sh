#!/bin/bash
# Daily Persian news fetcher — single scheduler: daily-news-fa.timer (crontab entry removed 2026-11-09).
set -u
export PATH="/snap/bin:$HOME/.opencode/bin:$HOME/.local/bin:$HOME/.npm-global/bin:/usr/local/bin:/usr/bin:/bin"
REPO_DIR="$HOME/Develop/daily-news-fa"
cd "$REPO_DIR" || exit 1
exec 9>"$REPO_DIR/.daily.lock"
flock -n 9 || { echo "$(date -Is) another run is still in progress; exiting"; exit 0; }
# Network can be down right after boot; retry the fetch instead of dying on DNS.
for attempt in 1 2 3; do
  git fetch origin main && break
  [ "$attempt" = 3 ] && { echo "$(date -Is) fetch failed 3x; exiting"; exit 0; }
  sleep 20
done
git checkout -q main || exit 1
git merge --ff-only FETCH_HEAD || exit 1
YESTERDAY=$(date -d "yesterday" +%F)
MONTH=$(date -d "yesterday" +%Y-%m)
if [ "$MONTH" = "$(date +%Y-%m)" ]; then
  TARGET_DIR="$REPO_DIR"; REL="$YESTERDAY.md"
else
  TARGET_DIR="$REPO_DIR/archive/$MONTH"; REL="archive/$MONTH/$YESTERDAY.md"
fi
if git cat-file -e "origin/main:$REL" 2>/dev/null; then
  echo "$(date -Is) $REL already published; nothing to do."
  exit 0
fi
mkdir -p "$TARGET_DIR"
opencode run --dir "$REPO_DIR" --auto "Use the daily-news-fa skill (~/.config/opencode/skills/daily-news-fa/SKILL.md). Yesterday was $YESTERDAY and its target directory is $TARGET_DIR. If $YESTERDAY.md already exists in $TARGET_DIR and is pushed to origin/main, do nothing and exit. Otherwise collect yesterday's top news, translate to Persian, save $YESTERDAY.md plus dev-ai-$YESTERDAY.md for programming/AI news in $TARGET_DIR, update the README Latest and Dev & AI sections and index (index lists only the current month; past months stay as links under آرشیو ماه‌های گذشته), commit and push. If a new month has started, first archive the previous month's files into archive/YYYY-MM/ with git mv and update README links." 2>&1
rc=$?
echo "$(date -Is) opencode exit=$rc"
exit "$rc"
