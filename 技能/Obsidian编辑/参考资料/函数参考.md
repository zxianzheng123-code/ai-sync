# Functions 参考

## 全局函数

| 函数 | 签名 | 说明 |
|------|------|------|
| `date()` | `date(string): date` | 把字符串解析成日期，格式通常为 `YYYY-MM-DD HH:mm:ss` |
| `duration()` | `duration(string): duration` | 解析时长字符串 |
| `now()` | `now(): date` | 当前日期时间 |
| `today()` | `today(): date` | 当前日期，时间部分为 `00:00:00` |
| `if()` | `if(condition, trueResult, falseResult?)` | 条件判断 |
| `min()` | `min(n1, n2, ...): number` | 最小值 |
| `max()` | `max(n1, n2, ...): number` | 最大值 |
| `number()` | `number(any): number` | 转成数字 |
| `link()` | `link(path, display?): Link` | 创建链接 |
| `list()` | `list(element): List` | 如果不是列表则包成列表 |
| `file()` | `file(path): file` | 获取文件对象 |
| `image()` | `image(path): image` | 生成可渲染图片 |
| `icon()` | `icon(name): icon` | 通过 Lucide 名称生成图标 |
| `html()` | `html(string): html` | 作为 HTML 渲染 |
| `escapeHTML()` | `escapeHTML(string): string` | 转义 HTML 字符 |

## 任意类型函数

| 函数 | 签名 | 说明 |
|------|------|------|
| `isTruthy()` | `any.isTruthy(): boolean` | 转成布尔值 |
| `isType()` | `any.isType(type): boolean` | 判断类型 |
| `toString()` | `any.toString(): string` | 转成字符串 |

## 日期函数与字段

可用字段：

- `date.year`
- `date.month`
- `date.day`
- `date.hour`
- `date.minute`
- `date.second`
- `date.millisecond`

| 函数 | 签名 | 说明 |
|------|------|------|
| `date()` | `date.date(): date` | 去掉时间部分 |
| `format()` | `date.format(string): string` | 按 Moment.js 模式格式化 |
| `time()` | `date.time(): string` | 取时间字符串 |
| `relative()` | `date.relative(): string` | 输出相对时间 |
| `isEmpty()` | `date.isEmpty(): boolean` | 对日期类型始终为 `false` |

## Duration 类型

日期相减返回的是 **Duration**，不是数字。

### 字段

| 字段 | 类型 | 说明 |
|------|------|------|
| `duration.days` | Number | 总天数 |
| `duration.hours` | Number | 总小时数 |
| `duration.minutes` | Number | 总分钟数 |
| `duration.seconds` | Number | 总秒数 |
| `duration.milliseconds` | Number | 总毫秒数 |

### 关键规则

Duration 不能直接调用 `.round()`、`.floor()`、`.ceil()`。

必须先取数字字段，再做数字运算。

```yaml
# 正确
"(date(due_date) - today()).days"
"(now() - file.ctime).days"
"(date(due_date) - today()).days.round(0)"

# 错误
# "((date(due) - today()) / 86400000).round(0)"
```

## 日期运算

```yaml
# 支持的单位：
# y/year/years, M/month/months, d/day/days,
# w/week/weeks, h/hour/hours, m/minute/minutes, s/second/seconds

"date + \"1M\""
"date - \"2h\""
"now() + \"1 day\""
"today() + \"7d\""

"now() - file.ctime"
"(now() - file.ctime).days"
"(now() - file.ctime).hours"

"now() + (duration('1d') * 2)"
```

## 字符串函数

字段：

- `string.length`

| 函数 | 签名 | 说明 |
|------|------|------|
| `contains()` | `string.contains(value): boolean` | 是否包含子串 |
| `containsAll()` | `string.containsAll(...values): boolean` | 是否包含全部子串 |
| `containsAny()` | `string.containsAny(...values): boolean` | 是否包含任一子串 |
| `startsWith()` | `string.startsWith(query): boolean` | 是否以指定内容开头 |
| `endsWith()` | `string.endsWith(query): boolean` | 是否以指定内容结尾 |
| `isEmpty()` | `string.isEmpty(): boolean` | 是否为空 |
| `lower()` | `string.lower(): string` | 转小写 |
| `title()` | `string.title(): string` | 转标题格式 |
| `trim()` | `string.trim(): string` | 去除首尾空白 |
| `replace()` | `string.replace(pattern, replacement): string` | 替换内容 |
| `repeat()` | `string.repeat(count): string` | 重复字符串 |
| `reverse()` | `string.reverse(): string` | 反转字符串 |
| `slice()` | `string.slice(start, end?): string` | 截取子串 |
| `split()` | `string.split(separator, n?): list` | 切分为列表 |

## 数字函数

| 函数 | 签名 | 说明 |
|------|------|------|
| `abs()` | `number.abs(): number` | 绝对值 |
| `ceil()` | `number.ceil(): number` | 向上取整 |
| `floor()` | `number.floor(): number` | 向下取整 |
| `round()` | `number.round(digits?): number` | 四舍五入 |
| `toFixed()` | `number.toFixed(precision): string` | 固定小数位输出 |
| `isEmpty()` | `number.isEmpty(): boolean` | 是否为空 |

## 列表函数

字段：

- `list.length`

| 函数 | 签名 | 说明 |
|------|------|------|
| `contains()` | `list.contains(value): boolean` | 是否包含元素 |
| `containsAll()` | `list.containsAll(...values): boolean` | 是否包含全部元素 |
| `containsAny()` | `list.containsAny(...values): boolean` | 是否包含任一元素 |
| `filter()` | `list.filter(expression): list` | 按条件筛选 |
| `map()` | `list.map(expression): list` | 映射转换 |
| `reduce()` | `list.reduce(expression, initial): any` | 归约成单值 |
| `flat()` | `list.flat(): list` | 展平嵌套列表 |
| `join()` | `list.join(separator): string` | 拼接为字符串 |
| `reverse()` | `list.reverse(): list` | 反转顺序 |
| `slice()` | `list.slice(start, end?): list` | 截取子列表 |
| `sort()` | `list.sort(): list` | 升序排序 |
| `unique()` | `list.unique(): list` | 去重 |
| `isEmpty()` | `list.isEmpty(): boolean` | 是否为空列表 |

## 文件函数

| 函数 | 签名 | 说明 |
|------|------|------|
| `asLink()` | `file.asLink(display?): Link` | 转成链接 |
| `hasLink()` | `file.hasLink(otherFile): boolean` | 是否链接到某个文件 |
| `hasTag()` | `file.hasTag(...tags): boolean` | 是否拥有任一标签 |
| `hasProperty()` | `file.hasProperty(name): boolean` | 是否存在某个属性 |
| `inFolder()` | `file.inFolder(folder): boolean` | 是否位于某目录或其子目录 |

## 链接函数

| 函数 | 签名 | 说明 |
|------|------|------|
| `asFile()` | `link.asFile(): file` | 转成文件对象 |
| `linksTo()` | `link.linksTo(file): boolean` | 是否链接到指定文件 |

## 对象函数

| 函数 | 签名 | 说明 |
|------|------|------|
| `isEmpty()` | `object.isEmpty(): boolean` | 是否没有属性 |
| `keys()` | `object.keys(): list` | 返回键列表 |
| `values()` | `object.values(): list` | 返回值列表 |

## 正则函数

| 函数 | 签名 | 说明 |
|------|------|------|
| `matches()` | `regexp.matches(string): boolean` | 判断是否匹配 |
