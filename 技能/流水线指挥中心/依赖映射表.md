# 附件一：依赖映射与 Discovery 规则

> **权威表**（提取自 PLAYBOOK §3.3）。读法（假设"我"= 当前节点编号）：
> - **正向查下游**：找 `生产节点 = 我` 的所有行 → 消费节点列 = 直接下游。
> - **反向查上游**：找 `消费节点列包含我` 的所有行 → 该行产物 = 我的上游输入，其生产节点 = 上游节点。
>
> **双产物（2）**：layout_blueprint 与 style_guidebook 各自独立产出 discovery，任一存在即触发下游。

| 文件名 | 性质 | 生产节点 | 消费节点 |
|--------|------|--------|--------|
| `2+4_project_context.md` | 参考 | 1 | 2, 4 |
| `3+5+6a+6b_layout_blueprint.md` | 参考 | 2 | 3, 5, 6a, 6b |
| `3+6a+6b_style_guidebook.pen` | 参考 | 2 | 3, 6a, 6b |
| `5+6a+6b_static_ui_mock.pen` | 参考 | 3 | 5, 6a, 6b |
| `infra_spec.md` | 🚩生产 | 4 | 5, 6a, 6b, 6c |
| `prototype/` | 参考 | 5 | （用完即弃） |
| `6a_interaction_map.md` | 参考 | 5 | 6a |
| `6b+6c_code_blueprint.md` | 参考 | 6a | 6b, 6c |
| 逐页生产代码 | 🚩生产 | 6b | 6c |
| 完整前端应用 | 🚩生产 | 6c | （终点） |
| `discovery_to_*.md` | 发现清单 | 各节点 | 对应上/下游节点 |

产物变更时产出 `discovery_to_<产物基名>.md`，统一存放 `design/_discovery/`。正向通知下游更新，反向回流上游修订。

## discovery 文件模板

```markdown
# Discovery: <目标产物基名>

| # | 位置（页面/组件/章节） | 问题描述 | 建议处理方式 |
|---|----------------------|---------|------------|
| 1 | ... | ... | ... |
```
