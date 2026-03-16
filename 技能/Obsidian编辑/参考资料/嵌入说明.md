# Embeds 参考

## 嵌入笔记

```markdown
![[笔记名]]
![[笔记名#标题]]
![[笔记名#^block-id]]
```

## 嵌入图片

```markdown
![[image.png]]
![[image.png|640x480]]    宽 x 高
![[image.png|300]]        仅宽度，自动保持比例
```

## 外部图片

```markdown
![替代文本](https://example.com/image.png)
![替代文本|300](https://example.com/image.png)
```

## 嵌入音频

```markdown
![[audio.mp3]]
![[audio.ogg]]
```

## 嵌入 PDF

```markdown
![[document.pdf]]
![[document.pdf#page=3]]
![[document.pdf#height=400]]
```

## 嵌入列表

```markdown
![[笔记名#^list-id]]
```

列表需要先定义 block ID：

```markdown
- 条目 1
- 条目 2
- 条目 3

^list-id
```

## 嵌入搜索结果

````markdown
```query
tag:#project status:done
```
````
