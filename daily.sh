#!/bin/bash
# Daily Persian news fetcher — run from cron. See crontab -l.
export PATH="$HOME/.opencode/bin:$HOME/.local/bin:$HOME/.npm-global/bin:/usr/local/bin:/usr/bin:/bin"
REPO_DIR="$HOME/Develop/daily-news-fa"
cd "$REPO_DIR" || exit 1
git pull --ff-only origin main 2>&1
YESTERDAY=$(date -d "yesterday" +%F)
opencode run --dir "$REPO_DIR" --auto "Use the daily-news-fa skill (~/.config/opencode/skills/daily-news-fa/SKILL.md). Yesterday was $YESTERDAY. If $YESTERDAY.md already exists in the repo and is pushed to origin/main, do nothing and exit. Otherwise collect yesterday's top news, translate to Persian, save $YESTERDAY.md, update the README Latest section and index, commit and push." 2>&1
