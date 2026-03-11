# Properties（Frontmatter）参考

Properties 使用 YAML frontmatter，写在笔记开头：

```yaml
---
title: 我的笔记标题
date: 2024-01-15
tags:
  - project
  - important
aliases:
  - 我的笔记
  - 备用名称
cssclasses:
  - custom-class
status: in-progress
rating: 4.5
completed: false
due: 2024-02-01T14:30:00
---
```

## 属性类型

| 类型 | 示例 |
|------|------|
| 文本 | `title: 我的标题` |
| 数字 | `rating: 4.5` |
| 复选框 | `completed: true` |
| 日期 | `date: 2024-01-15` |
| 日期时间 | `due: 2024-01-15T14:30:00` |
| 列表 | `tags: [one, two]` 或 YAML 列表 |
| 链接 | `related: "[[其他笔记]]"` |

## 默认属性

- `tags`：笔记标签，可搜索，也会出现在图谱视图
- `aliases`：笔记别名，用于链接建议
- `cssclasses`：给笔记阅读/编辑视图附加 CSS class

## 标签

```markdown
#tag
#nested/tag
#tag-with-dashes
#tag_with_underscores
```

标签可包含：

- 各类语言字母
- 数字（不能放首位）
- 下划线 `_`
- 连字符 `-`
- 斜杠 `/`

在 frontmatter 中也可以这样写：

```yaml
---
tags:
  - tag1
  - nested/tag2
---
```
