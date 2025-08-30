//
//  HomeViewModel.swift
//  ink-flow-ios
//
//  Created by zhoutianpeng on 2025/8/30.
//

import Foundation
import SwiftUI
import Combine

class HomeViewModel: ObservableObject {
    @Published var dateGroups: [(String, [Note])] = []
    @Published var isLoading = false
    
    private let noteService = NoteService.shared
    private var hasInitialized = false
    
    init() {
        setupObservers()
        initializeData()
    }
    
    // MARK: - Setup and Initialization
    
    private func setupObservers() {
        // Observe note service changes
        noteService.$notes
            .receive(on: DispatchQueue.main)
            .sink { [weak self] notes in
                print("HomeViewModel: Notes updated, count: \(notes.count)")
                self?.updateDateGroups()
            }
            .store(in: &cancellables)
        
        noteService.$isLoading
            .receive(on: DispatchQueue.main)
            .assign(to: \.isLoading, on: self)
            .store(in: &cancellables)
    }
    
    private func initializeData() {
        if !hasInitialized {
            hasInitialized = true
            
            // Wait for notes to load, then check if sample data is needed
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                if self?.noteService.notes.isEmpty == true {
                    print("HomeViewModel: Database is empty, loading sample notes")
                    self?.loadSampleNotesIfNeeded()
                } else {
                    print("HomeViewModel: Database has \(self?.noteService.notes.count ?? 0) notes, skipping sample data")
                }
            }
            
            updateDateGroups()
        }
    }
    
    // Load sample notes only if database is empty (first time setup)
    private func loadSampleNotesIfNeeded() {
        // Check if sample data has already been loaded
        if UserDefaults.standard.bool(forKey: "sample_data_loaded") {
            print("HomeViewModel: Sample data already loaded, skipping")
            return
        }
        
        let calendar = Calendar.current
        let now = Date()
        
        // Generate unique IDs for sample notes
        let sampleNotesData = [
            ("📝", "团队会议记录", "今天讨论了项目的整体进度和下一阶段的开发计划。需要重点关注用户体验优化和性能提升。会议决定下周开始进行UI重构工作。", now.addingTimeInterval(-3600), now.addingTimeInterval(-1800)),
            ("💡", "产品创意想法", "在头脑风暴中想到了一个很有趣的功能点，可以让用户更好地管理他们的笔记和想法。这个功能可能会成为我们产品的一个亮点。", now.addingTimeInterval(-1800), now.addingTimeInterval(-900)),
            ("📚", "学习计划制定", "为了提升技术水平，制定了详细的学习计划。包括SwiftUI进阶、iOS性能优化、设计模式等方面的学习内容。", calendar.date(byAdding: .day, value: -1, to: now)!.addingTimeInterval(-7200), calendar.date(byAdding: .day, value: -1, to: now)!.addingTimeInterval(-5400)),
            ("🎯", "2024年目标规划", "新的一年要有新的目标和规划。技术方面要深入学习架构设计，个人方面要保持健康的生活习惯，工作方面要提升项目管理能力。", calendar.date(byAdding: .day, value: -1, to: now)!.addingTimeInterval(-3600), calendar.date(byAdding: .day, value: -1, to: now)!.addingTimeInterval(-1800)),
            ("🛒", "购物清单", "需要买的东西：新的开发书籍、办公用品、健身器材等。记得要货比三家，选择性价比最高的商品。", calendar.date(byAdding: .day, value: -2, to: now)!.addingTimeInterval(-5400), calendar.date(byAdding: .day, value: -2, to: now)!.addingTimeInterval(-3600)),
            ("🏃‍♂️", "运动健身计划", "制定了详细的健身计划，包括有氧运动、力量训练和柔韧性练习。目标是每周运动3-4次，保持良好的身体状态。", calendar.date(byAdding: .day, value: -2, to: now)!.addingTimeInterval(-1800), calendar.date(byAdding: .day, value: -2, to: now)!.addingTimeInterval(-900)),
            ("📖", "读书心得体会", "最近读完了一本关于软件架构的书，收获很大。书中提到的一些设计原则和最佳实践对当前项目很有帮助。", calendar.date(byAdding: .day, value: -3, to: now)!.addingTimeInterval(-9000), calendar.date(byAdding: .day, value: -3, to: now)!.addingTimeInterval(-7200))
        ]
        
        let sampleNotes = sampleNotesData.map { (emoji, title, content, startTime, endTime) in
            Note(id: UUID(), emoji: emoji, title: title, content: content, startTime: startTime, endTime: endTime)
        }
        
        // Save sample notes using the new storage system
        for note in sampleNotes {
            _ = noteService.saveNote(note, content: note.content)
        }
        
        // Mark sample data as loaded
        UserDefaults.standard.set(true, forKey: "sample_data_loaded")
        print("HomeViewModel: Sample data loaded and marked as complete")
    }
    
    // MARK: - Private Methods
    
    private func updateDateGroups() {
        let newDateGroups = noteService.getNotesGroupedByDate()
        print("HomeViewModel: Updating date groups, total groups: \(newDateGroups.count)")
        
        // Force UI update on main thread
        DispatchQueue.main.async { [weak self] in
            self?.dateGroups = newDateGroups
            print("HomeViewModel: Date groups updated on main thread")
        }
    }
    
    // MARK: - Public API
    
    /// Add new note
    func addNote(_ note: Note) {
        print("HomeViewModel: addNote called for note: \(note.title)")
        
        // Use completion handler to ensure UI updates after note is saved
        _ = noteService.saveNote(note, content: note.content) { [weak self] success in
            print("HomeViewModel: saveNote completion called with success: \(success)")
            if success {
                DispatchQueue.main.async {
                    print("HomeViewModel: Forcing refresh after note added")
                    self?.forceRefresh()
                }
            }
        }
    }
    
    /// Update existing note
    func updateNote(_ note: Note, content: String? = nil) {
        _ = noteService.updateNote(note, newContent: content)
    }
    
    /// Delete note
    func deleteNote(_ note: Note) {
        _ = noteService.deleteNote(note)
    }
    
    /// Search notes
    func searchNotes(query: String) -> [Note] {
        return noteService.searchNotes(query: query)
    }
    
    /// Get note content for editing
    func getNoteContent(for note: Note) -> String {
        return noteService.getNoteContent(for: note)
    }
    
    /// Load note content into memory for editing
    func loadNoteForEditing(_ note: Note) -> Note? {
        return noteService.loadNoteContentIntoMemory(note)
    }
    
    /// Refresh data from storage
    func refreshData() {
        print("HomeViewModel: refreshData called")
        noteService.loadAllNotes()
        // Force immediate update
        updateDateGroups()
    }
    
    /// Force UI refresh (for debugging)
    func forceRefresh() {
        print("HomeViewModel: forceRefresh called")
        DispatchQueue.main.async { [weak self] in
            self?.objectWillChange.send()
            self?.updateDateGroups()
        }
    }
    
    // MARK: - Combine Support
    
    private var cancellables = Set<AnyCancellable>()
}
