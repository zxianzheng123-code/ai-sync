# AI-Sync Agent Instructions

## Skills

本项目包含以下可调用技能（Skills）。

现阶段这些 Skill 一律按**主动触发**处理，不采用被动触发。

也就是说：

- 用户明确点名 Skill，才触发。
- 用户给出非常明确、可直接等价映射到某个 Skill 的指令，才触发。
- 仅仅“语义相似”或“可能相关”，不触发。

一旦确认触发，**必须读取对应 SKILL.md 全文**，严格按其 Workflow 执行。

| Skill | 入口文件 | 触发场景 |
|-------|---------|---------|
| ai-sync-pipeline | `skills/ai-sync-pipeline/SKILL.md` | 用户说"继续"推进流水线，或说动词（修/重构/优化/测试）+ 目标触发运维 |
| playbook-author | `skills/ai-sync-playbook-author/SKILL.md` | 用户要求编写或修订 PLAYBOOK |
| skill-compiler | `skills/ai-sync-skill-compiler/SKILL.md` | 用户要求编写或修订 SKILL.md |
| clothing-image-commercializer | `skills/clothing-image-commercializer/SKILL.md` | 用户要求处理服装图片 |
| obsidian-markdown | `skills/obsidian-markdown/SKILL.md` | 用户处理 Obsidian Markdown、wikilink、callout、embed、frontmatter 或笔记结构 |
| obsidian-bases | `skills/obsidian-bases/SKILL.md` | 用户处理 `.base` 文件、表格视图、卡片视图、筛选或公式 |
| json-canvas | `skills/json-canvas/SKILL.md` | 用户处理 `.canvas` 文件、思维导图、流程图或 Obsidian Canvas |
| obsidian-cli | `skills/obsidian-cli/SKILL.md` | 用户要通过命令行操作 Obsidian vault，或调试插件、主题 |
| defuddle | `skills/defuddle/SKILL.md` | 用户给网页 URL，希望提取干净正文再阅读、分析或整理 |
| task-engine | `skills/task-engine/SKILL.md` | 任务不映射到任何现有专项 Skill，且需要多步骤规划执行时触发 |

### Skill 调用规则

1. **主动触发优先**：默认不自动命中 Skill；必须由用户明确点名，或由用户给出可直接映射的明确指令后才触发。
2. **先读后做**：一旦触发，完整读取 SKILL.md，不可跳读或假设内容。
3. **忠于原文**：100% 按 SKILL.md 中的 Workflow、Strict Rules 执行，不擅自增减步骤。
4. **Skill 内自包含**：每个 Skill 的附属文件（playbook、protocol 等）在其同级目录下，按 SKILL.md 指引读取。

## Project Structure

```
ai-sync/
├── README.md                # 仓库级说明
├── AGENTS.md                # Skill 索引与触发规则
├── rules/                   # 全局规则
│   └── *.md
├── skills/                  # 所有 Skill 定义，保持扁平
│   └── <skill-name>/
│       ├── SKILL.md
│       ├── references/
│       ├── scripts/
│       └── assets/
└── <repo-level-docs>.md     # 少量仓库级文档
```

<!-- ai-sync-skills -->
## Skills

执行任务前先判断用户是否在**主动触发**某个 Skill。

主动触发成立后，**必须读取对应 SKILL.md 全文**，严格按其 Workflow 执行。

| Skill | 入口 | 说明 |
|-------|------|------|
| ai-sync-pipeline | `skills/ai-sync-pipeline/SKILL.md` | 流水线指挥中心。支持两种模式：① 流水线推进（扫描进度 → 路由到下一阶段）；② 运维操作（troubleshoot/refactor/optimize/test，可指定节点作用域）。用户只需记住这一个入口。 |
| ai-sync-playbook-author | `skills/ai-sync-playbook-author/SKILL.md` | 通过结构化提问，从客户口述中提炼出一份完整的 PLAYBOOK。不预设 PLAYBOOK 的主题或结构，运行时动态发现并适配。 |
| ai-sync-skill-compiler | `skills/ai-sync-skill-compiler/SKILL.md` | SKILL 编写专家。以 PLAYBOOK 为参考书，通过结构化提问 + 三审互撕，新建或修订完全合规的 SKILL.md。 |
| clothing-image-commercializer | `skills/clothing-image-commercializer/SKILL.md` | 全自动批量处理服装平铺照片，输出电商级纯白底商品图。读取输入文件夹中的随手拍服装照片，经去背景、清晰化、校色、姿态整理、居中构图、缩放后输出到目标文件夹。 |
| obsidian-markdown | `skills/obsidian-markdown/SKILL.md` | 创建和编辑 Obsidian Flavored Markdown，支持 wikilink、embed、callout、frontmatter、tags 等 Obsidian 扩展语法。 |
| obsidian-bases | `skills/obsidian-bases/SKILL.md` | 创建和编辑 Obsidian Bases（`.base`），支持视图、过滤器、公式和汇总。 |
| json-canvas | `skills/json-canvas/SKILL.md` | 创建和编辑 JSON Canvas（`.canvas`），支持节点、连线、分组和布局。 |
| obsidian-cli | `skills/obsidian-cli/SKILL.md` | 通过 Obsidian CLI 与 vault 交互，也支持插件和主题开发调试。 |
| defuddle | `skills/defuddle/SKILL.md` | 用 Defuddle CLI 从网页提取干净的 Markdown 正文，减少 token 消耗。 |
| task-engine | `skills/task-engine/SKILL.md` | 通用任务执行引擎。输入任意任务 → 理解 → 规划 → 分派 → 执行 → 汇总 → 检查 → 循环至完成。适用于不依赖特定领域 Skill 的开放式任务。 |

### 调用规则
1. **默认不被动触发**：不因模糊相关、语义相似或“看起来能用”而自动启用 Skill。
2. **主动触发后再执行**：用户点名 Skill，或给出足够明确的动作指令后，再读取并执行。
3. **先读后做**：完整读取 SKILL.md，不可跳读。
4. **忠于原文**：100% 按 Workflow / Strict Rules 执行。
5. **自包含**：附属文件在 skill 同级目录下。
<!-- ai-sync-skills -->

<!-- ai-sync-rules -->
## Global Rules

以下全局规则适用于本项目所有操作，**必须在每次任务开始前阅读并遵守**。

- `rules/通用文档写作规则.md` — 通用文档写作规则

请先读取 `rules/` 目录下的所有 .md 文件，理解并遵守其中的规则。
<!-- ai-sync-rules -->
