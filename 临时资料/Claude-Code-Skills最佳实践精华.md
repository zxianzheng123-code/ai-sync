# Claude Code Skills 最佳实践精华

> 提取自 Thariq Shihipar (Anthropic) 的推文分享
> 原文：https://x.com/trq212/status/2033949937936085378
> 提取日期：2026-03-18

---

## 核心认知

Skills 不是"一个 markdown 文件"——它是一个**文件夹**，可以包含脚本、资产、数据等。Claude Code 启动时会构建所有可用 Skills 及其描述的清单，通过扫描这份清单判断请求是否有对应的 Skill。

Anthropic 内部有数百个 Skills 在活跃使用。

---

## 一、Skills 的 9 大类型

### 1. 库与 API 参考

解释如何正确使用某个库、CLI 或 SDK。可针对内部库，也可针对 Claude 偶尔犯错的常用库。通常包含**参考代码片段文件夹**和**踩坑点列表**。

示例：`billing-lib`（内部计费库边界情况）、`internal-platform-cli`（内部 CLI 子命令及场景）、`frontend-design`（改进设计系统理解）

### 2. 产品验证

描述如何测试或验证代码是否正常工作，通常搭配 Playwright、tmux 等外部工具。

> **值得安排一个工程师花上一周时间专门打磨你的验证 Skills。**

技巧：让 Claude 录制输出过程视频；在每步执行程序化状态断言。

示例：`signup-flow-driver`（无头浏览器注册流程测试）、`checkout-verifier`（Stripe 测试卡结账验证）、`tmux-cli-driver`（交互式命令行测试）

### 3. 数据获取与分析

连接数据和监控体系。可能包含带凭证的数据获取库、仪表盘 ID、常用工作流说明。

示例：`funnel-query`（转化漏斗关联事件查询）、`cohort-compare`（用户群对比留存率并标记统计显著差异）、`grafana`（数据源 UID 和集群配置）

### 4. 业务流程与团队自动化

把重复性工作流自动化为一条命令。指令通常简单，但可能依赖其他 Skills 或 MCP。

> **把之前的执行结果保存在日志文件中，有助于模型保持一致性并反思之前的执行情况。**

示例：`standup-post`（汇总任务和生成站会报告）、`create-ticket`（强制执行 schema 和创建后工作流）、`weekly-recap`（合并 PR、关闭工单和部署记录汇总）

### 5. 代码脚手架与模板

为代码库中的特定功能生成框架样板代码，在有自然语言需求、无法纯靠代码覆盖的场景中特别有用。

示例：`new-framework-workflow`（用注解搭建新服务）、`new-migration`（数据库迁移模板）、`create-app`（新建内部应用预配）

### 6. 代码质量与审查

在团队内部执行代码质量标准并辅助代码审查。可包含确定性脚本保证最大可靠性，可作为钩子自动运行或在 GitHub Action 中执行。

示例：`adversarial-review`（生成子智能体挑刺）、`code-style`（强制执行特定风格）、`testing-practices`（测试指导）

### 7. CI/CD 与部署

帮你拉取、推送和部署代码，可能引用其他 Skills 来收集数据。

示例：`babysit-pr`（监控 PR、重试 CI、解决冲突）、`deploy-service`（构建、冒烟测试、渐进式流量切换、自动回滚）、`cherry-pick-prod`（隔离工作树的 cherry-pick 流程）

### 8. 运维手册

接收一个现象（Slack 消息、告警、错误特征），引导走完多工具排查流程，最后生成结构化报告。

示例：`service-debugging`（现象对应到工具查询）、`oncall-runner`（告警检查和排查结论）、`log-correlator`（按请求 ID 拉取匹配日志）

### 9. 基础设施运维

执行日常维护和运维操作，部分涉及破坏性操作需要安全护栏。让工程师在执行关键操作时更容易遵循最佳实践。

示例：`resource-orphans`（找孤立 Pod/Volume 并级联清理）、`dependency-management`（依赖审批工作流）、`cost-investigation`（费用突增原因分析）

---

## 二、编写 Skills 的 9 条关键技巧

### 1. 不要说显而易见的事

Claude 对代码库和编程已经非常了解。如果你的 Skill 主要提供知识，**把重点放在能打破 Claude 常规思维模式的信息上**。

例如 `frontend-design` Skill 专门避免 Inter 字体和紫色渐变这些"典型套路"。

### 2. 建一个踩坑点（Gotchas）章节

> **任何 Skill 中信息量最大的部分就是踩坑点章节。**

根据 Claude 使用 Skill 时遇到的常见失败点逐步积累，持续更新。

### 3. 利用文件系统与渐进式披露

把整个文件系统当作上下文工程和渐进式披露的工具：

- 详细函数签名和用法示例拆分到 `references/api.md`
- 模板文件放在 `assets/` 中供复制使用
- 参考资料、脚本、示例等文件夹帮助 Claude 更高效工作
- **告诉 Claude 你的 Skill 里有哪些文件，它会在合适的时候去读取**

### 4. 不要把 Claude 限制太死

给 Claude 需要的信息，但**留给它适应具体情况的灵活性**。由于 Skills 复用性很强，指令写得太具体反而有害。

### 5. 考虑好初始设置

- 把设置信息存在 Skill 目录下的 `config.json`
- 如果配置没设置好，智能体会向用户询问
- 需要结构化多选时，让 Claude 使用 `AskUserQuestion` 工具

### 6. description 字段是给模型看的

description 字段**不是摘要——它描述的是何时该触发这个 Skill**。Claude 启动会话时扫描所有 Skill 描述来判断是否匹配请求。

### 7. 记忆与数据存储

- 用只追加写入的文本日志或 JSON 文件实现简单记忆
- 更复杂场景可用 SQLite
- 例如 `standup-post` 保留 `standups.log` 记录历史，下次运行时 Claude 会读取
- **数据应存在稳定文件夹中**（`${CLAUDE_PLUGIN_DATA}`），避免升级时被删

### 8. 存储脚本与生成代码

> **你能给 Claude 的最强大的工具之一就是代码。**

提供脚本和库，让 Claude 把精力花在组合编排上——决定下一步做什么，而不是重新构造样板代码。例如数据科学 Skill 中放一组数据获取函数库，Claude 即时生成脚本组合这些功能。

### 9. 按需钩子（On Demand Hooks）

Skills 可包含只在该 Skill 被调用时才激活的钩子，整个会话期间保持生效。适合主观性强、不想一直运行但有时极其有用的场景。

示例：
- `/careful` — 通过 PreToolUse 拦截 `rm -rf`、`DROP TABLE`、`force-push`、`kubectl delete`
- `/freeze` — 阻止对特定目录之外的任何 Edit/Write 操作

---

## 三、分发与管理策略

### 分发方式

1. **仓库内分发**：提交到 `./.claude/skills`，适合小团队
2. **插件市场**：搭建内部插件市场，让用户自己决定安装哪些

每个提交到仓库的 Skill 都会给模型上下文增加负担，规模扩大后应使用插件市场。

### 管理流程

- 不设专门中心团队，让最有用的 Skills **自然涌现**
- 新 Skill 先上传到 GitHub 沙盒文件夹，在 Slack 推荐
- 获得足够关注后，提交 PR 移到插件市场
- **正式发布前必须有审核机制**，防止质量差或重复的 Skills

### Skills 组合与依赖

目前不支持正式的依赖管理，但可以**按名字引用其他 Skills**，只要对方已安装，模型就会调用。

### 衡量效果

使用 `PreToolUse` 钩子在公司内部记录 Skill 使用情况，发现哪些受欢迎、哪些触发频率低于预期。
