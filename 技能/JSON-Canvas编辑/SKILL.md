---
name: json-canvas
description: 创建和编辑 JSON Canvas 文件（.canvas），支持节点、连线、分组和布局。用户处理 .canvas 文件、思维导图、流程图或 Obsidian Canvas 时使用。
---

# JSON Canvas

## 文档定位

本 skill 用来创建和修改 `.canvas` 文件。

目标是保证三件事：

- 结构合法
- 引用不悬空
- 画布布局可读

## 文件结构

`.canvas` 文件遵循 [JSON Canvas Spec 1.0](https://jsoncanvas.org/spec/1.0/)。

顶层结构如下：

```json
{
  "nodes": [],
  "edges": []
}
```

- `nodes`：节点数组，可省略但通常保留。
- `edges`：连线数组，可省略但通常保留。

## 工作流

### 新建画布

1. 创建 `.canvas` 文件。
2. 写入基础结构。
3. 为每个节点生成唯一 ID。
4. 补齐节点必填字段。
5. 如果有关系，再补 `edges`。
6. 最后校验 JSON、ID 唯一性和连线引用。

### 在已有画布里加节点

1. 读取并解析原始 `.canvas`。
2. 生成不冲突的新 ID。
3. 选一个不遮挡旧节点的位置。
4. 追加新节点。
5. 如有必要，再补连线。
6. 再做一次完整校验。

### 连接两个节点

1. 确认源节点和目标节点 ID。
2. 生成边 ID。
3. 写入 `fromNode` 和 `toNode`。
4. 需要时补 `fromSide`、`toSide`、`label`。
5. 校验引用是否都指向真实节点。

### 修改已有画布

1. 先解析 JSON。
2. 按 `id` 找到目标节点或连线。
3. 只改目标字段。
4. 回写后重新校验。

## 节点

节点数组的顺序会影响层级：

- 前面的节点在下层
- 后面的节点在上层

### 通用字段

| 字段 | 必填 | 类型 | 说明 |
|------|------|------|------|
| `id` | 是 | string | 唯一 16 位十六进制 ID |
| `type` | 是 | string | `text`、`file`、`link`、`group` |
| `x` | 是 | integer | 左上角 X 坐标 |
| `y` | 是 | integer | 左上角 Y 坐标 |
| `width` | 是 | integer | 宽度 |
| `height` | 是 | integer | 高度 |
| `color` | 否 | canvasColor | `"1"` 到 `"6"`，或十六进制颜色 |

### 文本节点

文本节点必须有 `text`：

```json
{
  "id": "6f0ad84f44ce9c17",
  "type": "text",
  "x": 0,
  "y": 0,
  "width": 400,
  "height": 200,
  "text": "# 标题\n\n这是正文。"
}
```

注意换行：

- JSON 里用 `\n`
- 不要写成字面量 `\\n`

### 文件节点

文件节点必须有 `file`：

```json
{
  "id": "a1b2c3d4e5f67890",
  "type": "file",
  "x": 500,
  "y": 0,
  "width": 400,
  "height": 300,
  "file": "Attachments/diagram.png"
}
```

可选字段：

- `subpath`：定位到标题或 block，值以 `#` 开头

### 链接节点

链接节点必须有 `url`：

```json
{
  "id": "c3d4e5f678901234",
  "type": "link",
  "x": 1000,
  "y": 0,
  "width": 400,
  "height": 200,
  "url": "https://obsidian.md"
}
```

### 分组节点

分组节点用来包住一组节点：

```json
{
  "id": "d4e5f6789012345a",
  "type": "group",
  "x": -50,
  "y": -50,
  "width": 1000,
  "height": 600,
  "label": "项目概览",
  "color": "4"
}
```

常用可选字段：

- `label`
- `background`
- `backgroundStyle`

## 连线

连线依赖 `fromNode` 和 `toNode` 把两个节点接起来。

| 字段 | 必填 | 类型 | 默认值 | 说明 |
|------|------|------|--------|------|
| `id` | 是 | string | - | 边 ID |
| `fromNode` | 是 | string | - | 源节点 |
| `fromSide` | 否 | string | - | `top`、`right`、`bottom`、`left` |
| `fromEnd` | 否 | string | `none` | `none` 或 `arrow` |
| `toNode` | 是 | string | - | 目标节点 |
| `toSide` | 否 | string | - | `top`、`right`、`bottom`、`left` |
| `toEnd` | 否 | string | `arrow` | `none` 或 `arrow` |
| `color` | 否 | canvasColor | - | 连线颜色 |
| `label` | 否 | string | - | 连线说明文字 |

```json
{
  "id": "0123456789abcdef",
  "fromNode": "6f0ad84f44ce9c17",
  "fromSide": "right",
  "toNode": "a1b2c3d4e5f67890",
  "toSide": "left",
  "toEnd": "arrow",
  "label": "流向"
}
```

## 颜色

`canvasColor` 支持两种写法：

- 预设色：`"1"` 到 `"6"`
- 十六进制颜色：如 `"#FF0000"`

| 预设值 | 含义 |
|--------|------|
| `"1"` | 红 |
| `"2"` | 橙 |
| `"3"` | 黄 |
| `"4"` | 绿 |
| `"5"` | 青 |
| `"6"` | 紫 |

注意：

这些预设色只代表色系，不代表固定品牌色。

## ID 规则

推荐使用 16 位小写十六进制字符串：

```text
6f0ad84f44ce9c17
a3b2c1d0e9f8a7b6
```

## 布局建议

- 坐标允许为负数。
- `x` 向右增长，`y` 向下增长。
- 节点之间建议留 50 到 100px 间距。
- 分组内部建议留 20 到 50px 内边距。
- 尽量按 10 或 20 的倍数对齐。

| 节点类型 | 建议宽度 | 建议高度 |
|----------|----------|----------|
| 小文本 | 200-300 | 80-150 |
| 中文本 | 300-450 | 150-300 |
| 大文本 | 400-600 | 300-500 |
| 文件预览 | 300-500 | 200-400 |
| 链接预览 | 250-400 | 100-200 |

## 校验清单

改完 `.canvas` 后，至少检查这些点：

1. 所有 `id` 在 `nodes` 和 `edges` 范围内都唯一。
2. 每个 `fromNode` / `toNode` 都能在节点数组里找到。
3. 不同节点类型的必填字段都齐全。
4. `type` 只使用允许值。
5. `fromSide` / `toSide` 只使用四个方向值。
6. `fromEnd` / `toEnd` 只使用 `none` 或 `arrow`。
7. 颜色值要么是 `"1"` 到 `"6"`，要么是合法十六进制。
8. JSON 必须能成功解析。

如果校验失败，优先检查：

- 重复 ID
- 悬空连线
- 文本里的非法换行
- JSON 逗号或引号错误

## 示例

完整示例见 [参考资料/示例.md](参考资料/示例.md)。

## 引用

- [JSON Canvas Spec 1.0](https://jsoncanvas.org/spec/1.0/)
- [JSON Canvas GitHub](https://github.com/obsidianmd/jsoncanvas)
