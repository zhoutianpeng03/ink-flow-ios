//
//  SimpleToolbar.swift
//  NoteDetailPage
//
//  简化的编辑工具栏
//

import UIKit

protocol SimpleToolbarDelegate: AnyObject {
    func didTapBold()
    func didTapItalic()
    func didTapHeader()
    func didTapList()
    func didTapCode()
    func didTapImage()
    func didTapUndo()
    func didTapRedo()
}

class SimpleToolbar: UIToolbar {
    
    weak var toolbarDelegate: SimpleToolbarDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupToolbar()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupToolbar()
    }
    
    private func setupToolbar() {
        backgroundColor = .systemBackground
        tintColor = .systemBlue
        
        let items = createToolbarItems()
        setItems(items, animated: false)
    }
    
    private func createToolbarItems() -> [UIBarButtonItem] {
        var items: [UIBarButtonItem] = []
        
        // 加粗按钮
        let boldButton = UIBarButtonItem(
            image: UIImage(systemName: "bold"),
            style: .plain,
            target: self,
            action: #selector(boldPressed)
        )
        boldButton.accessibilityLabel = "加粗"
        items.append(boldButton)
        
        // 斜体按钮
        let italicButton = UIBarButtonItem(
            image: UIImage(systemName: "italic"),
            style: .plain,
            target: self,
            action: #selector(italicPressed)
        )
        italicButton.accessibilityLabel = "斜体"
        items.append(italicButton)
        
        // 分隔符
        items.append(createSpacer())
        
        // 标题按钮
        let headerButton = UIBarButtonItem(
            image: UIImage(systemName: "textformat.size"),
            style: .plain,
            target: self,
            action: #selector(headerPressed)
        )
        headerButton.accessibilityLabel = "标题"
        items.append(headerButton)
        
        // 列表按钮
        let listButton = UIBarButtonItem(
            image: UIImage(systemName: "list.bullet"),
            style: .plain,
            target: self,
            action: #selector(listPressed)
        )
        listButton.accessibilityLabel = "列表"
        items.append(listButton)
        
        // 分隔符
        items.append(createSpacer())
        
        // 代码按钮
        let codeButton = UIBarButtonItem(
            image: UIImage(systemName: "curlybraces"),
            style: .plain,
            target: self,
            action: #selector(codePressed)
        )
        codeButton.accessibilityLabel = "代码"
        items.append(codeButton)
        
        // 图片按钮
        let imageButton = UIBarButtonItem(
            image: UIImage(systemName: "photo"),
            style: .plain,
            target: self,
            action: #selector(imagePressed)
        )
        imageButton.accessibilityLabel = "图片"
        items.append(imageButton)
        
        // 弹性空间
        items.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil))
        
        // 撤销按钮
        let undoButton = UIBarButtonItem(
            image: UIImage(systemName: "arrow.uturn.backward"),
            style: .plain,
            target: self,
            action: #selector(undoPressed)
        )
        undoButton.accessibilityLabel = "撤销"
        items.append(undoButton)
        
        // 重做按钮
        let redoButton = UIBarButtonItem(
            image: UIImage(systemName: "arrow.uturn.forward"),
            style: .plain,
            target: self,
            action: #selector(redoPressed)
        )
        redoButton.accessibilityLabel = "重做"
        items.append(redoButton)
        
        return items
    }
    
    private func createSpacer() -> UIBarButtonItem {
        let spacer = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        spacer.width = 20
        return spacer
    }
    
    // MARK: - Action Methods
    @objc private func boldPressed() {
        toolbarDelegate?.didTapBold()
    }
    
    @objc private func italicPressed() {
        toolbarDelegate?.didTapItalic()
    }
    
    @objc private func headerPressed() {
        toolbarDelegate?.didTapHeader()
    }
    
    @objc private func listPressed() {
        toolbarDelegate?.didTapList()
    }
    
    @objc private func codePressed() {
        toolbarDelegate?.didTapCode()
    }
    
    @objc private func imagePressed() {
        toolbarDelegate?.didTapImage()
    }
    
    @objc private func undoPressed() {
        toolbarDelegate?.didTapUndo()
    }
    
    @objc private func redoPressed() {
        toolbarDelegate?.didTapRedo()
    }
}

// MARK: - Convenience Extensions
extension SimpleToolbar {
    func updateUndoRedoButtons(canUndo: Bool, canRedo: Bool) {
        guard let items = items else { return }
        
        for item in items {
            if item.action == #selector(undoPressed) {
                item.isEnabled = canUndo
            } else if item.action == #selector(redoPressed) {
                item.isEnabled = canRedo
            }
        }
    }
}
