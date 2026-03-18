# MCP 接入总表

> 统一根路径：`/Users/zxz/Desktop/ai-sync/`

## 读取顺序

1. 项目的 `AGENTS.md` / `CLAUDE.md`
2. `MCP/MCP接入总表.md`
3. `MCP/项目清单/<project-id>.md`

## 项目侧引用模板

```markdown
## MCP 系统

本项目的 `project_id` 是 `<project-id>`；执行涉及外部工具的任务前，先读取 `/Users/zxz/Desktop/ai-sync/MCP/MCP接入总表.md`，再按该 `project_id` 继续读取对应项目清单。
```

| project_id | 项目名 | 清单路径 | 是否默认回退 |
| --- | --- | --- | --- |
| default | 全局默认集 | `MCP/项目清单/default.md` | 是 |

## 回退规则

- 有专属清单：读取 `MCP/项目清单/<project-id>.md`
- 无专属清单：回退到 `MCP/项目清单/default.md`
