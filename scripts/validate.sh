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

# ── 检查 5：协议文件存在性 ──────────────────────────────
echo ""
echo "=== 检查 5：协议文件存在性 ==="

REQUIRED_PROTOCOLS=(
    "角色协议.md"
    "总转化协议.md"
    "成题协议.md"
    "答案协议.md"
    "证据协议.md"
    "判断协议.md"
    "方法协议.md"
    "教材协议.md"
    "执行闭环协议.md"
    "工具链协议.md"
    "通用审查协议.md"
    "流程执行协议.md"
)

missing_protocols=()
for proto in "${REQUIRED_PROTOCOLS[@]}"; do
    if [ ! -f "$ROOT/技能/协议/$proto" ]; then
        missing_protocols+=("$proto")
    fi
done

if [ ${#missing_protocols[@]} -eq 0 ]; then
    green "✅ 协议文件：${#REQUIRED_PROTOCOLS[@]}/${#REQUIRED_PROTOCOLS[@]} 协议文件存在"
    PASS=$((PASS + 1))
else
    red "❌ 协议文件：以下协议文件缺失："
    for p in "${missing_protocols[@]}"; do
        red "   - 技能/$p"
    done
    FAIL=$((FAIL + 1))
fi

# ── 检查 6：SKILL.md 基础协议引用 ─────────────────────
echo ""
echo "=== 检查 6：SKILL.md 基础协议引用 ==="

# 每个 SKILL.md 至少应引用角色协议（按需引用其他协议，不再强制全量）
REQUIRED_KEYWORDS=(
    "角色协议"
)

ref_fail=0
ref_total=0
for dir in "$ROOT/技能"/*/; do
    [ -d "$dir" ] || continue
    skill_file="$dir/SKILL.md"
    [ -f "$skill_file" ] || continue
    dirname=$(basename "$dir")
    ref_total=$((ref_total + 1))
    missing_refs=()
    for kw in "${REQUIRED_KEYWORDS[@]}"; do
        if ! grep -q "$kw" "$skill_file"; then
            missing_refs+=("$kw")
        fi
    done
    if [ ${#missing_refs[@]} -gt 0 ]; then
        ref_fail=$((ref_fail + 1))
        red "   ❌ $dirname：缺少引用 → ${missing_refs[*]}"
    fi
done

if [ "$ref_fail" -eq 0 ]; then
    green "✅ 基础协议引用：${ref_total} 个技能全部引用了角色协议"
    PASS=$((PASS + 1))
else
    red "❌ 基础协议引用：${ref_fail}/${ref_total} 个技能缺少基础协议引用（详见上方）"
    FAIL=$((FAIL + 1))
fi

# ── 检查 7：SKILL.md 结构合规性 ─────────────────────────
echo ""
echo "=== 检查 7：SKILL.md 结构合规性 ==="

struct_fail=0
struct_total=0
for dir in "$ROOT/技能"/*/; do
    [ -d "$dir" ] || continue
    skill_file="$dir/SKILL.md"
    [ -f "$skill_file" ] || continue
    dirname=$(basename "$dir")
    struct_total=$((struct_total + 1))
    issues=()

    # 检查 YAML frontmatter
    first_line=$(head -1 "$skill_file")
    if [ "$first_line" != "---" ]; then
        issues+=("缺少YAML frontmatter")
    else
        # 检查 name 和 description 字段
        # 读取 frontmatter 部分（第一个 --- 到第二个 --- 之间）
        frontmatter=$(sed -n '1,/^---$/p' "$skill_file" | tail -n +2 | head -n -1)
        if ! echo "$frontmatter" | grep -q "^name:"; then
            issues+=("frontmatter缺少name")
        fi
        if ! echo "$frontmatter" | grep -q "^description:"; then
            issues+=("frontmatter缺少description")
        fi
    fi

    # 检查 TL;DR 段
    if ! grep -q "TL;DR" "$skill_file"; then
        issues+=("缺少TL;DR段")
    fi

    # 检查 Initialization 段
    if ! grep -q "Initialization\|初始化" "$skill_file"; then
        issues+=("缺少Initialization段")
    fi

    if [ ${#issues[@]} -gt 0 ]; then
        struct_fail=$((struct_fail + 1))
        red "   ❌ $dirname：$(IFS='、'; echo "${issues[*]}")"
    fi
done

if [ "$struct_fail" -eq 0 ]; then
    green "✅ 结构合规：${struct_total} 个技能全部符合结构要求"
    PASS=$((PASS + 1))
else
    red "❌ 结构合规：${struct_fail}/${struct_total} 个技能结构不完整（详见上方）"
    FAIL=$((FAIL + 1))
fi

# ── 检查 8：召唤书 ↔ 技能目录双向一致性 ─────────────────
echo ""
echo "=== 检查 8：召唤书 ↔ 技能目录双向一致性 ==="

# 从召唤书提取技能目录名
book_dirs=()
while IFS= read -r line; do
    dir_name=$(echo "$line" | grep -oP '`技能/\K[^/]+(?=/SKILL\.md`)' || true)
    if [ -n "$dir_name" ]; then
        # 去重
        already=0
        for d in "${book_dirs[@]+"${book_dirs[@]}"}"; do
            if [ "$d" = "$dir_name" ]; then
                already=1
                break
            fi
        done
        if [ "$already" -eq 0 ]; then
            book_dirs+=("$dir_name")
        fi
    fi
done < "$ROOT/正哥技能召唤书.md"

# 从文件系统获取技能目录名
fs_dirs=()
for dir in "$ROOT/技能"/*/; do
    [ -d "$dir" ] || continue
    [ -f "$dir/SKILL.md" ] || continue
    fs_dirs+=("$(basename "$dir")")
done

# 正向：文件系统有但召唤书没有
orphan_dirs=()
for fd in "${fs_dirs[@]}"; do
    found=0
    for bd in "${book_dirs[@]+"${book_dirs[@]}"}"; do
        if [ "$fd" = "$bd" ]; then
            found=1
            break
        fi
    done
    if [ "$found" -eq 0 ]; then
        orphan_dirs+=("$fd")
    fi
done

# 反向：召唤书有但文件系统没有（已被检查 1 覆盖，这里补充反向信息）
missing_dirs=()
for bd in "${book_dirs[@]+"${book_dirs[@]}"}"; do
    found=0
    for fd in "${fs_dirs[@]}"; do
        if [ "$bd" = "$fd" ]; then
            found=1
            break
        fi
    done
    if [ "$found" -eq 0 ]; then
        missing_dirs+=("$bd")
    fi
done

bidir_ok=1
if [ ${#orphan_dirs[@]} -gt 0 ]; then
    bidir_ok=0
    red "   ❌ 以下技能目录不在召唤书中："
    for o in "${orphan_dirs[@]}"; do
        red "      - 技能/$o/"
    done
fi
if [ ${#missing_dirs[@]} -gt 0 ]; then
    bidir_ok=0
    red "   ❌ 召唤书中引用但目录不存在："
    for m in "${missing_dirs[@]}"; do
        red "      - 技能/$m/"
    done
fi

if [ "$bidir_ok" -eq 1 ]; then
    green "✅ 双向一致：召唤书（${#book_dirs[@]}）↔ 技能目录（${#fs_dirs[@]}）完全对应"
    PASS=$((PASS + 1))
else
    FAIL=$((FAIL + 1))
fi

# ── 检查 9：角色库文件存在性 ────────────────────────
echo ""
echo "=== 检查 9：角色库文件存在性 ==="

ROLE_FILES=(
    "角色/写作主笔.md"
    "角色/设计主笔.md"
    "角色/工程主笔.md"
    "角色/路由调度员.md"
    "角色/完整性审查官.md"
    "角色/逻辑审查官.md"
    "角色/事实核查官.md"
    "角色/反方审查官.md"
    "角色/可执行性审查官.md"
    "角色/工程审查官.md"
    "角色/业务翻译官.md"
    "角色/技术翻译官.md"
)

missing_role=()
for rp in "${ROLE_FILES[@]}"; do
    if [ ! -f "$ROOT/技能/$rp" ]; then
        missing_role+=("$rp")
    fi
done

if [ ${#missing_role[@]} -eq 0 ]; then
    green "✅ 角色库：${#ROLE_FILES[@]} 个角色文件全部存在"
    PASS=$((PASS + 1))
else
    red "❌ 角色库：以下角色文件缺失："
    for r in "${missing_role[@]}"; do
        red "   - 技能/$r"
    done
    FAIL=$((FAIL + 1))
fi

# ── 检查 10：使用指引引用有效性 ─────────────────────────
echo ""
echo "=== 检查 10：使用指引引用有效性 ==="

guide_file="$ROOT/使用指引.md"
if [ -f "$guide_file" ]; then
    guide_fail=0
    while IFS= read -r line; do
        # 提取 对外规则库/ 下的路径引用
        ref_path=$(echo "$line" | grep -oP '对外规则库/[^`\s]+\.md' || true)
        if [ -n "$ref_path" ]; then
            if [ ! -f "$ROOT/$ref_path" ]; then
                guide_fail=$((guide_fail + 1))
                red "   ❌ 引用文件不存在：$ref_path"
            fi
        fi
    done < "$guide_file"

    if [ "$guide_fail" -eq 0 ]; then
        green "✅ 使用指引：所有引用的规则文件存在"
        PASS=$((PASS + 1))
    else
        red "❌ 使用指引：${guide_fail} 个引用文件不存在（详见上方）"
        FAIL=$((FAIL + 1))
    fi
else
    yellow "⚠️ 使用指引：使用指引.md 文件不存在"
    WARN=$((WARN + 1))
fi

# ── 检查 11：Markdown 相对链接有效性 ───────────────────
echo ""
echo "=== 检查 11：Markdown 相对链接有效性 ==="

link_fail=0
link_total=0

# 检查技能目录下所有 .md 文件中的相对链接
# 用临时文件避免子 shell 变量问题
link_tmp=$(mktemp)
trap 'rm -f "$link_tmp"' EXIT

for md_file in $(find "$ROOT/技能" -name "*.md" -type f 2>/dev/null); do
    md_dir=$(dirname "$md_file")
    for link_match in $(grep -oP '\[[^\]]*\]\([^)]+\.md\)' "$md_file" 2>/dev/null || true); do
        link_path=$(echo "$link_match" | grep -oP '(?<=\()\.\.?/[^)]+\.md(?=\))' || true)
        if [ -n "$link_path" ]; then
            link_total=$((link_total + 1))
            resolved=$(cd "$md_dir" && realpath -m "$link_path" 2>/dev/null || echo "$md_dir/$link_path")
            if [ ! -f "$resolved" ]; then
                link_fail=$((link_fail + 1))
                rel_file="${md_file#"$ROOT/"}"
                red "   ❌ $rel_file → $link_path（文件不存在）"
            fi
        fi
    done
done

if [ "$link_fail" -eq 0 ]; then
    green "✅ Markdown 链接：${link_total} 个相对链接全部有效"
    PASS=$((PASS + 1))
else
    red "❌ Markdown 链接：${link_fail}/${link_total} 个链接无效（详见上方）"
    FAIL=$((FAIL + 1))
fi

# ── 汇总 ────────────────────────────────────────────────
echo ""
echo "================================"
echo "检查完成：✅ ${PASS} 通过  ⚠️ ${WARN} 提醒  ❌ ${FAIL} 失败"
echo "================================"

exit $FAIL
