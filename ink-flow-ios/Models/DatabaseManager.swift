//
//  DatabaseManager.swift
//  ink-flow-ios
//
//  Created by zhoutianpeng on 2025/8/30.
//

import Foundation
import SQLite3

class DatabaseManager {
    static let shared = DatabaseManager()
    private var db: OpaquePointer?
    
    private let notesTable = "notes"
    
    private init() {
        openDatabase()
        createTables()
    }
    
    deinit {
        closeDatabase()
    }
    
    // MARK: - Database Operations
    
    private func openDatabase() {
        let fileURL = try! FileManager.default
            .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("notes.sqlite")
        
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("Unable to open database")
            return
        }
        
        print("Database opened successfully at: \(fileURL.path)")
    }
    
    private func closeDatabase() {
        if sqlite3_close(db) != SQLITE_OK {
            print("Unable to close database")
        }
        db = nil
    }
    
    private func createTables() {
        let createTableSQL = """
            CREATE TABLE IF NOT EXISTS \(notesTable) (
                id TEXT PRIMARY KEY,
                emoji TEXT NOT NULL,
                title TEXT NOT NULL,
                summary TEXT NOT NULL,
                file_path TEXT NOT NULL,
                start_time REAL NOT NULL,
                end_time REAL NOT NULL,
                created_at REAL NOT NULL,
                updated_at REAL NOT NULL
            );
        """
        
        if sqlite3_exec(db, createTableSQL, nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("Error creating table: \(errmsg)")
        } else {
            print("Notes table created successfully")
        }
    }
    
    // MARK: - Note Operations
    
    func insertNote(_ note: NoteRecord) -> Bool {
        // First check if note with this ID already exists
        if getNote(by: note.id) != nil {
            print("DatabaseManager: Note with ID \(note.id) already exists, updating instead")
            return updateNote(note)
        }
        
        let insertSQL = """
            INSERT INTO \(notesTable) 
            (id, emoji, title, summary, file_path, start_time, end_time, created_at, updated_at) 
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?);
        """
        
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, insertSQL, -1, &statement, nil) == SQLITE_OK {
            let now = Date().timeIntervalSince1970
            
            print("DatabaseManager: Preparing to insert note - ID: \(note.id), Title: \(note.title)")
            
            sqlite3_bind_text(statement, 1, note.id.cString(using: .utf8), -1, nil)
            sqlite3_bind_text(statement, 2, note.emoji.cString(using: .utf8), -1, nil)
            sqlite3_bind_text(statement, 3, note.title.cString(using: .utf8), -1, nil)
            sqlite3_bind_text(statement, 4, note.summary.cString(using: .utf8), -1, nil)
            sqlite3_bind_text(statement, 5, note.filePath.cString(using: .utf8), -1, nil)
            sqlite3_bind_double(statement, 6, note.startTime.timeIntervalSince1970)
            sqlite3_bind_double(statement, 7, note.endTime.timeIntervalSince1970)
            sqlite3_bind_double(statement, 8, now)
            sqlite3_bind_double(statement, 9, now)
            
            print("DatabaseManager: All parameters bound successfully")
            
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Note inserted successfully")
                sqlite3_finalize(statement)
                return true
            } else {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("Error inserting note: \(errmsg)")
            }
        } else {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("Error preparing insert statement: \(errmsg)")
        }
        
        sqlite3_finalize(statement)
        return false
    }
    
    func updateNote(_ note: NoteRecord) -> Bool {
        let updateSQL = """
            UPDATE \(notesTable) 
            SET emoji = ?, title = ?, summary = ?, start_time = ?, end_time = ?, updated_at = ?
            WHERE id = ?;
        """
        
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, updateSQL, -1, &statement, nil) == SQLITE_OK {
            let now = Date().timeIntervalSince1970
            
            sqlite3_bind_text(statement, 1, note.emoji.cString(using: .utf8), -1, nil)
            sqlite3_bind_text(statement, 2, note.title.cString(using: .utf8), -1, nil)
            sqlite3_bind_text(statement, 3, note.summary.cString(using: .utf8), -1, nil)
            sqlite3_bind_double(statement, 4, note.startTime.timeIntervalSince1970)
            sqlite3_bind_double(statement, 5, note.endTime.timeIntervalSince1970)
            sqlite3_bind_double(statement, 6, now)
            sqlite3_bind_text(statement, 7, note.id.cString(using: .utf8), -1, nil)
            
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Note updated successfully")
                sqlite3_finalize(statement)
                return true
            } else {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("Error updating note: \(errmsg)")
            }
        } else {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("Error preparing update statement: \(errmsg)")
        }
        
        sqlite3_finalize(statement)
        return false
    }
    
    func deleteNote(id: String) -> Bool {
        let deleteSQL = "DELETE FROM \(notesTable) WHERE id = ?;"
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, deleteSQL, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, id.cString(using: .utf8), -1, nil)
            
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Note deleted successfully")
                sqlite3_finalize(statement)
                return true
            } else {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("Error deleting note: \(errmsg)")
            }
        } else {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("Error preparing delete statement: \(errmsg)")
        }
        
        sqlite3_finalize(statement)
        return false
    }
    
    func getAllNotes() -> [NoteRecord] {
        let querySQL = """
            SELECT id, emoji, title, summary, file_path, start_time, end_time, created_at, updated_at 
            FROM \(notesTable) 
            ORDER BY start_time DESC;
        """
        
        var statement: OpaquePointer?
        var notes: [NoteRecord] = []
        
        if sqlite3_prepare_v2(db, querySQL, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                let id = String(cString: sqlite3_column_text(statement, 0))
                let emoji = String(cString: sqlite3_column_text(statement, 1))
                let title = String(cString: sqlite3_column_text(statement, 2))
                let summary = String(cString: sqlite3_column_text(statement, 3))
                let filePath = String(cString: sqlite3_column_text(statement, 4))
                let startTime = Date(timeIntervalSince1970: sqlite3_column_double(statement, 5))
                let endTime = Date(timeIntervalSince1970: sqlite3_column_double(statement, 6))
                let createdAt = Date(timeIntervalSince1970: sqlite3_column_double(statement, 7))
                let updatedAt = Date(timeIntervalSince1970: sqlite3_column_double(statement, 8))
                
                let note = NoteRecord(
                    id: id,
                    emoji: emoji,
                    title: title,
                    summary: summary,
                    filePath: filePath,
                    startTime: startTime,
                    endTime: endTime,
                    createdAt: createdAt,
                    updatedAt: updatedAt
                )
                
                notes.append(note)
            }
        } else {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("Error preparing select statement: \(errmsg)")
        }
        
        sqlite3_finalize(statement)
        return notes
    }
    
    func getNote(by id: String) -> NoteRecord? {
        let querySQL = """
            SELECT id, emoji, title, summary, file_path, start_time, end_time, created_at, updated_at 
            FROM \(notesTable) 
            WHERE id = ?;
        """
        
        var statement: OpaquePointer?
        var note: NoteRecord?
        
        if sqlite3_prepare_v2(db, querySQL, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, id.cString(using: .utf8), -1, nil)
            
            if sqlite3_step(statement) == SQLITE_ROW {
                let id = String(cString: sqlite3_column_text(statement, 0))
                let emoji = String(cString: sqlite3_column_text(statement, 1))
                let title = String(cString: sqlite3_column_text(statement, 2))
                let summary = String(cString: sqlite3_column_text(statement, 3))
                let filePath = String(cString: sqlite3_column_text(statement, 4))
                let startTime = Date(timeIntervalSince1970: sqlite3_column_double(statement, 5))
                let endTime = Date(timeIntervalSince1970: sqlite3_column_double(statement, 6))
                let createdAt = Date(timeIntervalSince1970: sqlite3_column_double(statement, 7))
                let updatedAt = Date(timeIntervalSince1970: sqlite3_column_double(statement, 8))
                
                note = NoteRecord(
                    id: id,
                    emoji: emoji,
                    title: title,
                    summary: summary,
                    filePath: filePath,
                    startTime: startTime,
                    endTime: endTime,
                    createdAt: createdAt,
                    updatedAt: updatedAt
                )
            }
        } else {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("Error preparing select statement: \(errmsg)")
        }
        
        sqlite3_finalize(statement)
        return note
    }
    
    // MARK: - Debug and Utility Methods
    
    /// Verify database connection and table existence
    func verifyDatabaseSetup() -> Bool {
        guard db != nil else {
            print("DatabaseManager: Database connection is nil")
            return false
        }
        
        // Check if table exists
        let checkTableSQL = "SELECT name FROM sqlite_master WHERE type='table' AND name='\(notesTable)';"
        var statement: OpaquePointer?
        var tableExists = false
        
        if sqlite3_prepare_v2(db, checkTableSQL, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_ROW {
                tableExists = true
                print("DatabaseManager: Notes table exists")
            } else {
                print("DatabaseManager: Notes table does not exist")
            }
        } else {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("DatabaseManager: Error checking table existence: \(errmsg)")
        }
        
        sqlite3_finalize(statement)
        return tableExists
    }
    
    /// Get database file path for debugging
    func getDatabasePath() -> String {
        let fileURL = try! FileManager.default
            .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("notes.sqlite")
        return fileURL.path
    }
}

// MARK: - Database Model

struct NoteRecord {
    let id: String
    let emoji: String
    let title: String
    let summary: String
    let filePath: String
    let startTime: Date
    let endTime: Date
    let createdAt: Date
    let updatedAt: Date
}
