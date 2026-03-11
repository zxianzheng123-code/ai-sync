---
name: defuddle
description: 用 Defuddle CLI 从网页提取干净的 Markdown 正文，去掉导航、广告和杂项内容，减少 token 消耗。用户提供 URL 并希望阅读、分析文档、文章、博客或普通网页时优先使用。
---

# Defuddle

## 文档定位

本 skill 用来把网页正文提取成干净、可读的 Markdown。

适用对象：

- 在线文档
- 博客文章
- 普通内容页

不适合的对象：

- 需要真实浏览器交互的页面
- 强依赖登录态的页面
- 动态加载后才完整的复杂应用界面

## 规则

- 普通网页优先用 Defuddle，不优先用 WebFetch。
- 默认输出 Markdown，除非用户明确要 JSON 或 HTML。
- 如本机未安装 Defuddle，先安装再执行。

## 安装

```bash
npm install -g defuddle
```

## 常用命令

### 提取为 Markdown

```bash
defuddle parse <url> --md
```

### 保存到文件

```bash
defuddle parse <url> --md -o content.md
```

### 提取单个元数据字段

```bash
defuddle parse <url> -p title
defuddle parse <url> -p description
defuddle parse <url> -p domain
```

## 输出格式

| 参数 | 输出 |
|------|------|
| `--md` | Markdown，默认推荐 |
| `--json` | JSON，包含 HTML 和 Markdown |
| 不传格式参数 | HTML |
| `-p <name>` | 单个元数据字段 |
