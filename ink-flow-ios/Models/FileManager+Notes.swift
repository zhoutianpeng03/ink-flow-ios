//
//  FileManager+Notes.swift
//  ink-flow-ios
//
//  Created by zhoutianpeng on 2025/8/30.
//

import Foundation

extension FileManager {
    
    // MARK: - Note File Management
    
    /// Get the notes directory, creating it if it doesn't exist
    var notesDirectory: URL {
        let documentsURL = urls(for: .documentDirectory, in: .userDomainMask).first!
        let notesURL = documentsURL.appendingPathComponent("Notes")
        
        if !fileExists(atPath: notesURL.path) {
            try? createDirectory(at: notesURL, withIntermediateDirectories: true)
        }
        
        return notesURL
    }
    
    /// Generate a unique file path for a note
    func generateNoteFilePath(for noteId: String) -> String {
        let fileName = "\(noteId).md"
        let fileURL = notesDirectory.appendingPathComponent(fileName)
        return fileURL.path
    }
    
    /// Save note content to file
    func saveNoteContent(_ content: String, to filePath: String) -> Bool {
        do {
            try content.write(toFile: filePath, atomically: true, encoding: .utf8)
            print("Note content saved successfully to: \(filePath)")
            return true
        } catch {
            print("Error saving note content: \(error)")
            return false
        }
    }
    
    /// Load note content from file
    func loadNoteContent(from filePath: String) -> String? {
        do {
            let content = try String(contentsOfFile: filePath, encoding: .utf8)
            return content
        } catch {
            print("Error loading note content: \(error)")
            return nil
        }
    }
    
    /// Delete note file
    func deleteNoteFile(at filePath: String) -> Bool {
        do {
            try removeItem(atPath: filePath)
            print("Note file deleted successfully: \(filePath)")
            return true
        } catch {
            print("Error deleting note file: \(error)")
            return false
        }
    }
    
    /// Check if note file exists
    func noteFileExists(at filePath: String) -> Bool {
        return fileExists(atPath: filePath)
    }
    
    /// Generate summary from content (first 100 characters)
    func generateSummary(from content: String) -> String {
        let trimmedContent = content.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedContent.isEmpty {
            return "空笔记"
        }
        
        // Remove markdown formatting for better summary
        let cleanContent = trimmedContent
            .replacingOccurrences(of: "# ", with: "")
            .replacingOccurrences(of: "## ", with: "")
            .replacingOccurrences(of: "### ", with: "")
            .replacingOccurrences(of: "**", with: "")
            .replacingOccurrences(of: "*", with: "")
            .replacingOccurrences(of: "`", with: "")
        
        // Get first line or first 100 characters
        let lines = cleanContent.components(separatedBy: .newlines)
        let firstLine = lines.first ?? ""
        
        if firstLine.count > 100 {
            return String(firstLine.prefix(100)) + "..."
        } else if firstLine.isEmpty && lines.count > 1 {
            let secondLine = lines[1]
            return secondLine.count > 100 ? String(secondLine.prefix(100)) + "..." : secondLine
        } else {
            return firstLine
        }
    }
    
    /// Get file size in bytes
    func getNoteFileSize(at filePath: String) -> Int64? {
        do {
            let attributes = try attributesOfItem(atPath: filePath)
            return attributes[.size] as? Int64
        } catch {
            print("Error getting file size: \(error)")
            return nil
        }
    }
    
    /// Get file modification date
    func getNoteFileModificationDate(at filePath: String) -> Date? {
        do {
            let attributes = try attributesOfItem(atPath: filePath)
            return attributes[.modificationDate] as? Date
        } catch {
            print("Error getting file modification date: \(error)")
            return nil
        }
    }
}
