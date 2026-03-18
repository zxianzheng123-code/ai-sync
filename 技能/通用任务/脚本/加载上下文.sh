#!/bin/bash
SKILL_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPO_ROOT="$(cd "$SKILL_ROOT/../.." && pwd)"

echo "===== 工作人员：全部人设（动态加载） ====="
for persona_dir in "$REPO_ROOT/技能/人设库"/*/; do
  persona_name="$(basename "$persona_dir")"
  echo "===== 工作人员：$persona_name ====="
  cat "$persona_dir/人设.md"
  echo ""
  echo "--- 专业知识 ---"
  cat "$persona_dir/专业知识/"*.md 2>/dev/null
  echo ""
done

echo "===== 作业指引 ====="
cat "$SKILL_ROOT/作业指引/"*.md 2>/dev/null
echo ""

echo "===== 输出模板 ====="
cat "$SKILL_ROOT/资源/"*.md 2>/dev/null
echo ""

echo "===== 客户反馈报告 ====="
cat "$REPO_ROOT/客户反馈报告/通用任务.md" 2>/dev/null
