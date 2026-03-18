#!/usr/bin/env bash
# MCP 运行时可用性检查
# 用法：bash scripts/check_mcp_runtime.sh <project_id> [--secrets-file PATH]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
REGISTRY_FILE="$ROOT/MCP/MCP注册表.md"
PROJECT_DIR="$ROOT/MCP/项目清单"
SECRETS_FILE="$HOME/.config/ai-sync/mcp-secrets.env"

PROJECT_ID=""
OVERALL_FAIL=0

usage() {
    cat <<'EOF'
用法：
  bash scripts/check_mcp_runtime.sh <project_id> [--secrets-file PATH]

示例：
  bash scripts/check_mcp_runtime.sh default
  bash scripts/check_mcp_runtime.sh my-project --secrets-file /tmp/mcp.env
EOF
}

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

result_line() {
    local level="$1"
    local target="$2"
    local message="$3"
    printf '[%s] %s - %s\n' "$level" "$target" "$message"
}

run_command_check() {
    local mcp_id="$1"
    local target="$2"
    local executable

    executable="${target%% *}"
    if [ -z "$executable" ]; then
        OVERALL_FAIL=1
        result_line "FAIL" "$mcp_id" "缺少 command 检查目标"
        return
    fi

    if [[ "$executable" = /* ]]; then
        if [ -x "$executable" ]; then
            result_line "PASS" "$mcp_id" "命令可执行：$executable"
        else
            OVERALL_FAIL=1
            result_line "FAIL" "$mcp_id" "命令不可执行：$executable"
        fi
    elif command -v "$executable" >/dev/null 2>&1; then
        result_line "PASS" "$mcp_id" "命令可解析：$executable"
    else
        OVERALL_FAIL=1
        result_line "FAIL" "$mcp_id" "命令不存在：$executable"
    fi
}

run_http_check() {
    local mcp_id="$1"
    local target="$2"
    local status_code

    if ! command -v curl >/dev/null 2>&1; then
        OVERALL_FAIL=1
        result_line "FAIL" "$mcp_id" "缺少 curl，无法做 HTTP 探活"
        return
    fi

    status_code=$(curl -sS -L -m 10 -o /dev/null -w '%{http_code}' "$target" || true)
    case "$status_code" in
        2??|3??|401|403|405)
            result_line "PASS" "$mcp_id" "HTTP 可访问：$target ($status_code)"
            ;;
        *)
            OVERALL_FAIL=1
            result_line "FAIL" "$mcp_id" "HTTP 不可用：$target ($status_code)"
            ;;
    esac
}

run_manual_check() {
    local mcp_id="$1"
    local target="$2"
    result_line "WARN" "$mcp_id" "需要人工检查：$target"
}

while [ $# -gt 0 ]; do
    case "$1" in
        --secrets-file)
            shift
            [ $# -gt 0 ] || { usage; exit 1; }
            SECRETS_FILE="$1"
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            if [ -z "$PROJECT_ID" ]; then
                PROJECT_ID="$1"
            else
                usage
                exit 1
            fi
            ;;
    esac
    shift
done

if [ -z "$PROJECT_ID" ]; then
    usage
    exit 1
fi

if [ ! -f "$REGISTRY_FILE" ]; then
    result_line "FAIL" "$PROJECT_ID" "注册表不存在：$REGISTRY_FILE"
    exit 1
fi

if [ -f "$SECRETS_FILE" ]; then
    set -a
    # shellcheck disable=SC1090
    . "$SECRETS_FILE"
    set +a
else
    result_line "WARN" "global" "密钥文件不存在：$SECRETS_FILE"
fi

MANIFEST_FILE="$PROJECT_DIR/$PROJECT_ID.md"
if [ ! -f "$MANIFEST_FILE" ]; then
    MANIFEST_FILE="$PROJECT_DIR/default.md"
    if [ -f "$MANIFEST_FILE" ]; then
        result_line "WARN" "$PROJECT_ID" "未找到专属清单，回退到 default"
    else
        result_line "FAIL" "$PROJECT_ID" "既没有专属清单，也没有 default 清单"
        exit 1
    fi
fi

CURRENT_SECTION=""
ENABLED_COUNT=0

while IFS= read -r line || [ -n "$line" ]; do
    case "$line" in
        *"启用表"*) CURRENT_SECTION="enabled" ;;
        *"禁用表"*) CURRENT_SECTION="disabled" ;;
    esac

    if [ "$CURRENT_SECTION" = "enabled" ] && is_md_table_row "$line" && ! is_md_table_separator "$line"; then
        mcp_id=$(md_table_cell "$line" 2)
        case "$mcp_id" in
            mcp_id|编号|"") continue ;;
        esac

        ENABLED_COUNT=$((ENABLED_COUNT + 1))

        secret_key=$(lookup_md_table_cell_by_id "$REGISTRY_FILE" "$mcp_id" 10 || true)
        check_type=$(lookup_md_table_cell_by_id "$REGISTRY_FILE" "$mcp_id" 11 || true)
        check_target=$(lookup_md_table_cell_by_id "$REGISTRY_FILE" "$mcp_id" 12 || true)

        if [ -z "$check_type" ] || [ -z "$check_target" ]; then
            OVERALL_FAIL=1
            result_line "FAIL" "$mcp_id" "注册表缺少可用性检查定义"
            continue
        fi

        case "$secret_key" in
            ""|none) ;;
            *)
                if [ -z "${!secret_key:-}" ]; then
                    OVERALL_FAIL=1
                    result_line "FAIL" "$mcp_id" "缺少密钥：$secret_key"
                    continue
                fi
                ;;
        esac

        case "$check_type" in
            command)
                run_command_check "$mcp_id" "$check_target"
                ;;
            http)
                run_http_check "$mcp_id" "$check_target"
                ;;
            manual)
                run_manual_check "$mcp_id" "$check_target"
                ;;
            *)
                OVERALL_FAIL=1
                result_line "FAIL" "$mcp_id" "不支持的检查类型：$check_type"
                ;;
        esac
    fi
done < "$MANIFEST_FILE"

if [ "$ENABLED_COUNT" -eq 0 ]; then
    OVERALL_FAIL=1
    result_line "FAIL" "$PROJECT_ID" "清单里没有启用项"
fi

exit "$OVERALL_FAIL"
