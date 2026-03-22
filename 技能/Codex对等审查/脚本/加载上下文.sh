#!/usr/bin/env bash
# Step 0：加载本技能所需的上下文

SKILL_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPO_ROOT="$(cd "$SKILL_ROOT/../.." && pwd)"

echo "=== 加载 Codex对等审查 技能上下文 ==="

# 1. 本技能流程
cat "$SKILL_ROOT/SKILL.md"

# 2. 工作人员人设
cat "$REPO_ROOT/技能/人设库/工程/人设.md"

# 3. 共享审查知识
cat "$REPO_ROOT/技能/共享知识/审查/"*.md 2>/dev/null

# 4. 交付自查清单
if [ -f "$SKILL_ROOT/作业指引/交付自查清单.md" ]; then
  cat "$SKILL_ROOT/作业指引/交付自查清单.md"
fi

echo "=== 上下文加载完成 ==="
