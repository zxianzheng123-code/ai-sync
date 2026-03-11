---
name: obsidian-cli
description: 通过 Obsidian CLI 与运行中的 Obsidian vault 交互，支持读取、创建、搜索、修改笔记，以及插件和主题开发调试。用户提到操作 vault、命令行管理笔记、调试插件或主题时使用。
---

# Obsidian CLI

## 文档定位

本 skill 用来通过 `obsidian` 命令行与正在运行的 Obsidian 实例交互。

前提条件：

- Obsidian 已经打开。
- 本机已安装并可调用 `obsidian` CLI。

## 工作流

1. 先确认目标是哪个 vault、哪个文件。
2. 再决定动作：读、写、搜、追加、改属性、查任务、查标签。
3. 写入后做一次结果核对，避免误改错文件。
4. 如果是在开发插件或主题，改完后按“重载 → 查错 → 验证”顺序执行。

## 命令参考

先跑下面这条，拿到本机实时命令说明：

```bash
obsidian help
```

官方文档：

https://help.obsidian.md/cli

## 语法规则

### 参数

参数使用 `=` 传值。

如果值里有空格，要加引号：

```bash
obsidian create name="我的笔记" content="你好，世界"
```

### 标志位

布尔开关不需要值：

```bash
obsidian create name="我的笔记" silent overwrite
```

### 多行内容

换行使用 `\n`，制表使用 `\t`。

## 文件定位

很多命令支持 `file` 或 `path`。

- `file=<name>`：按 wikilink 方式解析，只写文件名即可。
- `path=<path>`：按 vault 根目录下的精确路径解析。

未传这两个参数时，默认操作当前激活文件。

## Vault 定位

默认命中最近聚焦的 vault。

如果要明确指定，先传 `vault=<name>`：

```bash
obsidian vault="My Vault" search query="project"
```

## 常用命令

```bash
obsidian read file="我的笔记"
obsidian create name="新笔记" content="# 标题" template="模板" silent
obsidian append file="我的笔记" content="新的一行"
obsidian search query="搜索词" limit=10
obsidian daily:read
obsidian daily:append content="- [ ] 新任务"
obsidian property:set name="status" value="done" file="我的笔记"
obsidian tasks daily todo
obsidian tags sort=count counts
obsidian backlinks file="我的笔记"
```

补充规则：

- 任何命令都可以加 `--copy` 把输出复制到剪贴板。
- `silent` 用来避免自动打开文件。
- 列表类命令可加 `total` 获取总数。

## 插件与主题开发

### 推荐验证顺序

1. 重载插件，确保新代码生效。
2. 检查错误，确认没有报错。
3. 用截图或 DOM 检查视觉结果。
4. 查看控制台输出，确认没有异常日志。

### 常用开发命令

#### 重载插件

```bash
obsidian plugin:reload id=my-plugin
```

#### 查看错误

```bash
obsidian dev:errors
```

#### 截图或看 DOM

```bash
obsidian dev:screenshot path=screenshot.png
obsidian dev:dom selector=".workspace-leaf" text
```

#### 查看控制台

```bash
obsidian dev:console level=error
```

#### 在应用上下文里执行 JavaScript

```bash
obsidian eval code="app.vault.getFiles().length"
```

#### 查看 CSS 属性

```bash
obsidian dev:css selector=".workspace-leaf" prop=background-color
```

#### 开关移动端模拟

```bash
obsidian dev:mobile on
```
