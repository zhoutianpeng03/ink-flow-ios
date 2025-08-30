//
//  DemoViewController.swift
//  NoteDetailPageDemo
//
//  演示应用的主视图控制器
//

import UIKit

class DemoViewController: UIViewController {
    
    // MARK: - Properties
    private var sampleNotes: [SimpleNote] = []
    
    // MARK: - UI Components
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "NoteCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        createSampleNotes()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        title = "笔记详情页面演示"
        view.backgroundColor = .systemBackground
        
        view.addSubview(tableView)
        
        // 导航栏按钮
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addNotePressed)
        )
        
        // 添加介绍按钮
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "介绍",
            style: .plain,
            target: self,
            action: #selector(showIntroduction)
        )
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func createSampleNotes() {
        sampleNotes = [
            SimpleNote(title: "欢迎使用笔记编辑器", content: """
# 欢迎使用笔记编辑器

这是一个从 **FSNotes** 项目中提取的简化版笔记编辑器。

## 主要功能

- **富文本编辑**：支持加粗、斜体等格式
- **Markdown 支持**：原生支持 Markdown 语法
- **工具栏**：便捷的格式化工具
- **图片插入**：支持从相册选择图片
- **撤销/重做**：完整的编辑历史管理

## 使用方法

1. 点击工具栏按钮应用格式
2. 选中文字后点击格式按钮
3. 使用 Markdown 语法直接输入

*体验一下吧！*
"""),
            
            SimpleNote(title: "Markdown 语法示例", content: """
# 标题示例

## 二级标题
### 三级标题

**粗体文本**
*斜体文本*
***粗斜体文本***

## 列表

### 无序列表
- 第一项
- 第二项
- 第三项

### 有序列表
1. 第一项
2. 第二项
3. 第三项

## 代码

内联代码：`print("Hello, World!")`

```swift
// 代码块示例
func greet(name: String) -> String {
    return "Hello, \\(name)!"
}
```

## 引用

> 这是一个引用文本
> 可以有多行

## 链接

[GitHub](https://github.com)
"""),
            
            SimpleNote(title: "待办事项列表", content: """
# 今日任务

- [x] 完成笔记编辑器开发
- [x] 添加工具栏功能
- [ ] 测试图片插入功能
- [ ] 优化用户界面
- [ ] 编写使用文档

## 本周计划

- [ ] 添加更多格式化选项
- [ ] 支持表格编辑
- [ ] 实现云端同步
- [ ] 添加主题切换功能

**记住**：每天进步一点点！
"""),
            
            SimpleNote(title: "空白笔记", content: "")
        ]
    }
    
    // MARK: - Actions
    @objc private func addNotePressed() {
        let newNote = SimpleNote(title: "新建笔记", content: "开始编写你的想法...")
        sampleNotes.insert(newNote, at: 0)
        
        let noteDetailVC = NoteDetailViewController()
        noteDetailVC.note = newNote
        
        navigationController?.pushViewController(noteDetailVC, animated: true)
    }
    
    @objc private func showIntroduction() {
        let alertController = UIAlertController(
            title: "笔记详情页面演示",
            message: """
这是一个从 FSNotes iOS 应用中提取的简化版笔记编辑器。

特性：
• 富文本编辑和 Markdown 支持
• 直观的格式化工具栏
• 图片插入功能
• 撤销/重做操作
• 响应式设计

点击任意笔记开始体验编辑功能！
""",
            preferredStyle: .alert
        )
        
        alertController.addAction(UIAlertAction(title: "开始体验", style: .default))
        
        present(alertController, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension DemoViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sampleNotes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NoteCell", for: indexPath)
        let note = sampleNotes[indexPath.row]
        
        cell.textLabel?.text = note.title.isEmpty ? "无标题" : note.title
        cell.detailTextLabel?.text = note.getPlainText().isEmpty ? "空白笔记" : String(note.getPlainText().prefix(50))
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension DemoViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let note = sampleNotes[indexPath.row]
        let noteDetailVC = NoteDetailViewController()
        noteDetailVC.note = note
        
        navigationController?.pushViewController(noteDetailVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            sampleNotes.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "删除"
    }
}
