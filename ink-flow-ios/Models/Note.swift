//
//  Note.swift
//  ink-flow-ios
//
//  Created by zhoutianpeng on 2025/8/30.
//

import Foundation
import SwiftUI

// MARK: - Main Note Class (ObservableObject for SwiftUI reactivity)
class Note: ObservableObject, Identifiable {
    let id: UUID
    @Published var emoji: String
    @Published var title: String
    @Published var startTime: Date
    @Published var endTime: Date
    @Published var createdAt: Date
    @Published var modifiedAt: Date
    
    // For backward compatibility and new storage system
    private var _content: String?
    private var _filePath: String?
    private var _summary: String?
    
    // MARK: - Computed Properties
    
    // Main timestamp for sorting (using start time)
    var timestamp: Date {
        return startTime
    }
    
    // Content handling (lazy loading from file or memory)
    var content: String {
        get {
            if let cachedContent = _content {
                return cachedContent
            }
            
            if let filePath = _filePath {
                return FileManager.default.loadNoteContent(from: filePath) ?? ""
            }
            
            return ""
        }
    }
    
    // Summary for display
    var summary: String {
        get {
            if let cachedSummary = _summary {
                return cachedSummary
            }
            return FileManager.default.generateSummary(from: content)
        }
    }
    
    // File path for storage
    var filePath: String? {
        return _filePath
    }
    
    var isEmpty: Bool {
        return content.isEmpty
    }
    
    var displayTitle: String {
        if title.isEmpty {
            return content.isEmpty ? "新建笔记" : String(content.prefix(30))
        }
        return title
    }
    
    // MARK: - Initializers
    
    /// Initialize with content (for new notes or in-memory notes)
    init(id: UUID = UUID(), emoji: String = "📝", title: String = "", content: String = "", startTime: Date = Date(), endTime: Date = Date()) {
        self.id = id
        self.emoji = emoji
        self.title = title
        self.startTime = startTime
        self.endTime = endTime
        self.createdAt = Date()
        self.modifiedAt = Date()
        self._content = content
        self._filePath = nil
        self._summary = nil
    }
    
    /// Initialize from database record (for loaded notes)
    init(from noteRecord: NoteRecord, content: String? = nil) {
        self.id = UUID(uuidString: noteRecord.id) ?? UUID()
        self.emoji = noteRecord.emoji
        self.title = noteRecord.title
        self.startTime = noteRecord.startTime
        self.endTime = noteRecord.endTime
        self.createdAt = noteRecord.createdAt
        self.modifiedAt = noteRecord.updatedAt
        self._content = content
        self._filePath = noteRecord.filePath
        self._summary = noteRecord.summary
    }
    
    // MARK: - Update Methods
    
    /// Update content and save to file
    func updateContent(_ newContent: String) {
        self._content = newContent
        self._summary = FileManager.default.generateSummary(from: newContent)
        self.modifiedAt = Date()
        
        // Auto-extract title from first line if title is empty
        if title.isEmpty {
            let firstLine = newContent.components(separatedBy: .newlines).first ?? ""
            if !firstLine.isEmpty {
                self.title = String(firstLine.prefix(50))
            }
        }
        
        // Save to file if file path exists
        if let filePath = _filePath {
            _ = FileManager.default.saveNoteContent(newContent, to: filePath)
        }
    }
    
    /// Update title
    func updateTitle(_ newTitle: String) {
        self.title = newTitle
        self.modifiedAt = Date()
    }
    
    /// Set file path (used when saving note)
    func setFilePath(_ path: String) {
        self._filePath = path
    }
    
    /// Save note
    func save() {
        self.modifiedAt = Date()
        // Additional save logic can be implemented here
        print("Note saved: \(title)")
    }
    
    // MARK: - Database Integration
    
    /// Convert to database record
    func toDatabaseRecord() -> NoteRecord {
        let filePath = _filePath ?? FileManager.default.generateNoteFilePath(for: id.uuidString)
        let summary = _summary ?? FileManager.default.generateSummary(from: content)
        
        return NoteRecord(
            id: id.uuidString,
            emoji: emoji,
            title: title,
            summary: summary,
            filePath: filePath,
            startTime: startTime,
            endTime: endTime,
            createdAt: createdAt,
            updatedAt: modifiedAt
        )
    }
    
    // MARK: - Formatting Properties
    
    // Time only formatter for display (without date)
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }
    
    // Date only for grouping
    var dateKey: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: timestamp)
    }
    
    // Formatted date for timeline display
    var formattedDateForTimeline: String {
        let formatter = DateFormatter()
        let calendar = Calendar.current
        
        if calendar.isDateInToday(timestamp) {
            return "今天"
        } else if calendar.isDateInYesterday(timestamp) {
            return "昨天"
        } else {
            formatter.locale = Locale(identifier: "zh_CN")
            formatter.dateFormat = "M月d日"
            return formatter.string(from: timestamp)
        }
    }
    
    // Formatted date for general display
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: modifiedAt)
    }
    
    // Content preview (use summary instead of content for performance)
    var contentPreview: String {
        return summary
    }
}

// MARK: - Codable Support
extension Note: Codable {
    private enum CodingKeys: String, CodingKey {
        case id, emoji, title, startTime, endTime, createdAt, modifiedAt
        case _content = "content"
        case _filePath = "filePath"
        case _summary = "summary"
    }
}

// MARK: - Sample Data
extension Note {
    static var sampleNote: Note {
        let note = Note(
            emoji: "📝",
            title: "示例笔记",
            content: """
            # 欢迎使用墨水笔记
            
            这是一个功能强大的笔记应用，支持丰富的文本格式。
            
            ## 特色功能
            
            - **粗体文本**
            - *斜体文本*
            - 有序列表
            - 无序列表
            - 代码块
            
            您可以开始编辑这个笔记，体验流畅的编辑体验。
            """,
            startTime: Date().addingTimeInterval(-3600),
            endTime: Date()
        )
        return note
    }
    
    static var emptyNote: Note {
        return Note()
    }
}
