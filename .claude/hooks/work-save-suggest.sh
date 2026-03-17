#!/bin/bash
export PATH="$HOME/bin:$PATH"

# Stop hook: suggest saving progress if significant work was done
INPUT=$(cat)

TOOL_COUNT=$(echo "$INPUT" | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    print(d.get('tool_use_count', d.get('num_tool_uses', 0)))
except:
    print(0)
" 2>/dev/null)

if [ "$TOOL_COUNT" -ge 10 ] 2>/dev/null; then
    echo "작업량이 많았습니다. /save-progress 로 진행상황을 저장해두면 다음에 이어서 할 수 있습니다."
fi

exit 0
