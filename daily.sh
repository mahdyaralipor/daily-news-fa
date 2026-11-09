#!/bin/bash
# Daily Persian news fetcher — run from cron. See crontab -l.
export PATH="/snap/bin:$HOME/.opencode/bin:$HOME/.local/bin:$HOME/.npm-global/bin:/usr/local/bin:/usr/bin:/bin"
REPO_DIR="$HOME/Develop/daily-news-fa"
cd "$REPO_DIR" || exit 1
git pull --ff-only origin main 2>&1
YESTERDAY=$(date -d "yesterday" +%F)
# Current month at root; previous months in archive/YYYY-MM/
if [ "$(date -d "yesterday" +%Y-%m)" = "$(date +%Y-%m)" ]; then TARGET_DIR="$REPO_DIR"; else TARGET_DIR="$REPO_DIR/archive/$(date -d "yesterday" +%Y-%m)"; mkdir -p "$TARGET_DIR"; fi
if [ -f "$TARGET_DIR/$YESTERDAY.md" ] && git ls-remote --exit-code origin "refs/heads/main" >/dev/null 2>&1; then
  # File exists locally; let the agent verify it is pushed before no-op.
  :
fi
opencode run --dir "$REPO_DIR" --auto "Use the daily-news-fa skill (~/.config/opencode/skills/daily-news-fa/SKILL.md). Yesterday was $YESTERDAY and its target directory is $TARGET_DIR. If $YESTERDAY.md already exists in $TARGET_DIR and is pushed to origin/main, do nothing and exit. Otherwise collect yesterday's top news, translate to Persian, save $YESTERDAY.md plus dev-ai-$YESTERDAY.md for programming/AI news in $TARGET_DIR, update the README Latest and Dev & AI sections and index, commit and push. If a new month has started, first archive the previous month's files into archive/YYYY-MM/ with git mv and update README links." 2>&1
