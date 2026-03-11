---
name: obsidian-bases
description: 创建和编辑 Obsidian Bases（.base 文件），支持视图、过滤器、公式和汇总。用户处理 .base 文件、笔记表格视图、卡片视图、筛选或公式时使用。
---

# Obsidian Bases

## 文档定位

本 skill 用来创建和修改 `.base` 文件。

它处理的是三类问题：

- 哪些笔记进入这个 Base
- 进入后如何计算和展示
- 最终以什么视图呈现

## 工作流

1. 先创建 `.base` 文件，并保证内容是合法 YAML。
2. 用 `filters` 定义数据范围。
3. 需要派生字段时，再写 `formulas`。
4. 用 `properties` 控制显示名。
5. 用 `views` 定义 table、cards、list 或 map 视图。
6. 最后校验 YAML、公式引用和视图引用是否闭环。
7. 有条件的话，在 Obsidian 里打开验证一次。

## 文件结构

`.base` 文件本质上是 YAML。

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

## 过滤器：Filters

过滤器负责决定哪些笔记进入 Base。

### 单条件

```yaml
filters: 'status == "done"'
```

### 多条件 AND

```yaml
filters:
  and:
    - 'status == "done"'
    - 'priority > 3'
```

### 多条件 OR

```yaml
filters:
  or:
    - 'file.hasTag("book")'
    - 'file.hasTag("article")'
```

### 排除条件 NOT

```yaml
filters:
  not:
    - 'file.hasTag("archived")'
```

### 嵌套条件

```yaml
filters:
  or:
    - file.hasTag("tag")
    - and:
        - file.hasTag("book")
        - file.hasLink("Textbook")
    - not:
        - file.hasTag("book")
        - file.inFolder("Required Reading")
```

### 常用运算符

| 运算符 | 含义 |
|--------|------|
| `==` | 等于 |
| `!=` | 不等于 |
| `>` | 大于 |
| `<` | 小于 |
| `>=` | 大于等于 |
| `<=` | 小于等于 |
| `&&` | 与 |
| `\|\|` | 或 |
| `!` | 非 |

## 属性：Properties

Base 里常见三类属性：

1. 笔记属性：来自 frontmatter，如 `author`
2. 文件属性：来自文件元数据，如 `file.name`
3. 公式属性：来自 `formulas`，如 `formula.total`

### 常用文件属性

| 属性 | 类型 | 说明 |
|------|------|------|
| `file.name` | String | 文件名 |
| `file.basename` | String | 不带扩展名的文件名 |
| `file.path` | String | 完整路径 |
| `file.folder` | String | 父目录 |
| `file.ext` | String | 扩展名 |
| `file.size` | Number | 文件大小 |
| `file.ctime` | Date | 创建时间 |
| `file.mtime` | Date | 修改时间 |
| `file.tags` | List | 文件内全部标签 |
| `file.links` | List | 内部链接 |
| `file.backlinks` | List | 反向链接 |
| `file.embeds` | List | 嵌入内容 |
| `file.properties` | Object | frontmatter 全量属性 |

### `this` 关键字

- 在主内容区：指向当前 Base 文件本身
- 被嵌入时：指向嵌入它的文件
- 在侧栏里：指向主内容区当前激活文件

## 公式：Formulas

公式用于生成派生值。

```yaml
formulas:
  total: "price * quantity"
  status_icon: 'if(done, "✅", "⏳")'
  formatted_price: 'if(price, price.toFixed(2) + " 元")'
  created: 'file.ctime.format("YYYY-MM-DD")'
  days_old: '(now() - file.ctime).days'
  days_until_due: 'if(due_date, (date(due_date) - today()).days, "")'
```

### 常用全局函数

| 函数 | 签名 | 说明 |
|------|------|------|
| `date()` | `date(string): date` | 把字符串转成日期 |
| `now()` | `now(): date` | 当前日期时间 |
| `today()` | `today(): date` | 今天 |
| `if()` | `if(condition, trueResult, falseResult?)` | 条件判断 |
| `duration()` | `duration(string): duration` | 解析时长 |
| `file()` | `file(path): file` | 获取文件对象 |
| `link()` | `link(path, display?): Link` | 生成链接 |

完整函数表见 [references/FUNCTIONS_REFERENCE.md](references/FUNCTIONS_REFERENCE.md)。

### Duration 规则

日期相减返回的是 **Duration**，不是数字。

可用字段：

- `duration.days`
- `duration.hours`
- `duration.minutes`
- `duration.seconds`
- `duration.milliseconds`

关键规则：

- 不能直接对 Duration 用 `.round()`、`.floor()`、`.ceil()`
- 必须先取数字字段，再做数字运算

```yaml
# 正确
"(date(due_date) - today()).days"
"(now() - file.ctime).days.round(0)"

# 错误
# "(now() - file.ctime).round(0)"
```

### 日期运算

```yaml
"now() + \"1 day\""
"today() + \"7d\""
"now() - file.ctime"
"(now() - file.ctime).days"
```

## 视图：Views

### Table

```yaml
views:
  - type: table
    name: "我的表格"
    order:
      - file.name
      - status
      - due_date
```

### Cards

```yaml
views:
  - type: cards
    name: "卡片视图"
    order:
      - file.name
      - cover_image
      - description
```

### List

```yaml
views:
  - type: list
    name: "列表视图"
    order:
      - file.name
      - status
```

### Map

```yaml
views:
  - type: map
    name: "地图视图"
```

注意：

`map` 视图需要经纬度属性，通常也依赖 Maps 社区插件。

## 默认汇总公式

| 名称 | 输入类型 | 说明 |
|------|----------|------|
| `Average` | Number | 平均值 |
| `Min` | Number | 最小值 |
| `Max` | Number | 最大值 |
| `Sum` | Number | 求和 |
| `Range` | Number / Date | 范围 |
| `Median` | Number | 中位数 |
| `Stddev` | Number | 标准差 |
| `Earliest` | Date | 最早日期 |
| `Latest` | Date | 最晚日期 |
| `Checked` | Boolean | `true` 数量 |
| `Unchecked` | Boolean | `false` 数量 |
| `Empty` | Any | 空值数量 |
| `Filled` | Any | 非空数量 |
| `Unique` | Any | 去重后的数量 |

## 完整示例

### 任务追踪 Base

```yaml
filters:
  and:
    - file.hasTag("task")
    - 'file.ext == "md"'

formulas:
  days_until_due: 'if(due, (date(due) - today()).days, "")'
  is_overdue: 'if(due, date(due) < today() && status != "done", false)'
  priority_label: 'if(priority == 1, "🔴 高", if(priority == 2, "🟡 中", "🟢 低"))'

properties:
  status:
    displayName: 状态
  formula.days_until_due:
    displayName: "距离截止天数"
  formula.priority_label:
    displayName: 优先级

views:
  - type: table
    name: "进行中任务"
    filters:
      and:
        - 'status != "done"'
    order:
      - file.name
      - status
      - formula.priority_label
      - due
      - formula.days_until_due
```

### 阅读清单 Base

```yaml
filters:
  or:
    - file.hasTag("book")
    - file.hasTag("article")

formulas:
  reading_time: 'if(pages, (pages * 2).toString() + " 分钟", "")'
  status_icon: 'if(status == "reading", "📖", if(status == "done", "✅", "📚"))'

views:
  - type: cards
    name: "资料库"
    order:
      - cover
      - file.name
      - author
      - formula.status_icon
```

## 嵌入 Base

Markdown 中可以直接嵌入：

```markdown
![[MyBase.base]]
![[MyBase.base#View Name]]
```

## YAML 引号规则

- 简单字符串通常用双引号。
- 公式里如果已经包含双引号，整条公式外层改用单引号。
- 出现冒号、方括号、花括号等特殊字符时，优先补引号。

```yaml
# 错误
displayName: 状态: 进行中

# 正确
displayName: "状态: 进行中"
```

```yaml
# 错误
formulas:
  label: "if(done, "Yes", "No")"

# 正确
formulas:
  label: 'if(done, "Yes", "No")'
```

## 排错

### 1. YAML 语法错误

优先检查：

- 特殊字符是否漏加引号
- 公式里的引号有没有成对
- 缩进是否一致

### 2. Duration 用错

```yaml
# 错误
"(now() - file.ctime).round(0)"

# 正确
"(now() - file.ctime).days.round(0)"
```

### 3. 空值未保护

```yaml
# 错误
"(date(due_date) - today()).days"

# 正确
'if(due_date, (date(due_date) - today()).days, "")'
```

### 4. 引用了未定义公式

如果 `order` 或 `properties` 里写了 `formula.X`，那 `formulas` 里必须先定义 `X`。

## 引用

- [Bases Syntax](https://help.obsidian.md/bases/syntax)
- [Functions](https://help.obsidian.md/bases/functions)
- [Views](https://help.obsidian.md/bases/views)
- [Formulas](https://help.obsidian.md/formulas)
- [完整函数参考](references/FUNCTIONS_REFERENCE.md)
