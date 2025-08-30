//
//  SimpleTextFormatter.swift
//  NoteDetailPage
//
//  简化的文本格式化器
//

import UIKit

class SimpleTextFormatter {
    
    private weak var textView: SimpleEditTextView?
    private var note: SimpleNote?
    
    init(textView: SimpleEditTextView, note: SimpleNote) {
        self.textView = textView
        self.note = note
    }
    
    // MARK: - Markdown 格式化方法
    
    func toggleBold() {
        guard let textView = textView else { return }
        
        if note?.isMarkdown == true {
            toggleMarkdownFormat(prefix: "**", suffix: "**")
        } else {
            textView.toggleBold()
        }
    }
    
    func toggleItalic() {
        guard let textView = textView else { return }
        
        if note?.isMarkdown == true {
            toggleMarkdownFormat(prefix: "*", suffix: "*")
        } else {
            textView.toggleItalic()
        }
    }
    
    func insertHeader() {
        insertMarkdownAtLineStart(prefix: "# ")
    }
    
    func insertList() {
        insertMarkdownAtLineStart(prefix: "- ")
    }
    
    func insertCodeBlock() {
        if let range = textView?.selectedRange, range.length > 0 {
            // 选中文本时，添加代码块格式
            toggleMarkdownFormat(prefix: "```\n", suffix: "\n```")
        } else {
            // 无选中文本时，插入内联代码
            toggleMarkdownFormat(prefix: "`", suffix: "`")
        }
    }
    
    func insertImage() {
        let imageMarkdown = "![图片描述](图片链接)"
        insertText(imageMarkdown)
        
        // 选中描述部分便于编辑
        if let textView = textView {
            let location = textView.selectedRange.location - imageMarkdown.count + 2
            textView.selectedRange = NSRange(location: location, length: 4)
        }
    }
    
    // MARK: - 私有方法
    
    private func toggleMarkdownFormat(prefix: String, suffix: String) {
        guard let textView = textView else { return }
        
        let selectedRange = textView.selectedRange
        let text = textView.text ?? ""
        
        if selectedRange.length == 0 {
            // 无选中文本，插入格式并将光标放在中间
            let insertText = prefix + suffix
            textView.insertText(insertText, at: selectedRange)
            
            let newLocation = selectedRange.location + prefix.count
            textView.selectedRange = NSRange(location: newLocation, length: 0)
        } else {
            // 有选中文本，检查是否已经有格式
            let selectedText = String(text[text.index(text.startIndex, offsetBy: selectedRange.location)..<text.index(text.startIndex, offsetBy: selectedRange.location + selectedRange.length)])
            
            if selectedText.hasPrefix(prefix) && selectedText.hasSuffix(suffix) {
                // 移除格式
                let unformattedText = String(selectedText.dropFirst(prefix.count).dropLast(suffix.count))
                textView.replaceText(in: selectedRange, with: unformattedText)
            } else {
                // 添加格式
                let formattedText = prefix + selectedText + suffix
                textView.replaceText(in: selectedRange, with: formattedText)
            }
        }
    }
    
    private func insertMarkdownAtLineStart(prefix: String) {
        guard let textView = textView else { return }
        
        let text = textView.text ?? ""
        let selectedRange = textView.selectedRange
        
        // 找到当前行的开始位置
        let lineStart = findLineStart(in: text, from: selectedRange.location)
        
        // 检查是否已经有这个前缀
        let lineStartIndex = text.index(text.startIndex, offsetBy: lineStart)
        let remainingText = String(text[lineStartIndex...])
        
        if remainingText.hasPrefix(prefix) {
            // 移除前缀
            let removeRange = NSRange(location: lineStart, length: prefix.count)
            textView.replaceText(in: removeRange, with: "")
        } else {
            // 添加前缀
            textView.insertText(prefix, at: NSRange(location: lineStart, length: 0))
        }
    }
    
    func insertText(_ text: String) {
        guard let textView = textView else { return }
        textView.insertText(text, at: textView.selectedRange)
    }
    
    private func findLineStart(in text: String, from position: Int) -> Int {
        guard position > 0 else { return 0 }
        
        let substring = String(text.prefix(position))
        if let lastNewlineIndex = substring.lastIndex(of: "\n") {
            return text.distance(from: text.startIndex, to: lastNewlineIndex) + 1
        }
        
        return 0
    }
    
    // MARK: - 撤销/重做
    
    func undo() {
        textView?.undoManager?.undo()
    }
    
    func redo() {
        textView?.undoManager?.redo()
    }
    
    func canUndo() -> Bool {
        return textView?.undoManager?.canUndo ?? false
    }
    
    func canRedo() -> Bool {
        return textView?.undoManager?.canRedo ?? false
    }
}
