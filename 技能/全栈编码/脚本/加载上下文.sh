#!/bin/bash
SKILL_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPO_ROOT="$(cd "$SKILL_ROOT/../.." && pwd)"

echo "===== 工作人员：全栈开发 ====="
cat "$REPO_ROOT/技能/人设库/全栈开发/人设.md"
echo ""
echo "--- 专业知识 ---"
cat "$REPO_ROOT/技能/人设库/全栈开发/专业知识/"*.md 2>/dev/null
echo ""

echo "===== 工作人员：工程审查 ====="
cat "$REPO_ROOT/技能/人设库/工程审查/人设.md"
echo ""
echo "--- 专业知识 ---"
cat "$REPO_ROOT/技能/人设库/工程审查/专业知识/"*.md 2>/dev/null
echo ""

echo "===== 工作人员：测试工程师 ====="
cat "$REPO_ROOT/技能/人设库/测试工程师/人设.md"
echo ""
echo "--- 专业知识 ---"
cat "$REPO_ROOT/技能/人设库/测试工程师/专业知识/"*.md 2>/dev/null
echo ""

echo "===== 作业指引 ====="
cat "$SKILL_ROOT/作业指引/"*.md 2>/dev/null
echo ""

echo "===== 输出模板 ====="
cat "$SKILL_ROOT/资源/"*.md 2>/dev/null
echo ""

echo "===== 客户反馈报告 ====="
cat "$REPO_ROOT/客户反馈报告/全栈编码.md" 2>/dev/null
