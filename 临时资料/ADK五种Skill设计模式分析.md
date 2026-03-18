# ADK 五种 Agent Skill 设计模式 × ai-sync 对照分析

> 来源：[Google Cloud Tech 推文](https://x.com/GoogleCloudTech/status/2033953579824758855)
> 记录日期：2026-03-18
> 性质：外部洞察沉淀，暂不改动仓库结构

---

## 一、背景

Google Cloud Tech 提出：当 SKILL.md 的格式已经标准化后，真正的挑战是**内部逻辑的内容设计**。同样格式的 SKILL.md，内部逻辑可以完全不同。总结了 5 种设计模式。

## 二、5 种模式概要

| 模式 | 核心逻辑 | 一句话 |
|------|---------|--------|
| **Tool Wrapper** | 按需加载领域知识文档，用完释放 | "需要时才查手册" |
| **Generator** | 加载模板 + 收集变量 + 填充输出 | "填空式生成" |
| **Pipeline** | 步骤 → 门禁 → 步骤 → 门禁 → 输出 | "流水线 + 质检站" |
| **Reviewer** | 加载外部检查清单 → 结构化评审输出 | "按清单逐项打分" |
| **Inversion** | Agent 反过来问用户，收集齐才动手 | "先问清楚再开工" |

**组合性**：这 5 种模式不互斥。Pipeline 末尾可以加 Reviewer 步骤；Generator 开头可以用 Inversion 收集变量。

## 三、ai-sync 现有技能的模式映射

| 技能 | 主模式 | 辅模式 | 备注 |
|------|--------|--------|------|
| 总转化器 | Inversion | — | 问用户→路由分发，不做执行 |
| Skill编译器 | Generator | Reviewer | 从参考文档/需求生成 SKILL.md；三审查官联审 |
| 方法提炼师 | Pipeline | — | 入口门禁→7步线性→场景回放校验 |
| 测试循环师 | Pipeline | Reviewer | 7阶段螺旋迭代；双视角全覆盖审查 |
| 答案澄清师 | Pipeline | — | 轻量线性流：锁题→门禁→核对→答案卡 |
| 全栈编码师 | Generator | Pipeline + Reviewer | 5阶段递进生成；每阶段多回合审查 |
| 问题拆解师 | Inversion | — | 拆解不清晰的问题 |
| 调研判断师 | Pipeline | Reviewer | 证据链→判断 |
| 教材编写师 | Generator | Pipeline | 从素材生成教材 |

### 覆盖情况

- **Inversion** ✅ 已有（总转化器、问题拆解师）
- **Generator** ✅ 已有（Skill编译器、全栈编码师、教材编写师）
- **Pipeline** ✅ 已有（方法提炼师、测试循环师、答案澄清师）
- **Reviewer** ✅ 作为子模式存在（Skill编译器、测试循环师、全栈编码师）
- **Tool Wrapper** ❌ 暂缺——没有纯粹的"按需加载领域知识"型技能

## 四、三个可借鉴方向（待后续决策）

### 方向 1：在 frontmatter 中显式标注 `pattern`

在 SKILL.md 的 YAML frontmatter 加 `pattern` 字段（如 `pattern: Pipeline + Reviewer`），好处：
- Skill编译器造新技能时可按模式套骨架
- 技能召唤书可按模式分组
- 新协作者上手更快

### 方向 2：引入 `references/` 和 `assets/` 目录约定

ADK 三层架构：L1 元数据 / L2 指令 / L3 资源。将参考文档放 `references/`，输出模板放 `assets/`，实现指令与素材分离、按需加载。

示例结构：
```
技能/Skill编译器/
├── SKILL.md
├── references/    ← 编制规范、协议引用
└── assets/        ← SKILL.md 骨架模板
```

不强制所有技能都有——轻量技能（如答案澄清师）可以不用。

### 方向 3：评估 Tool Wrapper 型技能的价值

Tool Wrapper 的核心价值：agent 平时不需要记住领域规则，只在处理特定任务时才加载。

潜在场景：
- 特定电商平台的操作规范
- 特定供应商的合作规则
- 季节性业务流程（如开学季、换季）

## 五、现有优势（不需要改的地方）

| 维度 | ai-sync 现状 | vs ADK 描述 |
|------|-------------|-------------|
| 门禁体系 | 三层门禁（方向→边界→质量） | 比 ADK 的 diamond gate 更成熟 |
| 互撕循环 | 多回合审查 + 单次采纳一个改动点 | 覆盖了 Reviewer 模式核心意图 |
| 协议层 | 13 个共享协议 + 角色库 | 本质就是 ADK 说的"模式可组合" |
| 技能路由 | 总转化器做统一入口分发 | 天然的 Inversion 模式 |

## 六、参考链接

- [Google Cloud Tech 推文](https://x.com/GoogleCloudTech/status/2033953579824758855)
- [ADK Skills 官方文档](https://google.github.io/adk-docs/skills/)
- [awesome-agent-skills (GitHub)](https://github.com/skillmatic-ai/awesome-agent-skills)
- [Developer's guide to multi-agent patterns in ADK](https://developers.googleblog.com/developers-guide-to-multi-agent-patterns-in-adk/)
