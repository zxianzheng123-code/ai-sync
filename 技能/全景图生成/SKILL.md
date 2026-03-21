---
description: 当用户想查看整个技能体系的全景视图或架构图时，使用此技能
trigger: 更新全景图
version: 2.0
---

## 执行模式
Master Agent 负责调度和验收，不亲自干活。每个步骤启动 SubAgent 执行。

## 工作人员
- 产品（→ 技能/人设库/产品/人设.md）

## Workflow

### Step 0：加载上下文（Master Agent）
执行 脚本/加载上下文.sh

### Step 1：数据收集
- 执行者：产品（SubAgent）
- 目标：扫描仓库现状，发现所有技能、协议、角色，提取分组信息
- 成功标准：技能/*/SKILL.md 全部扫描到；协议/*.md 全部扫描到；技能/人设库/*/人设.md 全部扫描到；正哥技能召唤书.md 中的分组信息已提取
- 输入：仓库文件系统
- 输出：文件清单 + 分组映射

### Step 2：结构分析
- 执行者：产品（SubAgent）
- 目标：从每个文件中提取结构化数据——技能（group/color/icon/trigger/desc/tldr/protocols/roles/steps）、协议（name/abbr/desc）、角色（name/desc/type）
- 成功标准：每个文件的关键字段全部提取；无硬编码清单，仓库里有什么就提取什么
- 输入：Step 1 的文件清单
- 输出：结构化数据（SKILLS/PROTOCOLS/ROLES/GROUPS四个数据对象）

### Step 3：全景图生成
- 执行者：产品（SubAgent）
- 目标：用结构化数据更新系统全景图.html——只改数据不改样式（CSS和渲染函数保持不变，只更新JS数据对象）
- 成功标准：HTML中SKILLS对象的key数与扫描到的技能数一致；每个GROUPS中引用的技能名都存在于SKILLS中；新增分组使用--c-fallback默认色
- 输入：Step 2 的结构化数据
- 输出：更新后的系统全景图.html

### Step 4：验证
- 如有 脚本/验证/ 下的脚本 → 自动执行
- 如有 作业指引/交付自查清单.md → 逐项检查
- 额外检查项：
  - [ ] 扫描到的技能数 = HTML中SKILLS key数
  - [ ] 扫描到的协议数 = HTML中PROTOCOLS key数
  - [ ] GROUPS中引用的技能名全部存在于SKILLS中
  - [ ] CSS和渲染函数未被改动
- 全部通过才进入交付

### Step 5：交付审核（Master Agent）
输出更新后的全景图，部署到线上（netlify deploy --prod --dir=公开站点 --site=6afa32a0-d7c0-4252-ab87-1364175cb1c0），等用户确认。汇报本次扫描到的技能/协议/角色数量及相比上一版的变化。
