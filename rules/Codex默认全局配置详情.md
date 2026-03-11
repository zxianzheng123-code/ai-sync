# Codex 默认全局配置详情

## 1. 文档定位

| 项 | 内容 |
| --- | --- |
| 文档定位 | 记录 Codex 全局默认配置的真源口径 |
| 使用对象 | 本项目构建者 |
| 文档范围 | 只记录本机当前可识别的 Codex 全局配置项与 feature 开关 |
| 不包含 | 不展开具体项目业务规则；不替代 `AGENTS.md`；不替代官方发布说明 |
| 采集时间 | 2026-03-11 |
| 采集来源 | `~/.codex/config.toml`、`codex features list` |

## 2. 当前全局默认配置

| 配置项 | 当前值 | 作用 |
| --- | --- | --- |
| `model` | `gpt-5.4` | 默认模型 |
| `model_reasoning_effort` | `high` | 默认推理强度 |
| `model_context_window` | `1050000` | 默认上下文窗口上限 |
| `model_auto_compact_token_limit` | `997500` | 自动压缩上下文的阈值 |
| `personality` | `pragmatic` | 默认交互风格 |
| `service_tier` | `fast` | 默认服务档位 |

## 3. 当前项目目录信任配置

| 路径 | 当前值 | 作用 |
| --- | --- | --- |
| `/Users/zxz/Desktop/ai-sync` | `trusted` | 允许在该项目下更主动执行 |
| `/Users/zxz` | `trusted` | 允许在该工作区下更主动执行 |
| `/Users/zxz/Desktop/供应链记账系统` | `trusted` | 允许在该项目下更主动执行 |

## 4. 当前 MCP 服务配置

| 服务 | 当前配置 | 作用 |
| --- | --- | --- |
| `playwright` | `npx @playwright/mcp@latest` | 浏览器自动化 |
| `pencil` | `/Applications/Pencil.app/Contents/Resources/app.asar.unpacked/out/mcp-server-darwin-arm64 --app desktop` | `.pen` 设计文件编辑与读取 |

## 5. 当前界面与连接器配置

| 配置项 | 当前值 | 作用 |
| --- | --- | --- |
| `tui.theme` | `1337` | 终端界面主题 |
| `apps.connector_2128aebfecb84f64a069897515042a44.enabled` | `false` | 连接器未启用 |
| `apps.connector_76869538009648d5b282a4bb21c3d157.enabled` | `false` | 连接器未启用 |
| `apps.connector_68df33b1a2d081918778431a9cfca8ba.enabled` | `false` | 连接器未启用 |

## 6. Feature 开关总表

| 开关 | 阶段 | 当前状态 | 说明 |
| --- | --- | --- | --- |
| `apply_patch_freeform` | under development | `true` | 启用 freeform 形式的 `apply_patch` |
| `apps` | experimental | `true` | 启用应用连接能力 |
| `apps_mcp_gateway` | under development | `true` | 启用 apps 到 MCP 的网关能力 |
| `artifact` | under development | `true` | 启用 artifact 相关能力 |
| `child_agents_md` | under development | `true` | 启用子 agent 相关说明能力 |
| `codex_git_commit` | under development | `false` | Git 提交相关能力未启用 |
| `collaboration_modes` | removed | `true` | 已移除；保留项 |
| `default_mode_request_user_input` | under development | `false` | 默认模式下的结构化用户提问未启用 |
| `elevated_windows_sandbox` | removed | `false` | 已移除；不使用 |
| `enable_request_compression` | stable | `true` | 启用请求压缩 |
| `experimental_windows_sandbox` | removed | `false` | 已移除；不使用 |
| `fast_mode` | stable | `true` | 启用快速模式 |
| `image_detail_original` | under development | `false` | 原图细节模式未启用 |
| `image_generation` | under development | `true` | 启用图片生成能力 |
| `js_repl` | experimental | `true` | 启用 JavaScript REPL |
| `js_repl_tools_only` | under development | `false` | 工具限定型 JS REPL 未启用 |
| `memories` | under development | `true` | 启用记忆能力 |
| `multi_agent` | experimental | `true` | 启用多 agent 协作 |
| `personality` | stable | `true` | 启用 personality 配置 |
| `plugins` | under development | `false` | 插件能力未启用 |
| `powershell_utf8` | under development | `false` | PowerShell UTF-8 适配未启用 |
| `prevent_idle_sleep` | experimental | `true` | 防止运行时休眠 |
| `realtime_conversation` | under development | `false` | 实时对话能力未启用 |
| `remote_models` | removed | `false` | 已移除；不使用 |
| `request_permissions` | under development | `false` | 权限请求能力未启用 |
| `request_rule` | removed | `false` | 已移除；不使用 |
| `responses_websockets` | under development | `false` | Responses WebSocket 能力未启用 |
| `responses_websockets_v2` | under development | `false` | Responses WebSocket V2 能力未启用 |
| `runtime_metrics` | under development | `true` | 启用运行指标能力 |
| `search_tool` | removed | `false` | 已移除；不使用 |
| `shell_snapshot` | stable | `true` | 启用 shell 快照能力 |
| `shell_tool` | stable | `true` | 启用 shell 工具能力 |
| `shell_zsh_fork` | under development | `false` | zsh fork 能力未启用 |
| `skill_env_var_dependency_prompt` | under development | `false` | Skill 环境变量依赖提示未启用 |
| `skill_mcp_dependency_install` | stable | `true` | 启用 Skill 的 MCP 依赖安装能力 |
| `sqlite` | stable | `true` | 启用 sqlite 相关能力 |
| `steer` | removed | `true` | 已移除；保留项 |
| `undo` | stable | `true` | 启用撤销能力 |
| `unified_exec` | stable | `true` | 启用统一命令执行能力 |
| `use_linux_sandbox_bwrap` | under development | `false` | Linux bwrap 沙箱未启用 |
| `voice_transcription` | under development | `false` | 语音转写未启用 |
| `web_search_cached` | deprecated | `false` | 已废弃；不使用 |
| `web_search_request` | deprecated | `false` | 已废弃；不使用 |

## 7. 当前建议口径

| 类型 | 建议 |
| --- | --- |
| 稳定可长期保留 | `enable_request_compression`、`fast_mode`、`personality`、`shell_snapshot`、`shell_tool`、`skill_mcp_dependency_install`、`sqlite`、`undo`、`unified_exec` |
| 当前已启用且偏激进 | `apply_patch_freeform`、`apps`、`apps_mcp_gateway`、`artifact`、`child_agents_md`、`image_generation`、`js_repl`、`memories`、`multi_agent`、`prevent_idle_sleep`、`runtime_metrics` |
| 不建议主动启用 | 所有 `removed` 与 `deprecated` 项；以及当前未启用的 `under development` 项 |

## 8. 维护规则

| 规则 | 要求 |
| --- | --- |
| 真源规则 | 本文档只记录本机当前已识别到的配置与开关，不猜测未发现项 |
| 更新规则 | 每次调整 `~/.codex/config.toml` 或重新执行 `codex features list` 后同步更新 |
| 口径规则 | 配置名保留原始英文；说明、边界、建议使用中文 |
| 禁止事项 | 不把已移除或已废弃项写成可长期依赖能力 |
