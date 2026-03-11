---
name: clothing-image-commercializer
description: 全自动批量处理服装平铺照片，输出电商级纯白底商品图。读取输入文件夹中的随手拍服装照片，经去背景、清晰化、校色、姿态整理、居中构图、缩放后输出到目标文件夹。
---

# 服装图片商品化

## 目标

| 项 | 说明 |
|----|------|
| 输入 | `folderA` 中的随手拍服装平铺照片 |
| 输出 | `folderB` 中的电商级纯白底商品图 |
| 执行者 | AI Agent，全自动无人值守 |

## 铁律

优先级高于一切处理标准。违反任一条即判定输出无效。

1. **忠实原物**：款式、结构、细节不可篡改。
2. **细节保真**：纽扣、logo、面料纹理、缝线必须保留，不可模糊、丢失或虚构。
3. **校色不改色**：允许校正白平衡/色温偏差；禁止改变色相（如蓝→绿、红→橙）。
4. **姿态可调不可改**：允许拉平皱褶、摆正摆放；禁止改变款式轮廓。
5. **模糊必须清晰化**：模糊区域必须增强清晰度，输出图不允许存在模糊区域。

## 输入规范

| 项 | 要求 |
|----|------|
| 来源 | `folderA` |
| 格式 | PNG 或 JPG |
| 内容 | 单件服装，平铺拍摄 |
| 背景 | 不限 |

### 跳过条件

遇到以下情况，跳过该文件并记录原因：

- 非 PNG/JPG 格式。
- 图片中包含多件服装。
- 图片中无可识别的服装。

## 输出规范

| 项 | 要求 |
|----|------|
| 目标 | `folderB` |
| 格式 | PNG |
| 尺寸 | 1200 × 1200 px |
| 命名 | 原文件名，扩展名统一为 `.png` |
| 背景 | 纯白 #FFFFFF |

## 处理标准

每条仅在此处定义，全文引用编号。

| 编号 | 步骤 | 标准 | 关联铁律 |
|------|------|------|----------|
| P1 | 去除背景 | 移除原背景 → 纯白 #FFFFFF。边缘干净，无残留/抠图痕迹。 | — |
| P2 | 清晰化 | 增强模糊区域，整体清晰锐利。 | 铁律 5 |
| P3 | 校色 | 校正白平衡/色温，还原真实颜色。禁改色相。 | 铁律 3 |
| P4 | 姿态整理 | 拉平皱褶、摆正摆放，呈现平整平铺效果。禁改款式轮廓。 | 铁律 4 |
| P5 | 居中构图 | 服装居中，四周边距每侧 ≥60px，各侧差值 ≤20px。 | — |
| P6 | 缩放输出 | 1200×1200px，服装不可裁切，PNG 格式。 | 铁律 1 |

## 验收条件

**样品基准**：`folderB/_sample/sample.png`。

**合格定义**：Q1–Q6 全部通过 = 合格。任一不通过 = 不合格。

| 编号 | 条件 | 关联标准 |
|------|------|----------|
| Q1 | 背景纯白，无残留/抠图痕迹 | P1 |
| Q2 | 清晰度 ≥ 样品图 | P2 |
| Q3 | 颜色与原图一致，色相未改 | P3 |
| Q4 | 细节与原图一致，未丢失/虚构 | 铁律 1, 2 |
| Q5 | 构图居中，边距符合 P5 | P5 |
| Q6 | 服装完整，未裁切 | P6 |

**不合格处理**：不输出到 `folderB`，记录文件名 + 不合格编号（Q1–Q6）。

## 工作流程

```
STEP 1 — 初始化:
  sample ← load(folderB/_sample/sample.png)
  IF sample 不存在:
    ABORT "ERROR: 样品图 folderB/_sample/sample.png 不存在，无法执行质量验收"

  files ← scan(folderA, ext=[png, jpg])
  IF files 为空:
    GOTO STEP 4（生成空报告）

  FOR EACH f IN files:
    IF f 不符合跳过条件:
      skipped.add(f, reason)
      CONTINUE
    queue.add(f)

  PRINT "待处理文件清单:", queue

STEP 2 — 逐张处理:
  FOR EACH f IN queue:
    img ← load(f)
    img ← P1(img)  // 去除背景
    img ← P2(img)  // 清晰化
    img ← P3(img)  // 校色
    img ← P4(img)  // 姿态整理
    img ← P5(img)  // 居中构图
    img ← P6(img)  // 缩放输出
    GOTO STEP 3（验收 img, f）

STEP 3 — 逐张验收:
  passed ← check(img, Q1..Q6, sample)
  IF passed:
    save(img, folderB/{f.stem}.png)
    success.add(f)
  ELSE:
    fail.add(f, failed_Q_codes)

STEP 4 — 生成报告:
  PRINT:
    处理总数: queue.size
    成功: success.count + success.filenames
    失败: fail.count + fail.filenames + fail.Q_codes
    跳过: skipped.count + skipped.filenames + skipped.reasons
```

## Initialization

接收两个参数后立即执行 STEP 1：

| 参数 | 说明 |
|------|------|
| `folderA` | 输入文件夹路径（含随手拍服装照片） |
| `folderB` | 输出文件夹路径（含 `_sample/sample.png`） |
