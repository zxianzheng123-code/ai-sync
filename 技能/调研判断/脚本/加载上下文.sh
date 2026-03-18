#!/bin/bash
SKILL_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPO_ROOT="$(cd "$SKILL_ROOT/../.." && pwd)"

echo "===== 工作人员：写作主笔 ====="
cat "$REPO_ROOT/技能/人设库/写作主笔/人设.md"
echo ""
echo "--- 专业知识 ---"
cat "$REPO_ROOT/技能/人设库/写作主笔/专业知识/"*.md 2>/dev/null
echo ""

echo "===== 工作人员：事实核查 ====="
cat "$REPO_ROOT/技能/人设库/事实核查/人设.md"
echo ""
echo "--- 专业知识 ---"
cat "$REPO_ROOT/技能/人设库/事实核查/专业知识/"*.md 2>/dev/null
echo ""

echo "===== 工作人员：反方审查 ====="
cat "$REPO_ROOT/技能/人设库/反方审查/人设.md"
echo ""
echo "--- 专业知识 ---"
cat "$REPO_ROOT/技能/人设库/反方审查/专业知识/"*.md 2>/dev/null
echo ""

echo "===== 工作人员：逻辑审查 ====="
cat "$REPO_ROOT/技能/人设库/逻辑审查/人设.md"
echo ""
echo "--- 专业知识 ---"
cat "$REPO_ROOT/技能/人设库/逻辑审查/专业知识/"*.md 2>/dev/null
echo ""

echo "===== 作业指引 ====="
cat "$SKILL_ROOT/作业指引/"*.md 2>/dev/null
echo ""

echo "===== 输出模板 ====="
cat "$SKILL_ROOT/资源/"*.md 2>/dev/null
echo ""

echo "===== 客户反馈报告 ====="
cat "$REPO_ROOT/客户反馈报告/调研判断.md" 2>/dev/null
