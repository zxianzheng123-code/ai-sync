# Codex与Claude Code最佳使用实践

## 文档定义

| 字段 | 内容 |
| --- | --- |
| 文档定位 | 基于 OpenAI 与 Anthropic 官方文档，整理 `Codex` 与 `Claude Code` 的落地使用实践、选型建议与统一执行模板 |
| 文档范围 | 只覆盖任务输入、计划方式、持久规则、验证闭环、权限安全、并行协作、重复工作沉淀 |
| 不含内容 | 不做模型能力排名；不讨论价格；不收录社区传闻式技巧 |
| 更新时间 | 2026-03-14 |
| 一句话结论 | 两者都应被当作“可配置的工程代理”，不是“聊一句就完”的聊天助手 |

## 总结论

| 场景                | 优先选择          | 原因                                                    | 起手动作                                |
| ----------------- | ------------- | ----------------------------------------------------- | ----------------------------------- |
| 日常本地开发            | 两者都可          | 核心差异不在模型，而在你是否给清楚任务边界、验证方式和权限边界                       | 先写清 `目标 / 上下文 / 约束 / 完成标准 / 验证方式`   |
| 多任务并行、后台长任务、周期性维护 | `Codex`       | 官方工作流更强调 `Skills + Automations + 多线程 / 多 agent` 的组合   | 先把高频工作做成 `Skill`，稳定后再上 `Automation` |
| 终端主场、强权限控制、强流程钩子  | `Claude Code` | 官方工作流更强调 `Plan Mode + hooks + worktree + permissions` | 默认从 `Plan Mode` 和严格权限开始             |
| 高安全或含不可信内容的仓库     | 两者都可，但先收紧权限   | 官方都明确提醒：网络、脚本、外部上下文是主要风险面                             | 默认只读或受限写入，按需放开                      |

## 共通最佳实践

| 对象     | 官方共识                     | 直接做法                             |
| ------ | ------------------------ | -------------------------------- |
| 任务输入   | 输入越像工单，结果越稳定             | 每次都给出 `目标 / 上下文 / 约束 / 完成标准`     |
| 复杂任务   | 先探索和计划，再实现               | 多文件、多阶段、需求模糊时，先要求只做计划            |
| 验证闭环   | Agent 必须能自验，否则你会变成唯一反馈回路 | 明确给测试命令、截图对照、预期输出、复现步骤           |
| 持久规则   | 长期规则不能反复手打               | 仓库内维护共享规则文件，不把长期规则塞进每次 prompt    |
| 外部实时信息 | 不要长期靠复制粘贴                | 用 `MCP` 连接 issue、文档、数据库、设计稿、监控系统 |
| 重复工作   | 重复三次以上就该沉淀               | 固化成 `Skill / 命令 / 自动化`，不要继续人工重说  |
| 权限安全   | 默认先紧后松                   | 先用只读或受限写入，确认可信后再放开网络与高权限命令       |
| 会话管理   | 上下文膨胀会直接拉低质量             | 一个任务一个线程；分叉工作单独开线程或 worktree     |

## 工具能力怎么分配

| 需求        | Codex                           | Claude Code                      | 使用原则                       |
| --------- | ------------------------------- | -------------------------------- | -------------------------- |
| 仓库共享规则    | `AGENTS.md`                     | `CLAUDE.md`                      | 只写长期有效、团队共享、可验证的规则         |
| 细分规则      | 更细目录下继续放 `AGENTS.md`，或主文件引用专题文档 | `.claude/rules/` 或分层 `CLAUDE.md` | 规则靠近对象，避免一份大总表吃掉全部上下文      |
| 外部上下文     | `MCP`                           | `MCP`                            | 只接真正能减少人工回填的系统             |
| 可复用方法     | `Skills`                        | `Skills`                         | 一个技能只做一件事，输入输出要清楚          |
| 周期执行      | `Automations`                   | `claude -p` + CI / cron / 脚本     | `方法` 先稳定，再做 `调度`           |
| 必须强制发生的动作 | 依赖配置、审批、规则与外部流程约束               | `hooks`                          | 只是“希望它记住”时写规则；“必须每次发生”时上钩子 |
| 隔离并行工作    | 多 agent / worktree              | subagents / worktree             | 有冲突风险的并行修改不要共享同一工作树        |

## Codex最佳实践

| 主题        | 推荐做法                                                      | 含义                                                                    |
| --------- | --------------------------------------------------------- | --------------------------------------------------------------------- |
| 起手 prompt | 默认给 `目标 / 上下文 / 约束 / 完成标准` 四段                             | 这是 OpenAI 官方给出的默认结构，能显著减少跑偏                                           |
| 复杂任务      | 先开 `Plan mode` 或先让 Codex 反问你                              | 需求模糊时，先把问题问清楚比直接编码更重要                                                 |
| 仓库规则      | 把长期规则写进 `AGENTS.md`                                       | `AGENTS.md` 适合写目录结构、构建命令、测试命令、禁做事项、完成定义                               |
| 规则长度      | `AGENTS.md` 短而准                                           | 官方明确建议保持实用，规则过长会稀释真正重要的要求                                             |
| 配置位置      | 个人默认写进 `~/.codex/config.toml`；仓库默认写进 `.codex/config.toml` | 把“个人习惯”和“仓库共识”分层，不要混写                                                 |
| 验证闭环      | 要求 Codex 补测试、跑检查、确认行为、做 diff review                       | OpenAI 明确建议把“改代码、验代码、审代码”合成一个闭环                                       |
| Review    | 用 `/review` 做 PR 式检查、未提交变更检查、提交检查                         | 把 review 变成固定动作，而不是上线前才想起来                                            |
| 外部系统      | 用 `MCP` 取代复制粘贴                                            | 实时数据、频繁变化的数据、跨项目共用的数据都更适合 MCP                                         |
| 重复工作      | 先做 `Skill`，后做 `Automation`                                | 官方原话的核心就是：`Skills define the method, automations define the schedule` |
| 会话管理      | 一个任务一个线程；分叉时 `/fork`；长线程用 `/compact`；并行时用 `/agent`        | 官方明确反对“一个项目只保留一条巨长线程”                                                 |
| 权限策略      | 默认从受限权限开始，可信仓库再逐步放开                                       | 官方建议对新手或新仓库先紧后松，避免一开始就全权限                                             |
| 典型适用场景    | 后台跑任务、周期分析、并行子任务、PR review、长链路研发                          | Codex 的优势更偏“流程化、并行化、后台化”                                              |

## Claude Code最佳实践

| 主题 | 推荐做法 | 含义 |
| --- | --- | --- |
| 第一原则 | 先给 Claude 一个自验方式 | Anthropic 明确说这是最高杠杆动作；没有验证标准，你就会变成唯一 QA |
| 推荐流程 | `Explore -> Plan -> Code -> Verify` | 先读代码和问问题，再实现，避免把错误问题做对 |
| 计划模式 | 复杂任务默认先用 `Plan Mode` | 多文件改动、代码库探索、方向不确定时最适合 |
| prompt 上下文 | 优先给具体文件、日志、截图、URL、`@文件` 引用、管道输入 | Claude 官方明确鼓励“让它自己取上下文”，而不是你手写长解释 |
| 仓库规则 | 规则写进 `CLAUDE.md` | 适合写构建命令、测试偏好、代码风格、命名约定、仓库礼仪 |
| 规则长度 | 单个 `CLAUDE.md` 目标控制在 200 行内，超出就拆分 | 官方明确提醒：文件过长会消耗上下文并降低遵循度 |
| 规则分层 | 全局规则、项目规则、子目录规则按范围叠加 | 共享规则放项目内；个人偏好放 `~/.claude/CLAUDE.md` |
| 规则与记忆分工 | 团队规则放 `CLAUDE.md`；经验沉淀可交给 auto memory | 官方明确说 auto memory 是上下文补充，不是团队规范真源 |
| 强制动作 | 需要“零例外执行”的动作写成 `hooks` | Anthropic 明确区分：`CLAUDE.md` 是建议性，`hooks` 是确定性 |
| 外部系统 | 优先用 CLI 工具和 `MCP` | `gh`、云平台 CLI、监控 CLI、数据库工具都比大段复制更省上下文 |
| 并行隔离 | 并行会话优先用 `--worktree`；高噪音调查优先用 subagent | 官方明确推荐 worktree 解决并行冲突，subagent 解决上下文污染 |
| subagent 使用边界 | 自包含、输出冗长、需要独立权限的任务才用 subagent | 快速修改、强依赖主线程上下文的任务，不必额外拆 agent |
| 非交互执行 | 需要脚本化、CI、批量检查时用 `claude -p` | 适合接 shell 脚本、验证流水线、定时任务 |
| 权限策略 | 默认严格只读；按命令和路径做 allow / ask / deny | Anthropic 官方把权限系统、sandbox、敏感文件 deny 列为核心配置 |
| 不可信内容 | 不要把不可信内容直接 pipe 进 Claude；敏感仓库建议 VM / sandbox | 这是 Anthropic 安全文档的明确提醒 |

## 推荐默认操作法

| 阶段 | 统一动作 | Codex写法 | Claude Code写法 |
| --- | --- | --- | --- |
| 1. 定义任务 | 先说清边界 | `目标 / 上下文 / 约束 / 完成标准` | `目标 / 相关文件 / 验证方式 / 风险边界` |
| 2. 先做计划 | 复杂任务先不改代码 | `先进入 Plan mode，只做分析和计划` | `先用 Plan Mode，不要改文件` |
| 3. 让工具取上下文 | 少手抄，多引用 | `@文件`、`MCP`、错误日志 | `@文件`、截图、URL、管道输入、CLI |
| 4. 执行与自验 | 改完必须验证 | `补测试并跑检查，再 /review` | `跑测试 / 截图比对 / 输出校验` |
| 5. 固化经验 | 重复问题沉淀为规则 | 更新 `AGENTS.md` / Skill / Automation | 更新 `CLAUDE.md` / rules / hooks / Skill |

## 统一任务模板

```text
目标：
要实现什么变化，或要解决什么问题。

上下文：
相关文件、目录、报错、截图、文档、接口、页面入口。

约束：
必须遵守的架构、命名、权限、安全、性能、兼容性要求。

完成标准：
改完以后什么必须成立。

验证方式：
要跑哪些测试、命令、截图对照、输出检查。

执行要求：
如果任务复杂，先只做计划，不要直接改代码。
如果涉及高风险文件，先给风险点，再执行。
```

## 常见误区

| 误区 | 后果 | 修正 |
| --- | --- | --- |
| 把 agent 当聊天助手 | 输出像建议，不像交付 | 任务写成工单，不写成闲聊 |
| 只说“帮我改一下” | Agent 自己补假设，容易跑偏 | 把完成标准和验证方式写出来 |
| 复杂任务一上来就让它写 | 很可能把错问题做对 | 先探索和计划 |
| 把长期规则反复塞进 prompt | 上下文浪费，规则不稳定 | 迁到 `AGENTS.md` 或 `CLAUDE.md` |
| 规则文件越写越长 | 真正重要的规则被淹没 | 只保留高频、长期、可验证规则 |
| 重复任务一直人工重说 | 输出波动大，成本高 | 固化为 `Skill`、`hook`、`Automation` 或脚本 |
| 并行修改共用一个工作树 | 冲突多、回滚难 | 改用 worktree 或隔离线程 |
| 对不可信内容直接放开网络与脚本 | 提高提示注入和误执行风险 | 默认收紧权限，按需放开 |

## 官方来源

### OpenAI / Codex

| 文档 | 链接 | 本文主要使用点 |
| --- | --- | --- |
| Codex Best Practices | https://developers.openai.com/codex/learn/best-practices | prompt 四段式、Plan mode、AGENTS.md、testing/review、MCP、Skills、Automations、线程管理 |
| AGENTS.md 指南 | https://developers.openai.com/codex/guides/agents-md | 全局 / 仓库 / 子目录分层规则 |
| Agent approvals & security | https://developers.openai.com/codex/agent-approvals-security | sandbox、approval、网络与默认权限建议 |
| How OpenAI uses Codex | https://openai.com/business/guides-and-resources/how-openai-uses-codex/ | 背景任务、碎片时间协作、后台工作方式 |

### Anthropic / Claude Code

| 文档 | 链接 | 本文主要使用点 |
| --- | --- | --- |
| Claude Code Best Practices | https://code.claude.com/docs/en/best-practices | 自验优先、Explore/Plan/Code、CLAUDE.md、hooks、skills、subagents |
| Claude Code Common Workflows | https://code.claude.com/docs/en/common-workflows | Plan Mode、worktree、非交互执行、验证流程 |
| Claude Code Hooks | https://code.claude.com/docs/en/hooks | hooks 的触发边界、阻断能力、与规则文件的分工 |
| How Claude remembers your project | https://code.claude.com/docs/en/memory | `CLAUDE.md` 与 auto memory 的边界、分层与长度建议 |
| Claude Code Settings | https://code.claude.com/docs/en/settings | allow / ask / deny、敏感文件屏蔽、defaultMode |
| Claude Code Security | https://code.claude.com/docs/en/security | 默认只读、sandbox、提示注入、不可信内容处理 |
| Claude Code Subagents | https://code.claude.com/docs/en/sub-agents | subagent 与主线程边界、工具权限、隔离上下文 |
