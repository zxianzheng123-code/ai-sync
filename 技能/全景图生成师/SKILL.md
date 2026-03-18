---
name: panorama-generator
description: Scans all skills, protocols, and roles in the ai-sync repo, then regenerates 系统全景图.html with current data while preserving visual style.
---

# 全景图生成师（Panorama Generator）

## TL;DR
- 输入：用户说"更新全景图"
- 输出：重新生成的 `系统全景图.html`，反映仓库当前的全部技能、协议、角色
- 性质：仓库维护操作——扫描源文件、生成可视化页面
- 关键卖点：无硬编码清单，仓库里有什么就渲染什么

## 角色设定

> 角色行为规范见 [角色协议](../../协议/角色协议.md) 和各角色文件。

- **执行**：[工程主笔](../../协议/角色/工程主笔.md) — 本技能中称"全景图主笔"，负责扫描、提取、生成
- **审查**：[完整性审查官](../../协议/角色/完整性审查官.md) — 确认生成结果覆盖了所有技能和协议，无遗漏
- **沟通**：[技术翻译官](../../协议/角色/技术翻译官.md) — 用大白话告知用户更新了什么

## Strict Rules

> 本技能遵守以下共享协议，不再重复列出其中的规则：
> - [角色协议](../../协议/角色协议.md) — 身份、底线、角色分层
> - [执行闭环协议](../../协议/执行闭环协议.md) — 推进、汇报、验收、复盘
> - [通用审查协议](../../协议/通用审查协议.md) — 检查关卡、全员确认
> - [流程执行协议](../../协议/流程执行协议.md) — 步骤顺序、不可跳步、不可合并、步骤标记
>
> 以下为本技能特有规则：

1. **无硬编码清单**：不维护技能/协议的固定列表。每次执行时从文件系统动态发现。
2. **只改数据不改样式**：HTML 中的 CSS 和渲染函数（`renderSkillCard`、`renderGroups` 等）保持不变，只更新 `SKILLS`、`PROTOCOLS`、`ROLES`、`GROUPS` 四个 JS 数据对象。
3. **分组来源**：技能分组信息从 `正哥技能召唤书.md` 的章节标题获取，不硬编码。
4. **颜色映射规则**：每个分组沿用现有 CSS 变量（`--c-router`、`--c-answer` 等）。新增分组时使用 `--c-fallback` 作为默认色，并在 CSS `:root` 中补充新变量。
5. **完整性校验必做**：生成后必须对比"扫描到的技能数"和"HTML 中 SKILLS 对象的 key 数"，不一致则报错。

---

## Workflow

> 以下步骤受[流程执行协议](../../协议/流程执行协议.md)约束：不可跳步、不可合并、每步必须产出步骤标记。

### Step 1: 扫描仓库现状（内部）

动作：
1. 扫描 `技能/*/SKILL.md`，列出所有技能目录
2. 扫描 `协议/*.md`（排除 `协议引用矩阵.md`），列出所有协议文件
3. 扫描 `协议/角色/*.md`，列出所有角色文件
4. 读取 `正哥技能召唤书.md`，提取分组信息

产出：文件清单 + 分组映射

### Step 2: 提取数据（内部）

逐个读取 Step 1 发现的文件，提取以下字段：

**每个技能（从 SKILL.md）：**
- group：所属能力组（来自召唤书分组）
- color：对应的 CSS 变量
- icon：HTML 实体图标
- trigger：暗号（来自召唤书）
- desc：一句话描述（来自 TL;DR 或 SKILL.md 标题下方）
- tldr：输入 → 输出（来自 TL;DR）
- protocols：引用的协议缩写列表（来自 Strict Rules 中的协议引用）
- roles：exec / audit / comm 三个角色（来自角色设定）
- steps：Workflow 步骤列表，每步含 n / title / type / desc / branch

**每个协议（从协议 .md）：**
- name：协议名称
- abbr：缩写（R / C / F / Ans / E / J / Met / Txt / D / T / A / W）
- desc：一句话描述

**每个角色（从角色 .md）：**
- name：角色名称
- desc：职责描述
- type：exec / audit / comm

产出：结构化数据

### Step 3: 生成 HTML（内部）

动作：
1. 用 Step 2 的数据构建 `SKILLS`、`PROTOCOLS`、`ROLES`、`GROUPS` 四个 JS 对象
2. 保留现有 `系统全景图.html` 的 CSS 和渲染函数不变
3. 只替换 `<script>` 标签内 `// DATA MODEL` 到 `// RENDER FUNCTIONS` 之间的数据部分
4. 写入 `系统全景图.html`

### Step 4: 校验（内部）

动作：
1. 对比扫描到的技能数和生成的 SKILLS key 数，必须一致
2. 对比扫描到的协议数和生成的 PROTOCOLS key 数，必须一致
3. 确认每个 GROUPS 中引用的技能名都存在于 SKILLS 中

产出：校验结果

### Step 5: 部署到线上（内部）

动作：
1. 将生成的 `系统全景图.html` 复制到 `公开站点/index.html`
2. 执行部署命令：
```
netlify deploy --prod --dir=公开站点 --site=6afa32a0-d7c0-4252-ab87-1364175cb1c0
```
3. 确认部署成功（Deploy is live）

线上地址：https://darling-semolina-902be1.netlify.app/

### Step 6: 汇报（面向用户）

用大白话告知：
- 本次扫描到多少个技能、多少个协议、多少个角色
- 相比上一版有什么变化（新增/删除/修改了哪些）
- 如果有异常（某个 SKILL.md 格式不对导致提取失败），明确指出

## Initialization
现在执行 Step 1。

## 部署信息

- **Netlify Site ID**: `6afa32a0-d7c0-4252-ab87-1364175cb1c0`
- **Netlify Site Name**: `darling-semolina-902be1`
- **线上地址**: https://darling-semolina-902be1.netlify.app/
- **部署目录**: `公开站点/`（仓库根目录下，内含 `index.html`）
