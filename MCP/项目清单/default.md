# default 项目清单

> 统一根路径：`/Users/zxz/Desktop/ai-sync/`

## 基本信息

| 字段 | 值 |
| --- | --- |
| project_id | default |
| 项目名 | 全局默认集 |
| path_hint | `MCP/项目清单/default.md` |
| source | registry |

## 启用表

| mcp_id | version | 用途摘要 | 模板文件 | 密钥键 | 可用性检查 |
| --- | --- | --- | --- | --- | --- |
| pencil | 1.0.0 | 本地原型和界面截图能力 | `MCP/配置模板/claude.mcp.json.example;MCP/配置模板/codex.mcp.toml.example` | none | `command:/Applications/Pencil.app/Contents/Resources/app.asar.unpacked/out/mcp-server-darwin-arm64 --app desktop` |
| playwright | 1.0.0 | 浏览器自动化与页面操作 | `MCP/配置模板/claude.mcp.json.example;MCP/配置模板/codex.mcp.toml.example` | none | `command:npx @playwright/mcp@latest` |
| openai-developer-docs | 1.0.0 | 官方文档上下文读取 | `MCP/配置模板/codex.mcp.toml.example` | none | `http:https://developers.openai.com/mcp` |

## 禁用表

| mcp_id | 禁用原因 |
| --- | --- |
