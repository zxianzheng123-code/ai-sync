---
name: obsidian
description: Obsidian 全功能编辑 — 涵盖 Markdown 笔记（wikilink/embed/callout/frontmatter）、Bases 数据库（.base）、JSON Canvas 画布（.canvas）以及 CLI 命令行交互。用户处理 .md/.base/.canvas 文件或通过命令行操作 vault 时使用。
---

# Obsidian 编辑

## 文档定位

本 skill 覆盖 Obsidian 四大能力：

- **Markdown 编辑**：Obsidian 对 Markdown 的扩展语法（wikilink、embed、callout、properties、tags、comments）
- **Bases 编辑**：`.base` 文件的创建与修改（视图、过滤器、公式、汇总）
- **JSON Canvas 编辑**：`.canvas` 文件的创建与修改（节点、连线、分组、布局）
- **CLI 命令行**：通过 `obsidian` 命令行与运行中的 vault 交互

---

## 一、Markdown 编辑

本节不重复普通 Markdown 基础语法，只覆盖 Obsidian 特有内容。

### 工作流

1. 先确定笔记结构，再写正文。
2. 需要元数据时，把 properties 放在文件最上方。
3. Vault 内部引用优先用 wikilink。
4. 需要内嵌内容时用 embed，不要用普通链接冒充嵌入。
5. 重要说明用 callout，不要乱堆粗体和感叹号。
6. 写完后至少检查一次阅读视图是否正常渲染。

### 文件头：Properties

Properties 使用 YAML frontmatter，放在文件最开头：

```yaml
---
title: 我的笔记
date: 2024-01-15
tags:
  - 项目
  - 活跃
aliases:
  - 备用名称
cssclasses:
  - custom-class
---
```

默认常用字段：

- `tags`：标签
- `aliases`：别名
- `cssclasses`：自定义样式类

完整属性说明见 [参考资料/属性说明.md](参考资料/属性说明.md)。

### 内部链接：Wikilink

Vault 内笔记之间的链接优先使用 wikilink：

```markdown
[[笔记名]]
[[笔记名|显示文本]]
[[笔记名#标题]]
[[笔记名#^block-id]]
[[#当前笔记里的标题]]
```

规则：

- 链接 vault 内笔记时，优先用 `[[wikilink]]`。
- 链接外部网页时，才用 `[文本](url)`。
- block link 需要先在原文里定义 block ID。

### Block ID

给段落追加 block ID：

```markdown
这是一段可以被精确引用的内容。 ^my-block-id
```

给引用块或列表追加 block ID 时，单独占一行：

```markdown
> 这是一个引用块

^quote-id
```

### 嵌入：Embed

给 wikilink 前面加 `!` 就是嵌入：

```markdown
![[笔记名]]
![[笔记名#标题]]
![[image.png]]
![[image.png|300]]
![[document.pdf#page=3]]
```

嵌入细节见 [参考资料/嵌入说明.md](参考资料/嵌入说明.md)。

### Callout

Callout 用来表达提示、警告、说明、问题等重点内容：

```markdown
> [!note]
> 基础说明。

> [!warning] 自定义标题
> 带标题的警告块。

> [!faq]- 默认折叠
> `-` 表示默认折叠，`+` 表示默认展开。
```

完整类型和别名见 [参考资料/Callout说明.md](参考资料/Callout说明.md)。

### 标签：Tags

```markdown
#tag
#nested/tag
```

标签可包含字母、数字（不能放首位）、下划线 `_`、连字符 `-`、斜杠 `/`。也可写在 frontmatter 的 `tags` 字段里。

### 注释：Comments

```markdown
这段内容可见 %%这段内容隐藏%%。

%%
这一整块在阅读视图中都会隐藏。
%%
```

### Obsidian 扩展格式

**高亮**：`==高亮文本==`

**数学公式**：行内 `$e^{i\pi} + 1 = 0$`，块级用 `$$...$$`

**Mermaid**：用 ` ```mermaid ` 代码块

**脚注**：`[^1]` + `[^1]: 脚注内容`，或行内 `^[行内脚注]`

---

## 二、Bases 编辑

`.base` 文件本质上是 YAML，处理三类问题：哪些笔记进入 Base、如何计算和展示、以什么视图呈现。

### 工作流

1. 创建 `.base` 文件，保证内容是合法 YAML。
2. 用 `filters` 定义数据范围。
3. 需要派生字段时写 `formulas`。
4. 用 `properties` 控制显示名。
5. 用 `views` 定义视图。
6. 校验 YAML、公式引用和视图引用是否闭环。

### 文件结构

```yaml
filters:
  and: []
  or: []
  not: []

formulas:
  formula_name: 'expression'

properties:
  property_name:
    displayName: "显示名"
  formula.formula_name:
    displayName: "公式显示名"

summaries:
  custom_summary_name: 'values.mean().round(3)'

views:
  - type: table | cards | list | map
    name: "视图名"
    order:
      - file.name
      - property_name
      - formula.formula_name
```

### 过滤器：Filters

```yaml
# 单条件
filters: 'status == "done"'

# 多条件 AND
filters:
  and:
    - 'status == "done"'
    - 'priority > 3'

# 多条件 OR
filters:
  or:
    - 'file.hasTag("book")'
    - 'file.hasTag("article")'

# 排除 NOT
filters:
  not:
    - 'file.hasTag("archived")'

# 嵌套
filters:
  or:
    - file.hasTag("tag")
    - and:
        - file.hasTag("book")
        - file.hasLink("Textbook")
```

常用运算符：`==` `!=` `>` `<` `>=` `<=` `&&` `||` `!`

### 属性：Properties

三类属性：

1. 笔记属性：来自 frontmatter，如 `author`
2. 文件属性：来自文件元数据，如 `file.name`
3. 公式属性：来自 `formulas`，如 `formula.total`

常用文件属性：

| 属性 | 类型 | 说明 |
|------|------|------|
| `file.name` | String | 文件名 |
| `file.path` | String | 完整路径 |
| `file.folder` | String | 父目录 |
| `file.size` | Number | 文件大小 |
| `file.ctime` | Date | 创建时间 |
| `file.mtime` | Date | 修改时间 |
| `file.tags` | List | 全部标签 |
| `file.links` | List | 内部链接 |
| `file.backlinks` | List | 反向链接 |

`this` 关键字：在主内容区指向当前 Base 文件；被嵌入时指向嵌入它的文件。

### 公式：Formulas

```yaml
formulas:
  total: "price * quantity"
  status_icon: 'if(done, "✅", "⏳")'
  created: 'file.ctime.format("YYYY-MM-DD")'
  days_old: '(now() - file.ctime).days'
  days_until_due: 'if(due_date, (date(due_date) - today()).days, "")'
```

常用全局函数：`date()` `now()` `today()` `if()` `duration()` `file()` `link()`

完整函数表见 [参考资料/函数参考.md](参考资料/函数参考.md)。

**Duration 规则**：日期相减返回 Duration，不能直接用 `.round()`，必须先取 `.days` / `.hours` 等数字字段。

### 视图：Views

```yaml
# Table
views:
  - type: table
    name: "我的表格"
    order: [file.name, status, due_date]

# Cards
views:
  - type: cards
    name: "卡片视图"
    order: [file.name, cover_image, description]

# List / Map
views:
  - type: list | map
    name: "视图名"
```

`map` 视图需要经纬度属性。

### 默认汇总公式

`Average` `Min` `Max` `Sum` `Range` `Median` `Stddev` `Earliest` `Latest` `Checked` `Unchecked` `Empty` `Filled` `Unique`

### 嵌入 Base

```markdown
![[MyBase.base]]
![[MyBase.base#View Name]]
```

### YAML 引号规则

- 简单字符串用双引号。
- 公式含双引号时，外层改用单引号。
- 出现冒号、方括号等特殊字符时，优先补引号。

### 排错

1. **YAML 语法错误**：检查特殊字符引号、公式引号配对、缩进一致。
2. **Duration 用错**：`(now() - file.ctime).days.round(0)` ✅ / `(now() - file.ctime).round(0)` ❌
3. **空值未保护**：用 `if(due_date, ..., "")` 包裹。
4. **引用未定义公式**：`order` 里写了 `formula.X`，`formulas` 里必须先定义 `X`。

---

## 三、JSON Canvas 编辑

`.canvas` 文件遵循 [JSON Canvas Spec 1.0](https://jsoncanvas.org/spec/1.0/)。

### 工作流

**新建画布**：创建 `.canvas` → 写入基础结构 → 生成唯一 ID → 补齐必填字段 → 补 edges → 校验。

**加节点**：解析原始 `.canvas` → 生成不冲突 ID → 选不遮挡位置 → 追加节点 → 补连线 → 校验。

**修改画布**：解析 JSON → 按 `id` 定位 → 只改目标字段 → 回写校验。

### 文件结构

```json
{
  "nodes": [],
  "edges": []
}
```

节点数组顺序影响层级：前面在下层，后面在上层。

### 节点

**通用字段**：

| 字段 | 必填 | 类型 | 说明 |
|------|------|------|------|
| `id` | 是 | string | 唯一 16 位十六进制 ID |
| `type` | 是 | string | `text` / `file` / `link` / `group` |
| `x` | 是 | integer | 左上角 X 坐标 |
| `y` | 是 | integer | 左上角 Y 坐标 |
| `width` | 是 | integer | 宽度 |
| `height` | 是 | integer | 高度 |
| `color` | 否 | canvasColor | `"1"`-`"6"` 或十六进制 |

**文本节点**：必须有 `text`。JSON 里换行用 `\n`。

**文件节点**：必须有 `file`。可选 `subpath`（以 `#` 开头）。

**链接节点**：必须有 `url`。

**分组节点**：用来包住一组节点。可选 `label`、`background`、`backgroundStyle`。

### 连线

| 字段 | 必填 | 默认值 | 说明 |
|------|------|--------|------|
| `id` | 是 | - | 边 ID |
| `fromNode` | 是 | - | 源节点 |
| `fromSide` | 否 | - | `top` / `right` / `bottom` / `left` |
| `fromEnd` | 否 | `none` | `none` / `arrow` |
| `toNode` | 是 | - | 目标节点 |
| `toSide` | 否 | - | `top` / `right` / `bottom` / `left` |
| `toEnd` | 否 | `arrow` | `none` / `arrow` |
| `color` | 否 | - | 连线颜色 |
| `label` | 否 | - | 说明文字 |

### 颜色

预设色：`"1"` 红、`"2"` 橙、`"3"` 黄、`"4"` 绿、`"5"` 青、`"6"` 紫。也支持十六进制如 `"#FF0000"`。

### ID 规则

16 位小写十六进制字符串：`6f0ad84f44ce9c17`

### 布局建议

- 坐标允许负数。`x` 向右增长，`y` 向下增长。
- 节点间距 50-100px，分组内边距 20-50px。
- 尽量按 10 或 20 的倍数对齐。

| 节点类型 | 建议宽度 | 建议高度 |
|----------|----------|----------|
| 小文本 | 200-300 | 80-150 |
| 中文本 | 300-450 | 150-300 |
| 大文本 | 400-600 | 300-500 |
| 文件预览 | 300-500 | 200-400 |
| 链接预览 | 250-400 | 100-200 |

### 校验清单

1. 所有 `id` 在 `nodes` 和 `edges` 范围内唯一。
2. 每个 `fromNode` / `toNode` 都能在节点数组里找到。
3. 不同节点类型的必填字段齐全。
4. `type` 只使用允许值。
5. `fromSide` / `toSide` 只使用四个方向值。
6. `fromEnd` / `toEnd` 只使用 `none` 或 `arrow`。
7. 颜色值合法。
8. JSON 能成功解析。

完整示例见 [参考资料/Canvas示例.md](参考资料/Canvas示例.md)。

---

## 四、CLI 命令行

通过 `obsidian` 命令行与正在运行的 Obsidian 实例交互。

前提：Obsidian 已打开，本机已安装 `obsidian` CLI。

### 语法规则

- 参数用 `=` 传值，值含空格加引号：`obsidian create name="我的笔记" content="你好"`
- 布尔开关不需要值：`obsidian create name="我的笔记" silent overwrite`
- 换行用 `\n`，制表用 `\t`

### 文件与 Vault 定位

- `file=<name>`：按 wikilink 方式解析。
- `path=<path>`：按 vault 根目录精确路径解析。
- 未传则默认操作当前激活文件。
- `vault=<name>`：指定 vault（默认最近聚焦的）。

### 常用命令

```bash
# 笔记操作
obsidian read file="我的笔记"
obsidian create name="新笔记" content="# 标题" template="模板" silent
obsidian append file="我的笔记" content="新的一行"
obsidian search query="搜索词" limit=10

# 每日笔记
obsidian daily:read
obsidian daily:append content="- [ ] 新任务"

# 属性与元数据
obsidian property:set name="status" value="done" file="我的笔记"
obsidian tasks daily todo
obsidian tags sort=count counts
obsidian backlinks file="我的笔记"
```

补充：任何命令可加 `--copy` 复制输出到剪贴板；`silent` 避免自动打开文件。

### 插件与主题开发

推荐验证顺序：重载 → 查错 → 截图/DOM → 控制台。

```bash
obsidian plugin:reload id=my-plugin        # 重载插件
obsidian dev:errors                         # 查看错误
obsidian dev:screenshot path=screenshot.png # 截图
obsidian dev:dom selector=".workspace-leaf" text  # DOM
obsidian dev:console level=error            # 控制台
obsidian eval code="app.vault.getFiles().length"  # 执行 JS
obsidian dev:css selector=".workspace-leaf" prop=background-color  # CSS
obsidian dev:mobile on                      # 移动端模拟
```

先跑 `obsidian help` 拿到本机实时命令说明。官方文档：https://help.obsidian.md/cli

---

## 引用

- [Obsidian Flavored Markdown](https://help.obsidian.md/obsidian-flavored-markdown)
- [Internal links](https://help.obsidian.md/links)
- [Embed files](https://help.obsidian.md/embeds)
- [Callouts](https://help.obsidian.md/callouts)
- [Properties](https://help.obsidian.md/properties)
- [Bases Syntax](https://help.obsidian.md/bases/syntax)
- [Bases Functions](https://help.obsidian.md/bases/functions)
- [JSON Canvas Spec 1.0](https://jsoncanvas.org/spec/1.0/)
- [Obsidian CLI](https://help.obsidian.md/cli)
