#!/bin/bash
SKILL_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPO_ROOT="$(cd "$SKILL_ROOT/../.." && pwd)"

echo "===== 工作人员：客户经理 ====="
cat "$REPO_ROOT/技能/人设库/客户经理/人设.md"
echo ""
echo "--- 专业知识 ---"
cat "$REPO_ROOT/技能/人设库/客户经理/专业知识/"*.md 2>/dev/null
echo ""

echo "===== 作业指引 ====="
cat "$SKILL_ROOT/作业指引/"*.md 2>/dev/null
echo ""

echo "===== 输出模板 ====="
cat "$SKILL_ROOT/资源/"*.md 2>/dev/null
echo ""

echo "===== 客户反馈报告 ====="
cat "$REPO_ROOT/客户反馈报告/造工具.md" 2>/dev/null
