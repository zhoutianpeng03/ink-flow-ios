# 笔记详情页面 - 独立组件

这是从 FSNotes iOS 应用中提取的笔记详情编辑页面，可以作为独立组件使用。

## 功能特性

- 富文本编辑
- Markdown 语法支持
- 文本格式化工具栏（加粗、斜体、标题等）
- 图片插入和预览
- 撤销/重做功能
- 代码块高亮
- 待办事项列表

## 文件结构

```
NoteDetailPage/
├── Core/                   # 核心文件
│   ├── NoteDetailViewController.swift
│   ├── SimpleEditTextView.swift
│   └── SimpleNote.swift
├── Views/                  # 视图组件
│   ├── SimpleToolbar.swift
│   └── SimpleTextFormatter.swift
├── Extensions/             # 扩展文件
│   ├── UIFont+Extensions.swift
│   └── UIColor+Extensions.swift
├── Resources/              # 资源文件
│   └── Assets.xcassets
└── Demo/                   # 演示项目
    ├── AppDelegate.swift
    ├── ViewController.swift
    └── Main.storyboard
```

## 使用方法

1. 将 `NoteDetailViewController` 添加到你的项目中
2. 创建一个 `SimpleNote` 实例
3. 将笔记传递给控制器并展示

```swift
let note = SimpleNote(title: "我的笔记", content: "这是笔记内容")
let editor = NoteDetailViewController()
editor.note = note
navigationController?.pushViewController(editor, animated: true)
```

## 依赖要求

- iOS 13.0+
- Swift 5.0+
- UIKit

## 许可证

基于 FSNotes 项目提取，遵循原项目许可证。
