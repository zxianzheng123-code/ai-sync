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

is_md_table_row() {
    case "$1" in
        '|'*'|') return 0 ;;
        *) return 1 ;;
    esac
}

is_md_table_separator() {
    local compact
    compact=$(printf '%s\n' "$1" | tr -d '[:space:]|:-')
    [ -z "$compact" ]
}

md_table_cell() {
    local line="$1"
    local col="$2"
    printf '%s\n' "$line" | awk -F'|' -v c="$col" '{
        val = $c
        gsub(/\r/, "", val)
        gsub(/^[[:space:]`]+/, "", val)
        gsub(/[[:space:]`]+$/, "", val)
        print val
    }'
}

is_kebab_case() {
    printf '%s\n' "$1" | grep -Eq '^[a-z0-9]+(-[a-z0-9]+)*$'
}

lookup_md_table_cell_by_id() {
    local file="$1"
    local target_id="$2"
    local col="$3"
    local line row_id

    while IFS= read -r line || [ -n "$line" ]; do
        if is_md_table_row "$line" && ! is_md_table_separator "$line"; then
            row_id=$(md_table_cell "$line" 2)
            if [ "$row_id" = "$target_id" ]; then
                md_table_cell "$line" "$col"
                return 0
            fi
        fi
    done < "$file"

    return 1
}

trim_spaces() {
    printf '%s\n' "$1" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//'
}

iterate_semicolon_list() {
    local list="$1"
    local item
    local parts=()

    IFS=';' read -r -a parts <<< "$list"
    for item in "${parts[@]}"; do
        item=$(trim_spaces "$item")
        [ -n "$item" ] && printf '%s\n' "$item"
    done
}

# ── 检查 1：技能路径有效性 ──────────────────────────────
echo ""
echo "=== 检查 1：技能路径有效性 ==="

total_paths=0
valid_paths=0
invalid_paths=()

while IFS= read -r line; do
    # 提取 SKILL.md 路径（匹配 `技能/xxx/SKILL.md` 格式）
    path=$(printf '%s\n' "$line" | awk 'match($0, /`技能\/[^`]+\/SKILL\.md`/) { value = substr($0, RSTART + 1, RLENGTH - 2); print value; exit }' || true)
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
    code=$(printf '%s\n' "$line" | awk -F'|' '{
        for (i = 2; i < NF; i++) {
            cell = $i
            gsub(/^[[:space:]]+|[[:space:]]+$/, "", cell)
            if (cell ~ /^`[^`]+`$/) {
                gsub(/`/, "", cell)
                print cell
                exit
            }
        }
    }' || true)
    if [ -n "$code" ] && [ "$code" != "暗号" ] && [ "$code" != "暗号（单独触发用）" ]; then
        codes+=("$code")
    fi
done < "$ROOT/正哥技能召唤书.md"

# 检查重复
duplicates=$(printf '%s\n' "${codes[@]+"${codes[@]}"}" | sort | uniq -d)
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
        latest_date=$(grep -Eo '[0-9]{4}[-./][0-9]{2}[-./][0-9]{2}' "$changelog" | head -1 || true)
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
    if [ ! -f "$ROOT/协议/$proto" ]; then
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
        frontmatter=$(awk '
            NR == 1 && $0 == "---" { in_frontmatter = 1; next }
            in_frontmatter && $0 == "---" { exit }
            in_frontmatter { print }
        ' "$skill_file")
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
    dir_name=$(printf '%s\n' "$line" | awk 'match($0, /`技能\/[^`]+\/SKILL\.md`/) { value = substr($0, RSTART + 1, RLENGTH - 2); sub(/^技能\//, "", value); sub(/\/SKILL\.md$/, "", value); print value; exit }' || true)
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
    if [ ! -f "$ROOT/协议/$rp" ]; then
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
        ref_path=$(printf '%s\n' "$line" | grep -Eo '对外规则库/[^`[:space:]]+\.md' || true)
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
    for link_match in $(grep -Eo '\[[^]]*\]\((\.\./|\.\/)[^)]+\.md\)' "$md_file" 2>/dev/null || true); do
        link_path=$(printf '%s\n' "$link_match" | awk 'match($0, /\((\.\.\/|\.\/)[^)]+\.md\)/) { value = substr($0, RSTART + 1, RLENGTH - 2); print value; exit }' || true)
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

# ── 检查 12：工具体系文件树与必需文件存在 ───────────────────
echo ""
echo "=== 检查 12：工具体系文件树与必需文件存在 ==="

mcp_required_dirs=(
    "MCP"
    "MCP/配置模板"
    "MCP/密钥模板"
    "CLI"
    "项目工具清单"
)

mcp_required_files=(
    "工具注册表.md"
    "MCP/MCP接入总表.md"
    "MCP/CHANGELOG.md"
    "CLI/CHANGELOG.md"
    "项目工具清单/default.md"
    "MCP/配置模板/claude.mcp.json.example"
    "MCP/配置模板/codex.mcp.toml.example"
    "MCP/密钥模板/mcp-secrets.env.example"
    "scripts/check_tools_runtime.sh"
)

mcp_missing=()
for dir_path in "${mcp_required_dirs[@]}"; do
    if [ ! -d "$ROOT/$dir_path" ]; then
        mcp_missing+=("$dir_path")
    fi
done

for file_path in "${mcp_required_files[@]}"; do
    if [ ! -f "$ROOT/$file_path" ]; then
        mcp_missing+=("$file_path")
    fi
done

if [ ${#mcp_missing[@]} -eq 0 ]; then
    green "✅ 工具体系文件树：目录与必需文件均存在"
    PASS=$((PASS + 1))
else
    red "❌ 工具体系文件树：以下目录或文件缺失："
    for item in "${mcp_missing[@]}"; do
        red "   - $item"
    done
    FAIL=$((FAIL + 1))
fi

# ── 检查 13：MCP接入总表 -> 项目工具清单路径有效 ─────────────
echo ""
echo "=== 检查 13：MCP接入总表 -> 项目工具清单路径有效 ==="

mcp_intro="$ROOT/MCP/MCP接入总表.md"
if [ -f "$mcp_intro" ]; then
    intro_rows=0
    intro_fail=0
    intro_default_found=0
    intro_seen="|"

    while IFS= read -r line || [ -n "$line" ]; do
        if is_md_table_row "$line" && ! is_md_table_separator "$line"; then
            project_id=$(md_table_cell "$line" 2)
            project_name=$(md_table_cell "$line" 3)
            list_path=$(md_table_cell "$line" 4)
            fallback_flag=$(md_table_cell "$line" 5)

            case "$project_id" in
                project_id|项目id|项目_ID) continue ;;
            esac

            [ -z "$project_id" ] && continue
            intro_rows=$((intro_rows + 1))

            if ! is_kebab_case "$project_id" && [ "$project_id" != "default" ]; then
                intro_fail=$((intro_fail + 1))
                red "   ❌ 接入总表：project_id 不是 kebab-case → $project_id"
                continue
            fi

            if [ -z "$project_name" ]; then
                intro_fail=$((intro_fail + 1))
                red "   ❌ 接入总表：$project_id 缺少项目名"
            fi

            if [ -z "$list_path" ]; then
                intro_fail=$((intro_fail + 1))
                red "   ❌ 接入总表：$project_id 缺少清单路径"
                continue
            fi

            case "$list_path" in
                项目工具清单/*.md) ;;
                *)
                    intro_fail=$((intro_fail + 1))
                    red "   ❌ 接入总表：$project_id 的清单路径不在 项目工具清单/ 下 → $list_path"
                    continue
                    ;;
            esac

            resolved_list_path="$ROOT/$list_path"
            if [ ! -f "$resolved_list_path" ]; then
                intro_fail=$((intro_fail + 1))
                red "   ❌ 接入总表：$project_id 指向的清单不存在 → $list_path"
            fi

            if [ -z "$fallback_flag" ]; then
                intro_fail=$((intro_fail + 1))
                red "   ❌ 接入总表：$project_id 缺少是否默认回退"
            fi

            case "$intro_seen" in
                *"|$project_id|"*)
                    intro_fail=$((intro_fail + 1))
                    red "   ❌ 接入总表：重复 project_id → $project_id"
                    ;;
                *)
                    intro_seen="$intro_seen$project_id|"
                    ;;
            esac

            case "$project_id" in
                default)
                    intro_default_found=1
                    ;;
            esac
        fi
    done < "$mcp_intro"

    if [ "$intro_rows" -eq 0 ]; then
        intro_fail=$((intro_fail + 1))
        red "   ❌ 接入总表：未发现有效项目映射行"
    fi

    if [ "$intro_default_found" -ne 1 ]; then
        intro_fail=$((intro_fail + 1))
        red "   ❌ 接入总表：未发现 default 回退行"
    fi

    if [ "$intro_fail" -eq 0 ]; then
        green "✅ 接入总表：项目工具清单路径全部有效"
        PASS=$((PASS + 1))
    else
        FAIL=$((FAIL + 1))
    fi
else
    red "❌ 接入总表文件不存在：$mcp_intro"
    FAIL=$((FAIL + 1))
fi

# ── 检查 14：工具注册表字段完整性与 tool_id/类型 约束 ─
echo ""
echo "=== 检查 14：工具注册表字段完整性与 tool_id/类型 约束 ==="

mcp_registry="$ROOT/工具注册表.md"
if [ -f "$mcp_registry" ]; then
    registry_rows=0
    registry_fail=0
    registry_seen="|"

    while IFS= read -r line || [ -n "$line" ]; do
        if is_md_table_row "$line" && ! is_md_table_separator "$line"; then
            mcp_id=$(md_table_cell "$line" 2)
            tool_type=$(md_table_cell "$line" 3)
            version=$(md_table_cell "$line" 4)
            status=$(md_table_cell "$line" 5)
            display_name=$(md_table_cell "$line" 6)
            purpose=$(md_table_cell "$line" 7)
            client=$(md_table_cell "$line" 8)

            case "$mcp_id" in
                tool_id|mcp_id|MCP_ID|编号) continue ;;
            esac

            [ -z "$mcp_id" ] && continue
            registry_rows=$((registry_rows + 1))

            if ! is_kebab_case "$mcp_id"; then
                registry_fail=$((registry_fail + 1))
                red "   ❌ 注册表：tool_id 不是 kebab-case → $mcp_id"
                continue
            fi

            case "$registry_seen" in
                *"|$mcp_id|"*)
                    registry_fail=$((registry_fail + 1))
                    red "   ❌ 注册表：重复 tool_id → $mcp_id"
                    continue
                    ;;
                *)
                    registry_seen="$registry_seen$mcp_id|"
                    ;;
            esac

            case "$tool_type" in
                mcp|cli|plugin) ;;
                *)
                    registry_fail=$((registry_fail + 1))
                    red "   ❌ 注册表：$mcp_id 类型无效（须为 mcp/cli/plugin）→ $tool_type"
                    continue
                    ;;
            esac

            if [ -z "$display_name" ]; then
                registry_fail=$((registry_fail + 1))
                red "   ❌ 注册表：$mcp_id 缺少显示名"
            fi

            if [ -z "$purpose" ]; then
                registry_fail=$((registry_fail + 1))
                red "   ❌ 注册表：$mcp_id 缺少用途"
            fi

            if [ -z "$client" ]; then
                registry_fail=$((registry_fail + 1))
                red "   ❌ 注册表：$mcp_id 缺少适用客户端"
            fi

            case "$tool_type" in
                mcp|plugin)
                    connection=$(md_table_cell "$line" 9)
                    template_file=$(md_table_cell "$line" 10)
                    secret_key=$(md_table_cell "$line" 11)
                    check_type=$(md_table_cell "$line" 12)
                    check_target=$(md_table_cell "$line" 13)
                    success_flag=$(md_table_cell "$line" 14)
                    default_enabled=$(md_table_cell "$line" 15)
                    note=$(md_table_cell "$line" 16)

                    if [ -z "$version" ]; then
                        registry_fail=$((registry_fail + 1))
                        red "   ❌ 注册表：$mcp_id 缺少 version"
                    fi

                    if [ "$tool_type" = "mcp" ]; then
                        if [ -n "$template_file" ] && [ "$template_file" != "—" ]; then
                            while IFS= read -r template_ref; do
                                [ -n "$template_ref" ] || continue
                                case "$template_ref" in
                                    *.example) ;;
                                    *)
                                        registry_fail=$((registry_fail + 1))
                                        red "   ❌ 注册表：$mcp_id 模板文件不是 .example 结尾 → $template_ref"
                                        ;;
                                esac
                                if [ ! -f "$ROOT/$template_ref" ]; then
                                    registry_fail=$((registry_fail + 1))
                                    red "   ❌ 注册表：$mcp_id 模板文件不存在 → $template_ref"
                                fi
                            done < <(iterate_semicolon_list "$template_file")
                        fi
                    fi
                    ;;
                cli)
                    install_cmd=$(md_table_cell "$line" 9)
                    check_cmd=$(md_table_cell "$line" 10)
                    default_enabled=$(md_table_cell "$line" 11)
                    note=$(md_table_cell "$line" 12)

                    if [ -z "$install_cmd" ]; then
                        registry_fail=$((registry_fail + 1))
                        red "   ❌ 注册表：$mcp_id 缺少安装命令"
                    fi
                    if [ -z "$check_cmd" ]; then
                        registry_fail=$((registry_fail + 1))
                        red "   ❌ 注册表：$mcp_id 缺少检查命令"
                    fi
                    ;;
            esac
        fi
    done < "$mcp_registry"

    if [ "$registry_rows" -eq 0 ]; then
        registry_fail=$((registry_fail + 1))
        red "   ❌ 注册表：未发现有效工具条目"
    fi

    if [ "$registry_fail" -eq 0 ]; then
        green "✅ 注册表：字段完整且 tool_id 唯一"
        PASS=$((PASS + 1))
    else
        FAIL=$((FAIL + 1))
    fi
else
    red "❌ 注册表文件不存在：$mcp_registry"
    FAIL=$((FAIL + 1))
fi

# ── 检查 15：项目工具清单内联摘要 与 注册表一致 ─────────────
echo ""
echo "=== 检查 15：项目工具清单内联摘要 与 注册表一致 ==="

project_manifest_dir="$ROOT/项目工具清单"
if [ -d "$project_manifest_dir" ]; then
    project_manifest_fail=0
    project_manifest_count=0

    for project_file in "$project_manifest_dir"/*.md; do
        [ -e "$project_file" ] || continue
        project_manifest_count=$((project_manifest_count + 1))
        project_basename=$(basename "$project_file" .md)
        current_section=""
        basic_project_id=""
        basic_project_name=""
        basic_path_hint=""
        basic_source=""
        enabled_rows=0
        disabled_rows=0

        while IFS= read -r line || [ -n "$line" ]; do
            case "$line" in
                *"基本信息"*) current_section="basic" ;;
                *"启用 MCP"*) current_section="enabled_mcp" ;;
                *"启用 CLI"*) current_section="enabled_cli" ;;
                *"禁用表"*) current_section="disabled" ;;
            esac

            if printf '%s\n' "$line" | grep -q 'source=registry'; then
                basic_source="registry"
            fi

            if is_md_table_row "$line" && ! is_md_table_separator "$line"; then
                case "$current_section" in
                    basic)
                        key=$(md_table_cell "$line" 2)
                        value=$(md_table_cell "$line" 3)
                        case "$key" in
                            字段|key|值|字段名|项目字段) continue ;;
                            project_id) basic_project_id="$value" ;;
                            项目名) basic_project_name="$value" ;;
                            path_hint) basic_path_hint="$value" ;;
                            source) basic_source="$value" ;;
                        esac
                        ;;
                    enabled_mcp)
                        mcp_id=$(md_table_cell "$line" 2)
                        version=$(md_table_cell "$line" 3)
                        purpose_summary=$(md_table_cell "$line" 4)
                        template_file=$(md_table_cell "$line" 5)
                        secret_key=$(md_table_cell "$line" 6)
                        check_summary=$(md_table_cell "$line" 7)

                        case "$mcp_id" in
                            tool_id|mcp_id|编号) continue ;;
                        esac

                        [ -z "$mcp_id" ] && continue
                        enabled_rows=$((enabled_rows + 1))

                        registry_version=$(lookup_md_table_cell_by_id "$mcp_registry" "$mcp_id" 4 || true)
                        registry_template=$(lookup_md_table_cell_by_id "$mcp_registry" "$mcp_id" 10 || true)
                        registry_secret_key=$(lookup_md_table_cell_by_id "$mcp_registry" "$mcp_id" 11 || true)
                        registry_check_type=$(lookup_md_table_cell_by_id "$mcp_registry" "$mcp_id" 12 || true)
                        registry_check_target=$(lookup_md_table_cell_by_id "$mcp_registry" "$mcp_id" 13 || true)

                        if [ -z "$purpose_summary" ]; then
                            project_manifest_fail=$((project_manifest_fail + 1))
                            red "   ❌ 项目工具清单：$project_basename 的 $mcp_id 缺少用途摘要"
                        fi

                        if [ -z "$registry_version" ]; then
                            project_manifest_fail=$((project_manifest_fail + 1))
                            red "   ❌ 项目工具清单：$project_basename 的 $mcp_id 不在注册表中"
                            continue
                        fi

                        if [ "$version" != "$registry_version" ]; then
                            project_manifest_fail=$((project_manifest_fail + 1))
                            red "   ❌ 项目工具清单：$project_basename 的 $mcp_id version 与注册表不一致"
                        fi

                        if [ "$template_file" != "$registry_template" ]; then
                            project_manifest_fail=$((project_manifest_fail + 1))
                            red "   ❌ 项目工具清单：$project_basename 的 $mcp_id 模板文件与注册表不一致"
                        fi

                        if [ "$secret_key" != "$registry_secret_key" ]; then
                            project_manifest_fail=$((project_manifest_fail + 1))
                            red "   ❌ 项目工具清单：$project_basename 的 $mcp_id 密钥键与注册表不一致"
                        fi

                        case "$check_summary" in
                            *"$registry_check_type"*"$registry_check_target"*|*"$registry_check_target"*"$registry_check_type"*)
                                ;;
                            *)
                                project_manifest_fail=$((project_manifest_fail + 1))
                                red "   ❌ 项目工具清单：$project_basename 的 $mcp_id 可用性检查未同时包含类型与目标"
                                ;;
                        esac

                        if [ -z "$template_file" ]; then
                            project_manifest_fail=$((project_manifest_fail + 1))
                            red "   ❌ 项目工具清单：$project_basename 的 $mcp_id 缺少模板文件"
                        else
                            manifest_template_count=0
                            while IFS= read -r template_ref; do
                                [ -n "$template_ref" ] || continue
                                manifest_template_count=$((manifest_template_count + 1))
                                if [ ! -f "$ROOT/$template_ref" ]; then
                                    project_manifest_fail=$((project_manifest_fail + 1))
                                    red "   ❌ 项目工具清单：$project_basename 的 $mcp_id 模板文件不存在 → $template_ref"
                                fi
                            done < <(iterate_semicolon_list "$template_file")

                            if [ "$manifest_template_count" -eq 0 ]; then
                                project_manifest_fail=$((project_manifest_fail + 1))
                                red "   ❌ 项目工具清单：$project_basename 的 $mcp_id 模板文件列表为空"
                            fi
                        fi

                        if ! is_kebab_case "$mcp_id"; then
                            project_manifest_fail=$((project_manifest_fail + 1))
                            red "   ❌ 项目工具清单：$project_basename 的 mcp_id 不是 kebab-case → $mcp_id"
                        fi
                        ;;
                    enabled_cli)
                        cli_id=$(md_table_cell "$line" 2)
                        cli_purpose=$(md_table_cell "$line" 3)
                        cli_check=$(md_table_cell "$line" 4)

                        case "$cli_id" in
                            tool_id|编号) continue ;;
                        esac

                        [ -z "$cli_id" ] && continue
                        enabled_rows=$((enabled_rows + 1))

                        if ! is_kebab_case "$cli_id"; then
                            project_manifest_fail=$((project_manifest_fail + 1))
                            red "   ❌ 项目工具清单：$project_basename 的 CLI tool_id 不是 kebab-case → $cli_id"
                        fi

                        registry_check=$(lookup_md_table_cell_by_id "$mcp_registry" "$cli_id" 3 || true)
                        if [ -z "$registry_check" ]; then
                            project_manifest_fail=$((project_manifest_fail + 1))
                            red "   ❌ 项目工具清单：$project_basename 的 CLI $cli_id 不在注册表中"
                        fi
                        ;;
                    disabled)
                        mcp_id=$(md_table_cell "$line" 2)
                        disabled_reason=$(md_table_cell "$line" 4)

                        case "$mcp_id" in
                            tool_id|mcp_id|编号) continue ;;
                        esac

                        [ -z "$mcp_id" ] && continue
                        disabled_rows=$((disabled_rows + 1))

                        if [ -z "$disabled_reason" ]; then
                            project_manifest_fail=$((project_manifest_fail + 1))
                            red "   ❌ 项目工具清单：$project_basename 的 $mcp_id 缺少禁用原因"
                        fi

                        if [ -z "$(lookup_md_table_cell_by_id "$mcp_registry" "$mcp_id" 3 || true)" ]; then
                            project_manifest_fail=$((project_manifest_fail + 1))
                            red "   ❌ 项目工具清单：$project_basename 的禁用项不在注册表中 → $mcp_id"
                        fi
                        ;;
                esac
            fi
        done < "$project_file"

        if [ "$basic_project_id" != "$project_basename" ]; then
            project_manifest_fail=$((project_manifest_fail + 1))
            red "   ❌ 项目工具清单：文件名与 project_id 不一致 → $project_basename"
        fi

        if [ -z "$basic_project_name" ]; then
            project_manifest_fail=$((project_manifest_fail + 1))
            red "   ❌ 项目工具清单：$project_basename 缺少项目名"
        fi

        if [ -z "$basic_project_id" ]; then
            project_manifest_fail=$((project_manifest_fail + 1))
            red "   ❌ 项目工具清单：$project_basename 缺少 project_id"
        elif ! is_kebab_case "$basic_project_id" && [ "$basic_project_id" != "default" ]; then
            project_manifest_fail=$((project_manifest_fail + 1))
            red "   ❌ 项目工具清单：project_id 不是 kebab-case → $basic_project_id"
        fi

        if [ -z "$basic_path_hint" ]; then
            project_manifest_fail=$((project_manifest_fail + 1))
            red "   ❌ 项目工具清单：$project_basename 缺少 path_hint"
        fi

        if [ "$basic_source" != "registry" ]; then
            project_manifest_fail=$((project_manifest_fail + 1))
            red "   ❌ 项目工具清单：$project_basename 缺少 source=registry"
        fi

        if [ "$enabled_rows" -eq 0 ] && [ "$disabled_rows" -eq 0 ]; then
            project_manifest_fail=$((project_manifest_fail + 1))
            red "   ❌ 项目工具清单：$project_basename 没有启用或禁用行"
        fi
    done

    if [ "$project_manifest_count" -eq 0 ]; then
        project_manifest_fail=$((project_manifest_fail + 1))
        red "   ❌ 项目工具清单：未发现任何清单文件"
    fi

    if [ "$project_manifest_fail" -eq 0 ]; then
        green "✅ 项目工具清单：内联摘要与注册表一致"
        PASS=$((PASS + 1))
    else
        FAIL=$((FAIL + 1))
    fi
else
    red "❌ 项目工具清单目录不存在：$project_manifest_dir"
    FAIL=$((FAIL + 1))
fi

# ── 检查 16：配置模板 / CHANGELOG / secrets example 合规 ───
echo ""
echo "=== 检查 16：配置模板 / CHANGELOG / secrets example 合规 ==="

mcp_template_fail=0

for required in \
    "$ROOT/MCP/配置模板/claude.mcp.json.example" \
    "$ROOT/MCP/配置模板/codex.mcp.toml.example" \
    "$ROOT/MCP/密钥模板/mcp-secrets.env.example" \
    "$ROOT/MCP/CHANGELOG.md"
do
    if [ ! -f "$required" ]; then
        mcp_template_fail=$((mcp_template_fail + 1))
        red "   ❌ MCP 合规：文件不存在 → ${required#"$ROOT/"}"
    fi
done

if [ -f "$ROOT/MCP/配置模板/claude.mcp.json.example" ]; then
    if ! grep -q '"mcpServers"' "$ROOT/MCP/配置模板/claude.mcp.json.example"; then
        mcp_template_fail=$((mcp_template_fail + 1))
        red "   ❌ MCP 合规：claude.mcp.json.example 缺少 mcpServers"
    fi
    if command -v python3 >/dev/null 2>&1; then
        if ! python3 -m json.tool "$ROOT/MCP/配置模板/claude.mcp.json.example" >/dev/null 2>&1; then
            mcp_template_fail=$((mcp_template_fail + 1))
            red "   ❌ MCP 合规：claude.mcp.json.example 不是有效 JSON"
        fi
    fi
fi

if [ -f "$ROOT/MCP/配置模板/codex.mcp.toml.example" ]; then
    if ! grep -q '^\[mcp_servers\.' "$ROOT/MCP/配置模板/codex.mcp.toml.example"; then
        mcp_template_fail=$((mcp_template_fail + 1))
        red "   ❌ MCP 合规：codex.mcp.toml.example 缺少 [mcp_servers.<mcp_id>] 段"
    fi
    if command -v python3 >/dev/null 2>&1; then
        if ! python3 - <<'PY' "$ROOT/MCP/配置模板/codex.mcp.toml.example" >/dev/null 2>&1
import pathlib
import sys

try:
    import tomllib
except ModuleNotFoundError:
    sys.exit(0)

path = pathlib.Path(sys.argv[1])
tomllib.loads(path.read_text(encoding="utf-8"))
PY
        then
            mcp_template_fail=$((mcp_template_fail + 1))
            red "   ❌ MCP 合规：codex.mcp.toml.example 不是有效 TOML"
        fi
    fi
fi

secret_pattern='(ghp_[A-Za-z0-9]{20,}|github_pat_[A-Za-z0-9_]{20,}|sk-[A-Za-z0-9]{20,}|AIza[0-9A-Za-z_-]{20,}|AKIA[0-9A-Z]{16}|xox[baprs]-[A-Za-z0-9-]{10,})'
secret_hits=$(grep -R -n -E "$secret_pattern" "$ROOT/MCP" "$ROOT/CLI" "$ROOT/工具注册表.md" "$ROOT/项目工具清单" 2>/dev/null || true)
if [ -n "$secret_hits" ]; then
    mcp_template_fail=$((mcp_template_fail + 1))
    red "   ❌ MCP 合规：发现疑似真实密钥"
    echo "$secret_hits" | while IFS= read -r hit; do
        [ -n "$hit" ] && red "      - $hit"
    done
fi

if [ -f "$mcp_registry" ] && [ -f "$ROOT/MCP/密钥模板/mcp-secrets.env.example" ]; then
    while IFS= read -r line || [ -n "$line" ]; do
        if is_md_table_row "$line" && ! is_md_table_separator "$line"; then
            mcp_id=$(md_table_cell "$line" 2)
            tool_type_col=$(md_table_cell "$line" 3)

            case "$mcp_id" in
                tool_id|mcp_id|MCP_ID|编号) continue ;;
            esac

            [ -z "$mcp_id" ] && continue

            # 只检查 mcp 类型的密钥键（列 11）；cli 和 plugin 无密钥字段
            case "$tool_type_col" in
                mcp) ;;
                *) continue ;;
            esac

            secret_key=$(md_table_cell "$line" 11)
            case "$secret_key" in
                ""|none|—) continue ;;
            esac

            if ! grep -Eq "^${secret_key}=" "$ROOT/MCP/密钥模板/mcp-secrets.env.example"; then
                mcp_template_fail=$((mcp_template_fail + 1))
                red "   ❌ MCP 合规：密钥模板缺少 $mcp_id 所需键 → $secret_key"
            fi
        fi
    done < "$mcp_registry"
fi

if [ "$mcp_template_fail" -eq 0 ]; then
    green "✅ MCP 合规：模板、CHANGELOG 与密钥示例符合要求"
    PASS=$((PASS + 1))
else
    FAIL=$((FAIL + 1))
fi

# ── 汇总 ────────────────────────────────────────────────
echo ""
echo "================================"
echo "检查完成：✅ ${PASS} 通过  ⚠️ ${WARN} 提醒  ❌ ${FAIL} 失败"
echo "================================"

exit $FAIL
