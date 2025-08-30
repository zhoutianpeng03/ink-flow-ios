# 使用说明

## 集成指南

### 1. 将文件添加到项目

将以下文件夹复制到你的 iOS 项目中：

```
Core/
├── NoteDetailViewController.swift
├── SimpleEditTextView.swift
└── SimpleNote.swift

Views/
├── SimpleToolbar.swift
└── SimpleTextFormatter.swift

Extensions/
├── UIColor+Extensions.swift
└── UIFont+Extensions.swift
```

### 2. 基本使用

```swift
import UIKit

// 创建笔记
let note = SimpleNote(title: "我的笔记", content: "这里是笔记内容")

// 创建编辑器
let editor = NoteDetailViewController()
editor.note = note

// 展示编辑器
navigationController?.pushViewController(editor, animated: true)

// 或者模态展示
let navController = UINavigationController(rootViewController: editor)
present(navController, animated: true)
```

### 3. 高级用法

#### 自定义主题

```swift
// 在 UIColor+Extensions.swift 中修改主题颜色
extension UIColor {
    static var mainTheme: UIColor {
        return .systemPurple  // 自定义主题色
    }
}
```

#### 自定义字体

```swift
// 在 UIFont+Extensions.swift 中修改默认字体
extension UIFont {
    static var noteFont: UIFont {
        return UIFont(name: "YourCustomFont", size: 16) ?? UIFont.systemFont(ofSize: 16)
    }
}
```

#### 监听笔记变化

```swift
class MyViewController: UIViewController {
    func presentNoteEditor() {
        let note = SimpleNote(title: "测试", content: "内容")
        let editor = NoteDetailViewController()
        editor.note = note
        
        // 在编辑器消失后检查笔记内容
        editor.completion = { [weak self] updatedNote in
            // 处理更新后的笔记
            self?.saveNote(updatedNote)
        }
        
        navigationController?.pushViewController(editor, animated: true)
    }
}
```

## 工具栏功能

### 格式化按钮

- **B**: 加粗文本
- **I**: 斜体文本
- **H**: 插入标题
- **•**: 插入列表
- **{}**: 插入代码
- **📷**: 插入图片
- **↶**: 撤销
- **↷**: 重做

### Markdown 语法支持

```markdown
# 标题 1
## 标题 2
### 标题 3

**粗体文本**
*斜体文本*

- 无序列表项
- 另一个列表项

1. 有序列表项
2. 另一个有序列表项

`内联代码`

```代码块```

> 引用文本
```

## API 参考

### SimpleNote

```swift
class SimpleNote {
    var title: String
    var content: NSMutableAttributedString
    var createdAt: Date
    var modifiedAt: Date
    var isMarkdown: Bool
    
    init(title: String, content: String)
    func updateContent(_ newContent: NSAttributedString)
    func updateTitle(_ newTitle: String)
    func getPlainText() -> String
    func save()
}
```

### NoteDetailViewController

```swift
class NoteDetailViewController: UIViewController {
    var note: SimpleNote?
    
    // 自定义完成回调
    var completion: ((SimpleNote) -> Void)?
}
```

### SimpleEditTextView

```swift
class SimpleEditTextView: UITextView {
    var note: SimpleNote?
    
    func loadNote(_ note: SimpleNote)
    func saveNote()
    func toggleBold()
    func toggleItalic()
}
```

## 自定义和扩展

### 添加新的格式化功能

1. 在 `SimpleToolbar.swift` 中添加新按钮
2. 在 `SimpleTextFormatter.swift` 中添加格式化逻辑
3. 在 `SimpleToolbarDelegate` 中添加新方法

### 支持更多文件格式

可以通过修改 `SimpleNote` 类来支持不同的文件格式：

```swift
enum NoteFormat {
    case markdown
    case richText
    case html
    case plainText
}

extension SimpleNote {
    func exportAs(_ format: NoteFormat) -> String {
        // 实现格式转换逻辑
    }
}
```

## 故障排除

### 常见问题

1. **图片无法显示**: 确保已添加相册访问权限到 Info.plist
2. **工具栏按钮无响应**: 检查 delegate 连接是否正确
3. **字体显示异常**: 确保自定义字体文件已正确添加到项目中

### 性能优化

- 对于大型文档，考虑实现懒加载
- 图片处理时注意内存管理
- 使用 NSRange 而非 String.Index 提升性能

## 许可证

本项目基于 FSNotes 开源项目提取，遵循原项目的许可证条款。
