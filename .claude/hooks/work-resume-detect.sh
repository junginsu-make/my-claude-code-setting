#!/bin/bash
export PATH="$HOME/bin:$PATH"

# SessionStart hook: detect WORK_IN_PROGRESS.md and notify
INPUT=$(cat)

# Extract project directory
PROJECT_DIR=$(echo "$INPUT" | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    cwd = d.get('cwd', d.get('session', {}).get('cwd', ''))
    print(cwd)
except:
    pass
" 2>/dev/null)

if [ -z "$PROJECT_DIR" ]; then
    PROJECT_DIR="$(pwd)"
fi

# Find git root or use project dir
GIT_ROOT=$(cd "$PROJECT_DIR" 2>/dev/null && git rev-parse --show-toplevel 2>/dev/null) || GIT_ROOT="$PROJECT_DIR"

WIP_FILE="$GIT_ROOT/.claude/WORK_IN_PROGRESS.md"

if [ -f "$WIP_FILE" ]; then
    # Extract saved_at from frontmatter
    SAVED_AT=$(grep "^saved_at:" "$WIP_FILE" 2>/dev/null | sed 's/saved_at: //')
    if [ -n "$SAVED_AT" ]; then
        echo "이전 작업 기록이 있습니다 (저장: $SAVED_AT). /resume-work 로 이어서 할 수 있습니다."
    else
        echo "이전 작업 기록이 있습니다. /resume-work 로 이어서 할 수 있습니다."
    fi
fi

exit 0
