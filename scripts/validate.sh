#!/usr/bin/env bash
# AI-Sync 项目一致性校验脚本
# 用法：bash scripts/validate.sh

set -euo pipefail

# 定位项目根目录（脚本所在目录的上一级）
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

PASS=0
WARN=0
FAIL=0

green()  { printf '\033[32m%s\033[0m\n' "$1"; }
yellow() { printf '\033[33m%s\033[0m\n' "$1"; }
red()    { printf '\033[31m%s\033[0m\n' "$1"; }

# ── 检查 1：技能路径有效性 ──────────────────────────────
echo ""
echo "=== 检查 1：技能路径有效性 ==="

total_paths=0
valid_paths=0
invalid_paths=()

while IFS= read -r line; do
    # 提取 SKILL.md 路径（匹配 `技能/xxx/SKILL.md` 格式）
    path=$(echo "$line" | grep -oP '`技能/[^`]+/SKILL\.md`' | tr -d '`' || true)
    if [ -n "$path" ]; then
        total_paths=$((total_paths + 1))
        if [ -f "$ROOT/$path" ]; then
            valid_paths=$((valid_paths + 1))
        else
            invalid_paths+=("$path")
        fi
    fi
done < "$ROOT/正哥技能召唤书.md"

if [ ${#invalid_paths[@]} -eq 0 ]; then
    green "✅ 路径检查：${valid_paths}/${total_paths} 路径有效"
    PASS=$((PASS + 1))
else
    red "❌ 路径检查：${valid_paths}/${total_paths} 路径有效，以下路径无效："
    for p in "${invalid_paths[@]}"; do
        red "   - $p"
    done
    FAIL=$((FAIL + 1))
fi

# ── 检查 2：暗号唯一性 ──────────────────────────────────
echo ""
echo "=== 检查 2：暗号唯一性 ==="

# 提取所有暗号（表格中 | `暗号` | 列的内容）
codes=()
while IFS= read -r line; do
    # 匹配表格行中的暗号列（第3或第4列，格式为 `暗号`）
    code=$(echo "$line" | grep -oP '(?<=\| )`[^`]+`(?= \|)' | tr -d '`' || true)
    if [ -n "$code" ] && [ "$code" != "暗号" ] && [ "$code" != "暗号（单独触发用）" ]; then
        codes+=("$code")
    fi
done < "$ROOT/正哥技能召唤书.md"

# 检查重复
duplicates=$(printf '%s\n' "${codes[@]}" | sort | uniq -d)
if [ -z "$duplicates" ]; then
    green "✅ 暗号检查：${#codes[@]} 个暗号，无重复"
    PASS=$((PASS + 1))
else
    red "❌ 暗号检查：发现重复暗号："
    echo "$duplicates" | while read -r d; do
        red "   - $d"
    done
    FAIL=$((FAIL + 1))
fi

# ── 检查 3：CHANGELOG 时效性 ────────────────────────────
echo ""
echo "=== 检查 3：CHANGELOG 时效性 ==="

changelog="$ROOT/技能/CHANGELOG.md"
if [ -f "$changelog" ]; then
    # 提取最新日期（格式 YYYY-MM-DD 或 YYYY.MM.DD 或 YYYY/MM/DD）
    latest_date=$(grep -oP '\d{4}[-./]\d{2}[-./]\d{2}' "$changelog" | head -1 || true)
    if [ -n "$latest_date" ]; then
        # 统一为 YYYY-MM-DD
        normalized=$(echo "$latest_date" | tr './' '--')
        latest_ts=$(date -d "$normalized" +%s 2>/dev/null || echo "0")
        now_ts=$(date +%s)
        days_ago=$(( (now_ts - latest_ts) / 86400 ))

        if [ "$days_ago" -le 30 ]; then
            green "✅ CHANGELOG 时效：最近更新于 ${normalized}（${days_ago} 天前）"
            PASS=$((PASS + 1))
        else
            yellow "⚠️ CHANGELOG 提醒：最近更新于 ${normalized}，距今已 ${days_ago} 天"
            WARN=$((WARN + 1))
        fi
    else
        yellow "⚠️ CHANGELOG 提醒：未找到日期格式的记录"
        WARN=$((WARN + 1))
    fi
else
    red "❌ CHANGELOG 文件不存在：$changelog"
    FAIL=$((FAIL + 1))
fi

# ── 检查 4：技能目录完整性 ──────────────────────────────
echo ""
echo "=== 检查 4：技能目录完整性 ==="

total_dirs=0
complete_dirs=0
missing_skill=()

for dir in "$ROOT/技能"/*/; do
    [ -d "$dir" ] || continue
    dirname=$(basename "$dir")
    total_dirs=$((total_dirs + 1))
    if [ -f "$dir/SKILL.md" ]; then
        complete_dirs=$((complete_dirs + 1))
    else
        missing_skill+=("$dirname")
    fi
done

if [ ${#missing_skill[@]} -eq 0 ]; then
    green "✅ 目录完整性：${complete_dirs}/${total_dirs} 技能目录包含 SKILL.md"
    PASS=$((PASS + 1))
else
    red "❌ 目录完整性：${complete_dirs}/${total_dirs}，以下目录缺少 SKILL.md："
    for m in "${missing_skill[@]}"; do
        red "   - 技能/$m/"
    done
    FAIL=$((FAIL + 1))
fi

# ── 汇总 ────────────────────────────────────────────────
echo ""
echo "================================"
echo "检查完成：✅ ${PASS} 通过  ⚠️ ${WARN} 提醒  ❌ ${FAIL} 失败"
echo "================================"

exit $FAIL
