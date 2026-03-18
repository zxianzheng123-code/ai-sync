# MCP 注册表

> 统一根路径：`/Users/zxz/Desktop/ai-sync/`

| mcp_id | version | status | 显示名 | 用途 | 适用客户端 | 连接方式 | 模板文件 | 密钥键 | 可用性检查类型 | 可用性检查目标 | 成功标志 | 默认启用 | 备注 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| pencil | 1.0.0 | active | Pencil | 本地原型和界面截图能力 | Claude Code / Codex | command | `MCP/配置模板/claude.mcp.json.example;MCP/配置模板/codex.mcp.toml.example` | none | command | `/Applications/Pencil.app/Contents/Resources/app.asar.unpacked/out/mcp-server-darwin-arm64 --app desktop` | 命令可解析 | 是 | 当前默认可用 |
| playwright | 1.0.0 | active | Playwright | 浏览器自动化与页面操作 | Claude Code / Codex | command | `MCP/配置模板/claude.mcp.json.example;MCP/配置模板/codex.mcp.toml.example` | none | command | `npx @playwright/mcp@latest` | 命令可解析 | 是 | 依赖 npm 可执行环境 |
| openai-developer-docs | 1.0.0 | active | OpenAI Developer Docs | 官方文档上下文读取 | Codex | url | `MCP/配置模板/codex.mcp.toml.example` | none | http | `https://developers.openai.com/mcp` | HTTP 2xx/3xx | 是 | 远程 MCP 入口 |
