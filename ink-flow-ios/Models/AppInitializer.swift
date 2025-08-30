//
//  AppInitializer.swift
//  ink-flow-ios
//
//  Created by zhoutianpeng on 2025/8/30.
//

import Foundation

class AppInitializer {
    static let shared = AppInitializer()
    
    private let userDefaults = UserDefaults.standard
    private let hasInitializedKey = "app_has_initialized"
    private let dataVersionKey = "app_data_version"
    private let sampleDataLoadedKey = "sample_data_loaded"
    private let currentDataVersion = "1.0"
    
    private init() {}
    
    /// Initialize the app on first launch
    func initializeApp() {
        let hasInitialized = userDefaults.bool(forKey: hasInitializedKey)
        let dataVersion = userDefaults.string(forKey: dataVersionKey)
        
        if !hasInitialized {
            performFirstLaunchSetup()
        } else if dataVersion != currentDataVersion {
            performDataMigration(from: dataVersion)
        }
        
        // Perform maintenance tasks
        performMaintenanceTasks()
        
        // Mark as initialized
        userDefaults.set(true, forKey: hasInitializedKey)
        userDefaults.set(currentDataVersion, forKey: dataVersionKey)
    }
    
    // MARK: - Private Methods
    
    private func performFirstLaunchSetup() {
        print("Performing first launch setup...")
        
        // Create necessary directories
        createDirectoriesIfNeeded()
        
        // Initialize database
        _ = DatabaseManager.shared
        
        // Initialize note service
        _ = NoteService.shared
        
        // Setup default settings
        setupDefaultSettings()
        
        print("First launch setup completed")
    }
    
    private func performDataMigration(from oldVersion: String?) {
        print("Performing data migration from version: \(oldVersion ?? "unknown")")
        
        // Add migration logic here as needed
        // For now, we'll just ensure the new storage system is properly set up
        
        switch oldVersion {
        case nil, "":
            // Migration from pre-versioned data
            migrateFromPreVersionedData()
        default:
            print("No migration needed for version: \(oldVersion ?? "unknown")")
        }
        
        print("Data migration completed")
    }
    
    private func migrateFromPreVersionedData() {
        // This would handle migration from any old data format
        // For now, the NoteService will handle loading sample data if the database is empty
        print("Migration from pre-versioned data completed")
    }
    
    private func createDirectoriesIfNeeded() {
        let fileManager = FileManager.default
        
        // Create notes directory
        let notesDirectory = fileManager.notesDirectory
        if !fileManager.fileExists(atPath: notesDirectory.path) {
            do {
                try fileManager.createDirectory(at: notesDirectory, withIntermediateDirectories: true)
                print("Created notes directory: \(notesDirectory.path)")
            } catch {
                print("Error creating notes directory: \(error)")
            }
        }
    }
    
    private func setupDefaultSettings() {
        // Set up any default app settings
        // For example, theme preferences, default note settings, etc.
        
        if userDefaults.object(forKey: "default_note_emoji") == nil {
            userDefaults.set("📝", forKey: "default_note_emoji")
        }
        
        if userDefaults.object(forKey: "auto_save_enabled") == nil {
            userDefaults.set(true, forKey: "auto_save_enabled")
        }
    }
    
    private func performMaintenanceTasks() {
        // Perform background maintenance tasks
        DispatchQueue.global(qos: .utility).async {
            // Cleanup orphaned files
            NoteService.shared.cleanupOrphanedFiles()
            
            // Log storage statistics
            let stats = NoteService.shared.getStorageStats()
            print("Storage stats - Notes: \(stats.noteCount), Total size: \(stats.totalFileSize) bytes")
        }
    }
    
    // MARK: - Public Utility Methods
    
    /// Reset app data (for development/testing)
    func resetAppData() {
        print("Resetting app data...")
        
        // Clear UserDefaults
        userDefaults.removeObject(forKey: hasInitializedKey)
        userDefaults.removeObject(forKey: dataVersionKey)
        userDefaults.removeObject(forKey: sampleDataLoadedKey)
        
        // Clear notes directory
        let fileManager = FileManager.default
        let notesDirectory = fileManager.notesDirectory
        
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: notesDirectory, includingPropertiesForKeys: nil)
            for fileURL in fileURLs {
                try fileManager.removeItem(at: fileURL)
            }
            print("Cleared notes directory")
        } catch {
            print("Error clearing notes directory: \(error)")
        }
        
        // Clear database (by deleting the file)
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dbURL = documentsURL.appendingPathComponent("notes.sqlite")
        
        if fileManager.fileExists(atPath: dbURL.path) {
            do {
                try fileManager.removeItem(at: dbURL)
                print("Database file deleted")
            } catch {
                print("Error deleting database: \(error)")
            }
        }
        
        print("App data reset completed")
    }
    
    /// Get app initialization status
    func getInitializationStatus() -> (isInitialized: Bool, dataVersion: String?) {
        let hasInitialized = userDefaults.bool(forKey: hasInitializedKey)
        let dataVersion = userDefaults.string(forKey: dataVersionKey)
        return (hasInitialized, dataVersion)
    }
}
