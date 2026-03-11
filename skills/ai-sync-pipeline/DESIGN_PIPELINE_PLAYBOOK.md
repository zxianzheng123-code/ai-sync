# 设计驱动型 AI 开发流水线 PLAYBOOK

> **谁用**：Skill Compiler（skill-compiler）读取本文件，编译出合规 SKILL.md。
> **定位**：编制权威 + 附件源。Skill Compiler 从正文提取编制原则，从附件提取运行时共享信息并生成独立文件。
> v4.0 | 2026-03-05

---

## 1 理念（Why）

六条信条，所有规则从此推导。

| # | 信条 | 一句话 |
|---|------|-------|
| 1 | 客户画像 | 技术小白，不做技术决策，只负责业务判断 |
| 2 | 大白话沟通 | 只问业务确认，技术决策专家内部互撕，结果用大白话解释 |
| 3 | 参考物不继承 | 参考物只"看"不"抄"，生产代码从干净骨架从零写 |
| 4 | 全链路回流 | 下游发现上游问题立即反向回流，正向 discovery 由下游自然拾取 |
| 5 | Golden Hammer | 统一技术栈，"够用且一致" > "最优但混杂" |
| 6 | Big Rewrite | 方向不对就推倒从零写。AI 写代码便宜，重写比 debug 干净 |

---

## 2 流水线（What）

### 2.1 拓扑

```
设计阶段：        1 ⇄ 2 ⇄ 3 ⇄ 4★ ⇄ 5 ⇄ 6a★
前端编码：        → 6b(循环) → 6c★
后端编码：        → 7(循环)
部署 & 验收：     → 8a → 8b → 9

⇄ = 正向 + 条件反向回流    → = 仅正向
★ = 相对 v3.3 有 full-stack 条件扩展

分叉逻辑（由 infra_spec.md 中 deployment_model 决定）：
  static-only → 6c 完成后跳到 8a（轻量静态部署）→ 8b → 9
  full-stack  → 6c → 7 → 8a → 8b → 9
```

### 2.2 各节点定位

> **参考** = 高质量但用完即弃，不进生产 · **🚩生产** = 从零写、结构干净、零技术债继承

| 节点 | Skill 目录名 | 性质 | 隐喻 | 核心职责 | 边界（不做什么） |
|------|-------------|------|------|---------|---------------|
| 主入口 | `ai-sync-pipeline` | 调度器 | 指挥中心 | 流水线推进 + 运维操作分流，路由到对应 skill 执行 | 不执行任何阶段/ops 逻辑 |
| 1 | `1-biz-context-compressor` | 参考 | 翻译器 | 口述 → 结构化业务真相 | 只谈业务，技术绝缘 |
| 2 | `2-ui-blueprint-master` | 参考 | 建筑设计师 | 业务 → 信息架构 + 视觉系统 | 蓝图管布局；风格册管视觉 |
| 3 | `3-static-ui-mock-master` | 参考 | 渲染师 | 蓝图 + 风格册 → 像素级静态稿 | 纯静态，无后端/交互 |
| 4★ | `4-env-infra-spec` | 🚩生产 | 工地总监 | 选型 + 打地基 + 写施工规定。full-stack 时含后端框架/DB/云平台选型 | 只输出底座，不写业务代码 |
| 5 | `5-dynamic-ui-interaction` | 参考 | 试驾教练 | 静态稿 → 可交互原型 + 技术侦察 | 原型用完即弃，不进生产 |
| 6a★ | `6a-page-code-blueprint` | 参考 | 图纸员 | 设计稿 → 代码级施工图。full-stack 时同时输出 API 契约 + DB schema | 零代码产出，只产图纸 |
| 6b | `6b-page-code-writer` | 🚩生产 | 砌墙工 | 照图纸逐页编码。full-stack 时用正式 API 接口层（挂 mock） | 禁抄 5 原型；蓝图有误先修再编 |
| 6c★ | `6c-app-integration` | 🚩生产 | 总装车间 | 独立页面 → 完整应用。full-stack 时含前后端联调验证 | 不新增页面，不改页内逻辑 |
| 7 | `7-backend-code-writer` | 🚩生产 | 后厨大厨 | 照蓝图写后端代码 + 前端 mock → 真实 API 替换 | 蓝图有误先修 6a 再编码；不改前端 UI |
| 8a | `8a-deploy-blueprint` | 参考 | 物流规划 | 云平台选型细化 + CI/CD 方案 + 域名规划 | 零部署执行，只产方案 |
| 8b | `8b-deploy-executor` | 🚩生产 | 搬运工 | 按方案执行部署 + 域名/SSL + 线上验证 | 不改业务逻辑 |
| 9 | `9-acceptance-launch` | 🚩生产 | 验收员 | 端到端验收 + 用户试跑 + 正式签收 | bug 回流上游修，不做新功能 |

**Ops 节点（运维操作，按需触发，可指定节点作用域）：**

| 节点 | Skill 目录名 | 隐喻 | 核心流程 | 审查专家 |
|------|-------------|------|---------|--------|
| troubleshoot | `ops/troubleshoot` | 急诊医生 | 复现→trace→最小改动→回归 | QA 审查官 |
| refactor | `ops/refactor` | 装修工 | 快照→重组→diff 证明→回归 | Architect |
| optimize | `ops/optimize` | 调音师 | 基线度量→优化→量化对比→回归 | 性能审查官 |
| test | `ops/test` | 质检员 | 缺口分析→Red→Green→Refactor→全量 | 测试架构师 |

### 2.3 Skills 文件架构

```
skills/ai-sync-pipeline/              ← 流水线总入口 + PLAYBOOK
├── SKILL.md                          ← 总入口调度器
├── DESIGN_PIPELINE_PLAYBOOK.md       ← 本文件（编制权威）
└── stages/                           ← 各阶段 skill
    ├── 1-biz-context-compressor/
    │   └── SKILL.md
    ├── 2-ui-blueprint-master/
    │   └── SKILL.md
    ├── 3-static-ui-mock-master/
    │   └── SKILL.md
    ├── 4-env-infra-spec/
    │   └── SKILL.md
    ├── 5-dynamic-ui-interaction/
    │   └── SKILL.md
    ├── 6a-page-code-blueprint/
    │   └── SKILL.md
    ├── 6b-page-code-writer/
    │   └── SKILL.md
    ├── 6c-app-integration/
    │   └── SKILL.md
    ├── 7-backend-code-writer/
    │   └── SKILL.md
    ├── 8a-deploy-blueprint/
    │   └── SKILL.md
    ├── 8b-deploy-executor/
    │   └── SKILL.md
    └── 9-acceptance-launch/
        └── SKILL.md
├── ops/                             ← 运维操作（按需触发，可指定节点作用域）
│   ├── troubleshoot/
│   │   └── SKILL.md
│   ├── refactor/
│   │   └── SKILL.md
│   ├── optimize/
│   │   └── SKILL.md
│   └── test/
│       └── SKILL.md
```

> **调度关系**：`SKILL.md`（指挥中心）→ 流水线模式路由到 `stages/*/SKILL.md`；运维模式路由到 `ops/*/SKILL.md`。

---

## 3 产物管理

### 3.1 产物分类及命名规则

1. **参考产物**：高质量但用完即弃，不进生产。前缀 = 消费节点编号，多个消费节点用 `+` 分隔。示例：`2+4_project_context.md` = 1 产出，2 和 4 消费。无固定消费节点的内部参考文件不加前缀。
2. **生产文件**：从零写、结构干净、零技术债继承。直接进入项目目录，如 `infra_spec.md`、`src/` 下的代码。
3. **发现清单**：条件性产出（有发现才输出）。统一命名 `discovery_to_<产物基名>.md`。

### 3.2 文件架构

参考产物一律进 `design/`，discovery 进 `design/_discovery/`，`infra_spec.md` 放根目录。

```
<项目根目录>/
├── design/                          ← 参考产物
│   ├── <消费节点+消费节点>_<基名>.md / .pen ← 各阶段产出（见 §3.3）
│   ├── prototype/                   ← 5 throwaway，完成后可删
│   └── _discovery/                  ← 发现清单流转
│       ├── discovery_to_*.md        ← 活跃
│       └── _consumed/               ← 已归档
├── infra_spec.md                    ← 4 产出（根目录）
├── deploy_config.md                 ← 8b 产出（根目录，full-stack/static-only 均有）
├── src/                             ← 前端生产代码（结构由 infra_spec 定义）
├── server/                          ← 后端生产代码（full-stack 时由 7 产出）
└── ...
```

### 3.3 产物一览表

| 文件名 | 性质 | 生产节点 | 消费节点 |
|--------|------|--------|--------|
| `2+4_project_context.md` | 参考 | 1 | 2, 4 |
| `3+5+6a+6b_layout_blueprint.md` | 参考 | 2 | 3, 5, 6a, 6b |
| `3+6a+6b_style_guidebook.pen` | 参考 | 2 | 3, 6a, 6b |
| `5+6a+6b_static_ui_mock.pen` | 参考 | 3 | 5, 6a, 6b |
| `infra_spec.md` | 🚩生产 | 4 | 5, 6a, 6b, 6c, 7, 8a |
| `prototype/` | 参考 | 5 | （用完即弃） |
| `6a_interaction_map.md` | 参考 | 5 | 6a |
| `6b+6c+7_code_blueprint.md`（full-stack）/ `6b+6c_code_blueprint.md`（static-only） | 参考 | 6a | 6b, 6c, 7 |
| 逐页前端生产代码 | 🚩生产 | 6b | 6c |
| 完整前端应用 | 🚩生产 | 6c | 7, 8a |
| 后端生产代码 (`server/`) | 🚩生产 | 7 | 6c（联调）, 8a, 8b |
| `8b_deploy_blueprint.md` | 参考 | 8a | 8b |
| `deploy_config.md` + 线上 URL | 🚩生产 | 8b | 9 |
| 验收签收记录 | 🚩生产 | 9 | （终点） |
| `discovery_to_*.md` | 发现清单 | 各节点 | 对应上/下游节点 |

---

## 4 角色与质量（Who + How Well）

### 4.1 三层角色模型

每个 skill 固定配置：

| 层 | 角色 | 职责 |
|----|------|------|
| 执行层 | Lead（1 人） | 主笔交付。命名 `[领域] Lead`。每轮只采纳 1 个改动点 |
| 审查层 | 审查专家（≥1 人） | 按需配置，每位有明确审查维度。全员签字才能过 |
| 业务层 | 客户经理 + 项目经理 | 客户经理：大白话沟通。项目经理：上下游对齐 + 一致性，负总责 |

### 4.2 互撕质量门禁

1. **指名道姓**：指出具体页面/组件/元素，禁止笼统评价。
2. **必须找问题**：每回合每位专家至少指出 1 个具体问题；无问题则列出检查项证明。
3. **引用证据**：通过/不通过必须附可验证证据。
4. **最低回合数**：核心 ≥5，终审/局部 ≥3。写入 SKILL.md，未到不得通过。

### 4.3 上下游纪律

四条原则（修订流程见附件二，反向回流见附件三）：

1. **摄入关卡**：开工前项目经理门检上游产物（齐全性/一致性/矛盾）。硬伤 → 暂停回流，不开工。
2. **下游不越权**：上游问题由上游修，下游不代改。执行中随手记录。
3. **发现清单回流**：正向 → 写 discovery，下游 S1 自动拾取。反向 → 立即触发上游修订（见附件三）。
4. **业务现状先行**：技术决策需业务输入时，先大白话摸清现状，再内部互撕选型。

### 4.4 质量兜底

生产物必须自验证通过后才能交付，不允许"理论上能跑"。

---

## 5 SKILL.md 编制规范（How to Write）

### 5.1 语言风格

SKILL.md 读者是 AI Agent，模糊表述 = 自由发挥，精确指令 = 逐条执行。

1. **祈使句**。`做 X`，不用 `应该/建议做 X`。
2. **动词开头**。审查 / 输出 / 校验 / 询问 / 对比 / 读取 / 写入。
3. **短句断行**。一条一个意思，单条 ≤30 字。
4. **禁止模糊词**。禁用「适当/合理/尽量/视情况」，给阈值或判断标准。
5. **中文为主，术语保留英文**。YAML / frontmatter / SKILL.md / ref 等不硬翻。
6. **示例紧跟规则**。能用 1 个 example 说清的，不用 3 句话解释。

### 5.2 结构模板

每份 SKILL.md 必须包含以下章节，顺序固定：

| 章节 | 要求 |
|------|------|
| YAML 头 | `name` + `description` frontmatter |
| TL;DR | 一屏摘要：输入/输出/性质/关键卖点 |
| 角色设定 | 按 §4.1 三层角色模型配置 |
| Strict Rules | 铁律清单，不可被 Workflow 步骤覆盖或放松 |
| Workflow | 编号步骤，每步明确"动作 + 面向谁 + 问什么 + 循环规则" |
| ↳ Step 0 · 摄入关卡 | 项目经理门检上游产物（齐全性/一致性/矛盾）。起点 skill 声明「无上游」 |
| ↳ Step 1 · 模式分流 | 有待处理 discovery 或客户要求改 → 读附件二走 A0→A5；否则 → 首次执行 |
| ↳ 末尾 · 交付后级联 | 读附件三，汇总上游问题并反向回流 |
| Amendment Slots | 末尾声明 target / probe / verify / hooks 四个槽位 |
| Initialization | 末尾固定一句"现在立刻执行 Step 0。" |

### 5.3 Amendment Slots 定义

Skill 在末尾声明 `## Amendment Slots`，提供四个槽位：

| 槽位 | 说明 |
|------|------|
| `target` | 本 skill 核心产物文件名 |
| `probe` | 客户经理追问话术（2-3 句） |
| `verify` | 修订后回到主 Workflow 的哪些 Step 做验证 |
| `hooks` | 本 skill 特有判断逻辑（可为空），限用于 A1 分诊或 A2 重写判断 |

> 示例（`hooks`）：
> - 3 static-ui-mock：A1 退回分诊（数据问题 → Step 3 / 视觉问题 → Step 4 / 微调 → Step 5）
> - 6b page-code-writer：A2 Big Rewrite 判断（修改量 >50% → 删除该页面代码从零重写）

---

## 6 附件

下方附件由 Skill Compiler 编译时提取为独立文件，放在 PLAYBOOK 同目录。Skill 运行时只读附件文件，不读 PLAYBOOK 正文。

| 附件 | 提取为 | 读取时机 |
|------|--------|---------|
| 附件一：依赖映射与 Discovery 规则 | `dependency_map.md` | 写 discovery 时查依赖方向 |
| 附件二：修订流水线 | `amendment_protocol.md` | Step 1 命中修订模式时 |
| 附件三：交付后级联 | `cascade_protocol.md` | 交付完成后执行反向回流 |

---

# 附件一：依赖映射与 Discovery 规则

> **⚙️ Skill Compiler 提取指令**：提取本附件为 `dependency_map.md` 时，将 §3.3 产物一览表原样嵌入下方权威表位置。

> **权威表**：§3.3 产物一览表（Skill Compiler 提取时嵌入）。读法（假设"我"= 当前节点编号）：
> - **正向查下游**：找 `生产节点 = 我` 的所有行 → 消费节点列 = 直接下游。
> - **反向查上游**：找 `消费节点列包含我` 的所有行 → 该行产物 = 我的上游输入，其生产节点 = 上游节点。
>
> **双产物（2）**：layout_blueprint 与 style_guidebook 各自独立产出 discovery，任一存在即触发下游。

产物变更时产出 `discovery_to_<产物基名>.md`，统一存放 `design/_discovery/`。正向通知下游更新，反向回流上游修订。

## discovery 文件模板

```markdown
# Discovery: <目标产物基名>

| # | 位置（页面/组件/章节） | 问题描述 | 建议处理方式 |
|---|----------------------|---------|------------|
| 1 | ... | ... | ... |
```

---

# 附件二：修订流水线 A0→A5

以 `Amendment Slots`（target / probe / verify / hooks）为参数。

## A0 触发 `Step 1 · 自动`

1. `design/_discovery/` 存在 `discovery_to_<本 skill 产物基名>.md` → 进入 A1。
2. 客户要求修改 → 客户经理按 `<probe>` 追问 → 修订清单 → 进入 A1。
3. 均否 → 首次执行，退出修订流程。

## A1 摄入 `项目经理 · 内部`

1. 读取修订清单，逐条标记：接受 / 拒绝 / 需讨论。
2. 需讨论项 → 客户经理大白话确认 → 转为接受或拒绝。
3. **不删** discovery 文件——修订未完成时保留作为重新触发依据。
4. `<hooks>` 含 A1 分诊 → 执行。

## A2 范围锁定 `项目经理 · 告知客户`

1. 只改接受条目 + 直接关联影响，不做范围外重构。
2. 列出"改/不改"清单。`<hooks>` 含 A2 重写判断 → 执行。
3. 告知：> 老板，[产物] 需要调整几个地方：[修订点]。其他不动。

## A3 互撕 `Lead + 专家 · 内部`

局部修订 ≥3 回合 / Big Rewrite ≥5 回合。每轮只采纳 1 个改动点。三签 + 指名道姓 + 引用证据。

## A4 汇报 `客户经理 · 客户`

> 老板，[产物] 已调整：[变更摘要]。其他不变。可以吗？

## A5 交付 `Lead + 项目经理 · 内部`

| 子步骤 | 条件 | 动作 |
|--------|------|------|
| **5a 更新** | 必做 | 写入 design/ 对应路径（参考产物 → `design/`，discovery → `design/_discovery/`） → 重跑 `<verify>` → 输出修订日志 |
| **5b 归档** | 必做 | discovery 移入 `_consumed/`，加后缀 `_consumed_<YYYYMMDD>`。双产物分别归档 |

完成后 → 进入附件三：交付后级联。

---

# 附件三：交付后级联（反向回流协议）

> **适用范围**：所有 skill 交付完成后统一执行，无论首次执行还是修订执行。
>
> **设计理由**：正向 discovery 由下游 S1/A0 自然拾取，无需立即级联。反向回流必须立即触发——上游未修正时下游产物无效，继续正向推进是浪费。

## C1 汇总上游问题 `项目经理 · 内部`

1. 收集执行过程中记录的所有上游产物问题。
2. 无问题 → **结束**，回到主流程。
3. 有问题 → 进入 C2。

## C2 反向回流 `自动`

1. 查附件一，按读法规则从 §3.3 产物一览表定位上游产物及其生产 skill。
2. 读取上游 skill 的 SKILL.md → 从 Step 1 执行（命中修订模式，见附件二 A0→A5）。

## C3 收敛判断 `自动`

上游修订完成后：

1. 上游产物未变更 → **结束**。
2. 上游产物有实质变更 → 上游已写入正向 discovery → 当前 skill 回到 Step 1 自动拾取，触发修订模式重新校准。
