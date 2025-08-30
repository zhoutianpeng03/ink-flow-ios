//
//  SimpleNote.swift
//  NoteDetailPage
//
//  简化的笔记数据模型
//

import Foundation
import UIKit

class SimpleNote {
    var title: String
    var content: NSMutableAttributedString
    var createdAt: Date
    var modifiedAt: Date
    var isMarkdown: Bool
    
    init(title: String = "", content: String = "") {
        self.title = title
        self.content = NSMutableAttributedString(string: content)
        self.createdAt = Date()
        self.modifiedAt = Date()
        self.isMarkdown = true
    }
    
    init(title: String, attributedContent: NSAttributedString) {
        self.title = title
        self.content = NSMutableAttributedString(attributedString: attributedContent)
        self.createdAt = Date()
        self.modifiedAt = Date()
        self.isMarkdown = true
    }
    
    func updateContent(_ newContent: NSAttributedString) {
        content = NSMutableAttributedString(attributedString: newContent)
        modifiedAt = Date()
    }
    
    func updateTitle(_ newTitle: String) {
        title = newTitle
        modifiedAt = Date()
    }
    
    func getPlainText() -> String {
        return content.string
    }
    
    func isEmpty() -> Bool {
        return content.length == 0
    }
    
    func save() {
        // 简化版本，这里可以实现实际的保存逻辑
        modifiedAt = Date()
        print("笔记已保存: \(title)")
    }
}

// MARK: - 文本格式化相关扩展
extension SimpleNote {
    func isRTF() -> Bool {
        return !isMarkdown
    }
    
    func type() -> NoteType {
        return isMarkdown ? .markdown : .richText
    }
}

enum NoteType {
    case markdown
    case richText
}
