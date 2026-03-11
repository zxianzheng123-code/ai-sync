---
name: ai-sync-pipeline
description: 流水线指挥中心。支持两种模式：① 流水线推进（扫描进度 → 路由到下一阶段）；② 运维操作（troubleshoot/refactor/optimize/test，可指定节点作用域）。用户只需记住这一个入口。
---

# 流水线指挥中心（Pipeline Command Center）

## TL;DR
- 流水线模式：用户说"继续" → 扫描进度 → 路由到下一阶段
- 运维模式：用户说"修/重构/优化/测试 [节点] [描述]" → 路由到对应 ops SKILL
- 性质：调度器——自身不产出交付物
- 关键卖点：一个入口搞定一切

## Goal
用户不需要记 skill 名字。流水线推进说"继续"，运维操作说动词 + 目标。自动判断模式、路由到对应 SKILL.md 并执行。

## 角色设定

**执行层**：
- [Pipeline] Lead 路由调度员。根据产物状态判断当前阶段，路由到对应 SKILL.md 执行。

**审查层**：
- [Progress Auditor] 进度审查官：校验阶段判断是否正确——产物检查是否遗漏、discovery 是否优先处理、路由目标是否匹配。

**业务层**：
- **客户经理**：用大白话告知用户当前进度和即将执行的阶段。
- **项目经理**：校验产物完整性，判断阶段状态，确保路由正确。对项目负总责。

## Strict Rules
1. **本 skill 不产出任何交付物**——交付物由被路由到的阶段/ops skill 产出。
2. **不跳阶段**——流水线模式严格按拓扑顺序。
3. **不并行**——同一对话只执行 1 个阶段或 1 个 ops。
4. **忠于原 skill**——路由后，100% 按目标 SKILL.md 执行。
5. **discovery 优先**——扫描到待处理 discovery 时，必须优先处理。
6. **ops 命令优先**——用户输入含运维关键词时，走 ops 路由，不走流水线。

## Workflow

### Step 0: 摄入关卡（项目经理执行，不面向用户）
动作：
- 读取 `dependency_map.md`（产物一览表 + 依赖方向）。
- 确认 `amendment_protocol.md` 和 `cascade_protocol.md` 存在（各阶段 skill 运行时需要）。
- 附件齐全 → 进入 Step 1。
- 附件缺失 → 暂停，告知用户。

### Step 1: 命令解析与模式分流

**先判断用户意图是 ops 操作还是流水线推进：**

#### 1a. Ops 命令识别

| 关键词 | 路由目标 |
|--------|----------|
| "修" / "debug" / "fix" / "排查" | `ops/troubleshoot/` |
| "重构" / "refactor" | `ops/refactor/` |
| "优化" / "optimize" | `ops/optimize/` |
| "测试" / "写测试" / "test" | `ops/test/` |

命中 ops 关键词后，解析**节点作用域**：
- 用户指定了节点编号（如"修 7 的 XX"）→ scope = 该节点
- 未指定 → scope = 全局，ops SKILL 自行定位

→ 路由到 `ops/<操作>/SKILL.md`，注入 scope 信息。

#### 1b. 流水线推进（未命中 ops 关键词时）

扫描 `design/` 和 `design/_discovery/` 目录，按以下优先级判断：

| 优先级 | 检查条件 | 结论 |
|--------|---------|------|
| 1 | `design/_discovery/` 存在 `discovery_to_*.md` | → ① 从文件名提取 `<产物基名>`（如 `discovery_to_infra_spec.md` → `infra_spec`）；② 查 `dependency_map.md` 产物一览表，找到该产物的**生产节点**编号；③ 路由到该编号对应的阶段 SKILL.md。该阶段 Step 1 / A0 自动检测到同名 discovery 文件，命中修订模式（A0→A5） |
| 2 | `design/2+4_project_context.md` 不存在 | → 路由到 `stages/1-biz-context-compressor/` |
| 3 | `design/3+5+6a+6b_layout_blueprint.md` 或 `design/3+6a+6b_style_guidebook.pen` 不存在 | → 路由到 `stages/2-ui-blueprint-master/` |
| 4 | `design/5+6a+6b_static_ui_mock.pen` 不存在 | → 路由到 `stages/3-static-ui-mock-master/` |
| 5 | `infra_spec.md`（项目根目录）不存在 | → 路由到 `stages/4-env-infra-spec/` |
| 6 | `design/6a_interaction_map.md` 不存在 | → 路由到 `stages/5-dynamic-ui-interaction/` |
| 7 | `design/6b+6c+7_code_blueprint.md` 或 `design/6b+6c_code_blueprint.md` 不存在 | → 路由到 `stages/6a-page-code-blueprint/` |
| 8 | 6a 已完成但仍有未编码页面 | → 路由到 `stages/6b-page-code-writer/` |
| 9 | 所有页面已编码但未集成 | → 路由到 `stages/6c-app-integration/` |
| 10 | 6c 已完成 + `infra_spec.md` 中 `deployment_model = full-stack` + 后端代码未完成 | → 路由到 `stages/7-backend-code-writer/` |
| 11 | 后端已完成（或 static-only）+ `design/8b_deploy_blueprint.md` 不存在 | → 路由到 `stages/8a-deploy-blueprint/` |
| 12 | 部署方案已完成但未部署 | → 路由到 `stages/8b-deploy-executor/` |
| 13 | 已部署但未验收 | → 路由到 `stages/9-acceptance-launch/` |
| 14 | 全部完成 | → 告知用户流水线已全部完成 |

若用户指定了具体阶段（如"跑 3"），跳过自动判断，直接路由。但仍需检查前置产物是否就位。

### Step 2: 汇报并确认（客户经理执行，面向用户）
告知用户当前进度和即将执行的阶段：

> 老板，当前进度：
> ✅ 1 业务上下文
> ✅ 2 布局蓝图 + 风格册
> ⬜ 3 静态高保真稿 ← 现在要做这个
> ⬜ 4 技术底座
> ⬜ 5 交互原型
> ⬜ 6 前端编码 + 集成
> ⬜ 7 后端编码（仅 full-stack）
> ⬜ 8 部署上线
> ⬜ 9 验收签收
>
> 开始吗？（回复：开始 / 我要先跑别的：xxx）

### Step 3: 路由执行
动作：
1. 读取目标阶段的 SKILL.md（路径按 Step 1 表格中的目录）。
2. **从该 SKILL.md 的 Step 0 开始执行**，完整走完该 skill 的全部 Workflow。
3. 执行过程中 100% 遵守目标 skill 的 Strict Rules、互撕规则、三签门禁。

### Step 4: 交付后级联
动作：
- 被路由阶段 skill 的 Workflow 末尾已包含交付后级联逻辑（读取 `cascade_protocol.md`）。
- 阶段 skill 执行完毕后，回到本 skill。
- [客户经理] 告知用户：

> 老板，[阶段名] 已完成！下次开新对话继续调我就行，我会自动接上下一步。

## Amendment Slots

| 槽位 | 值 |
|------|-----|
| `target` | N/A（本 skill 无交付物，交付物由各阶段 skill 产出） |
| `probe` | "想跑哪个阶段？""要改之前做好的哪个部分？" |
| `verify` | Step 1（扫描进度与模式分流） |
| `hooks` | （无） |

## Initialization
现在立刻执行 Step 0。
