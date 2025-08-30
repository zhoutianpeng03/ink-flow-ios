//
//  Note.swift
//  ink-flow-ios
//
//  Created by zhoutianpeng on 2025/8/30.
//

import Foundation

struct Note: Identifiable, Codable {
    let id: UUID
    let emoji: String
    let title: String
    let startTime: Date
    let endTime: Date
    
    // For backward compatibility and new storage system
    private var _content: String?
    private var _filePath: String?
    private var _summary: String?
    
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
    
    // MARK: - Initializers
    
    /// Initialize with content (for new notes or in-memory notes)
    init(id: UUID = UUID(), emoji: String, title: String, content: String, startTime: Date, endTime: Date) {
        self.id = id
        self.emoji = emoji
        self.title = title
        self.startTime = startTime
        self.endTime = endTime
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
        self._content = content
        self._filePath = noteRecord.filePath
        self._summary = noteRecord.summary
    }
    
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
            createdAt: Date(),
            updatedAt: Date()
        )
    }
    
    /// Update content and save to file
    mutating func updateContent(_ newContent: String) {
        self._content = newContent
        self._summary = FileManager.default.generateSummary(from: newContent)
        
        // Save to file if file path exists
        if let filePath = _filePath {
            _ = FileManager.default.saveNoteContent(newContent, to: filePath)
        }
    }
    
    /// Set file path (used when saving note)
    mutating func setFilePath(_ path: String) {
        self._filePath = path
    }
    
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
    
    // Content preview (use summary instead of content for performance)
    var contentPreview: String {
        return summary
    }
}