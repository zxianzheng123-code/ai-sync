#!/bin/bash
SKILL_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPO_ROOT="$(cd "$SKILL_ROOT/../.." && pwd)"

echo "===== 工作人员：需求分析员 ====="
cat "$REPO_ROOT/技能/人设库/需求分析员/人设.md"
echo ""
echo "--- 专业知识 ---"
cat "$REPO_ROOT/技能/人设库/需求分析员/专业知识/"*.md 2>/dev/null
echo ""

echo "===== 工作人员：产品架构师 ====="
cat "$REPO_ROOT/技能/人设库/产品架构师/人设.md"
echo ""
echo "--- 专业知识 ---"
cat "$REPO_ROOT/技能/人设库/产品架构师/专业知识/"*.md 2>/dev/null
echo ""

echo "===== 工作人员：可行性评估员 ====="
cat "$REPO_ROOT/技能/人设库/可行性评估员/人设.md"
echo ""
echo "--- 专业知识 ---"
cat "$REPO_ROOT/技能/人设库/可行性评估员/专业知识/"*.md 2>/dev/null
echo ""

echo "===== 作业指引 ====="
cat "$SKILL_ROOT/作业指引/"*.md 2>/dev/null
echo ""

echo "===== 输出模板 ====="
cat "$SKILL_ROOT/资源/"*.md 2>/dev/null
echo ""

echo "===== 客户反馈报告 ====="
cat "$REPO_ROOT/客户反馈报告/需求规划.md" 2>/dev/null
