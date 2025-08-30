//
//  NoteService.swift
//  ink-flow-ios
//
//  Created by zhoutianpeng on 2025/8/30.
//

import Foundation

class NoteService: ObservableObject {
    static let shared = NoteService()
    
    private let databaseManager = DatabaseManager.shared
    private let fileManager = FileManager.default
    
    @Published var notes: [Note] = []
    @Published var isLoading = false
    
    private init() {
        print("NoteService: Initializing...")
        
        // Verify database setup
        if databaseManager.verifyDatabaseSetup() {
            print("NoteService: Database setup verified successfully")
        } else {
            print("NoteService: Database setup failed, attempting to recreate...")
        }
        
        print("NoteService: Database path: \(databaseManager.getDatabasePath())")
        loadAllNotes()
    }
    
    // MARK: - Public API
    
    /// Load all notes from database
    func loadAllNotes() {
        isLoading = true
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            let noteRecords = self.databaseManager.getAllNotes()
            let loadedNotes = noteRecords.map { record in
                Note(from: record)
            }
            
            DispatchQueue.main.async {
                self.notes = loadedNotes
                self.isLoading = false
            }
        }
    }
    
    /// Save a new note
    func saveNote(_ note: Note, content: String = "", completion: ((Bool) -> Void)? = nil) -> Bool {
        print("NoteService: Starting saveNote for: \(note.title)")
        
        // Verify database setup
        if !databaseManager.verifyDatabaseSetup() {
            print("NoteService: Database setup verification failed")
            completion?(false)
            return false
        }
        
        print("NoteService: Database verification passed")
        var mutableNote = note
        
        // Generate file path if not exists
        let filePath = fileManager.generateNoteFilePath(for: note.id.uuidString)
        mutableNote.setFilePath(filePath)
        
        // Save content to file
        let contentToSave = content.isEmpty ? note.content : content
        guard fileManager.saveNoteContent(contentToSave, to: filePath) else {
            print("Failed to save note content to file")
            return false
        }
        
        // Update content and summary
        mutableNote.updateContent(contentToSave)
        
        // Save to database
        let noteRecord = mutableNote.toDatabaseRecord()
        guard databaseManager.insertNote(noteRecord) else {
            // Rollback: delete the file if database insert failed
            _ = fileManager.deleteNoteFile(at: filePath)
            print("Failed to save note to database")
            completion?(false)
            return false
        }
        
        // Update local array
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { 
                completion?(false)
                return 
            }
            print("NoteService: Adding note to array, current count: \(self.notes.count)")
            self.notes.append(mutableNote)
            self.notes.sort { $0.timestamp > $1.timestamp }
            print("NoteService: After adding note, count: \(self.notes.count)")
            completion?(true)
        }
        
        return true
    }
    
    /// Update an existing note
    func updateNote(_ note: Note, newContent: String? = nil) -> Bool {
        var mutableNote = note
        
        // Update content if provided
        if let content = newContent {
            mutableNote.updateContent(content)
            
            // Save updated content to file
            if let filePath = note.filePath {
                _ = fileManager.saveNoteContent(content, to: filePath)
            }
        }
        
        // Update database
        let noteRecord = mutableNote.toDatabaseRecord()
        guard databaseManager.updateNote(noteRecord) else {
            print("Failed to update note in database")
            return false
        }
        
        // Update local array
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if let index = self.notes.firstIndex(where: { $0.id == note.id }) {
                self.notes[index] = mutableNote
                self.notes.sort { $0.timestamp > $1.timestamp }
            }
        }
        
        return true
    }
    
    /// Delete a note
    func deleteNote(_ note: Note) -> Bool {
        // Delete from database
        guard databaseManager.deleteNote(id: note.id.uuidString) else {
            print("Failed to delete note from database")
            return false
        }
        
        // Delete file
        if let filePath = note.filePath {
            _ = fileManager.deleteNoteFile(at: filePath)
        }
        
        // Update local array
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.notes.removeAll { $0.id == note.id }
        }
        
        return true
    }
    
    /// Get note content (with lazy loading)
    func getNoteContent(for note: Note) -> String {
        return note.content
    }
    
    /// Load note content into memory (for editing)
    func loadNoteContentIntoMemory(_ note: Note) -> Note? {
        guard let filePath = note.filePath else { return note }
        
        guard let content = fileManager.loadNoteContent(from: filePath) else {
            print("Failed to load note content from file")
            return nil
        }
        
        // Create new note instance with content in memory
        return Note(from: note.toDatabaseRecord(), content: content)
    }
    
    /// Search notes by title or content
    func searchNotes(query: String) -> [Note] {
        let lowercaseQuery = query.lowercased()
        
        return notes.filter { note in
            note.title.lowercased().contains(lowercaseQuery) ||
            note.summary.lowercased().contains(lowercaseQuery) ||
            note.emoji.contains(lowercaseQuery)
        }
    }
    
    /// Get notes grouped by date
    func getNotesGroupedByDate() -> [(String, [Note])] {
        print("NoteService: getNotesGroupedByDate called, total notes: \(notes.count)")
        let grouped = Dictionary(grouping: notes) { $0.dateKey }
        print("NoteService: Grouped into \(grouped.keys.count) date groups")
        
        // Sort date keys (newest first)
        let sortedKeys = grouped.keys.sorted { key1, key2 in
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let date1 = formatter.date(from: key1) ?? Date.distantPast
            let date2 = formatter.date(from: key2) ?? Date.distantPast
            return date1 > date2
        }
        
        // Create grouped array with sorted notes within each group
        let result = sortedKeys.map { key in
            let notesForDate = grouped[key]?.sorted { $0.timestamp > $1.timestamp } ?? []
            return (key, notesForDate)
        }
        
        print("NoteService: Returning \(result.count) date groups")
        for (dateKey, dateNotes) in result {
            print("NoteService: Date \(dateKey): \(dateNotes.count) notes")
        }
        
        return result
    }
    
    // MARK: - Migration and Maintenance
    
    /// Migrate from old in-memory storage to new file-based storage
    func migrateOldNotes(_ oldNotes: [Note]) {
        for oldNote in oldNotes {
            // Skip if note already exists in database
            if databaseManager.getNote(by: oldNote.id.uuidString) != nil {
                continue
            }
            
            // Save old note using new system
            _ = saveNote(oldNote, content: oldNote.content)
        }
        
        // Reload all notes
        loadAllNotes()
    }
    
    /// Cleanup orphaned files (files without database records)
    func cleanupOrphanedFiles() {
        DispatchQueue.global(qos: .utility).async { [weak self] in
            guard let self = self else { return }
            
            let notesDirectory = self.fileManager.notesDirectory
            
            do {
                let fileURLs = try self.fileManager.contentsOfDirectory(
                    at: notesDirectory,
                    includingPropertiesForKeys: nil
                )
                
                let allNoteRecords = self.databaseManager.getAllNotes()
                let validFilePaths = Set(allNoteRecords.map { $0.filePath })
                
                for fileURL in fileURLs {
                    let filePath = fileURL.path
                    
                    if !validFilePaths.contains(filePath) {
                        _ = self.fileManager.deleteNoteFile(at: filePath)
                        print("Deleted orphaned file: \(filePath)")
                    }
                }
            } catch {
                print("Error cleaning up orphaned files: \(error)")
            }
        }
    }
    
    /// Get storage statistics
    func getStorageStats() -> (noteCount: Int, totalFileSize: Int64) {
        let noteCount = notes.count
        var totalFileSize: Int64 = 0
        
        for note in notes {
            if let filePath = note.filePath,
               let fileSize = fileManager.getNoteFileSize(at: filePath) {
                totalFileSize += fileSize
            }
        }
        
        return (noteCount, totalFileSize)
    }
}
