//
//  CreateNoteSheet.swift
//  ink-flow-ios
//
//  Created by zhoutianpeng on 2025/8/30.
//

import SwiftUI

struct CreateNoteSheet: View {
    @Binding var isPresented: Bool
    let onNoteCreated: (Note) -> Void
    
    @State private var selectedEmoji = "📝"
    @State private var title = ""
    @State private var startTime = Date()
    @State private var endTime = Date().addingTimeInterval(3600) // Default 1 hour later
    @State private var showEmojiPicker = false
    
    // Common emojis for quick selection
    private let commonEmojis = ["📝", "💡", "📚", "💭", "🎯", "📋", "✨", "🔥", "💼", "🎨", "🚀", "⭐", "🌟", "💎", "🏆", "📌"]
    
    var body: some View {
        ZStack {
            // Background
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top rounded corner container
                VStack(spacing: 24) {
                    // Drag indicator
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.gray.opacity(0.4))
                        .frame(width: 36, height: 4)
                        .padding(.top, 12)
                    
                    // Header
                    Text("创建新笔记")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.top, 8)
                    
                    VStack(spacing: 20) {
                        // Emoji + Title Row
                        HStack(spacing: 12) {
                            // Emoji Button
                            Button(action: {
                                showEmojiPicker.toggle()
                            }) {
                                Text(selectedEmoji)
                                    .font(.title2)
                                    .frame(width: 44, height: 44)
                                    .background(Color.white.opacity(0.1))
                                    .clipShape(Circle())
                            }
                            
                            // Title Input
                            TextField("输入标题", text: $title)
                                .font(.body)
                                .padding(12)
                                .background(Color.white.opacity(0.1))
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .padding(.horizontal, 20)
                        
                        // Emoji Picker (when expanded)
                        if showEmojiPicker {
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 8), spacing: 12) {
                                ForEach(commonEmojis, id: \.self) { emoji in
                                    Button(action: {
                                        selectedEmoji = emoji
                                        showEmojiPicker = false
                                    }) {
                                        Text(emoji)
                                            .font(.title2)
                                            .frame(width: 40, height: 40)
                                            .background(
                                                selectedEmoji == emoji ? Color.white.opacity(0.2) : Color.clear
                                            )
                                            .clipShape(Circle())
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                        
                        // Time Selection
                        VStack(spacing: 16) {
                            // Start Time
                            HStack {
                                Text("开始时间")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(width: 80, alignment: .leading)
                                
                                DatePicker("开始时间", selection: $startTime, displayedComponents: [.date, .hourAndMinute])
                                    .datePickerStyle(CompactDatePickerStyle())
                                    .preferredColorScheme(.dark)
                                    .accentColor(.white)
                                    .labelsHidden()
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                            }
                            .padding(.horizontal, 20)
                            
                            // End Time
                            HStack {
                                Text("结束时间")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(width: 80, alignment: .leading)
                                
                                DatePicker("结束时间", selection: $endTime, displayedComponents: [.date, .hourAndMinute])
                                    .datePickerStyle(CompactDatePickerStyle())
                                    .preferredColorScheme(.dark)
                                    .accentColor(.white)
                                    .labelsHidden()
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        Spacer()
                        
                        // Action Buttons
                        HStack(spacing: 16) {
                            // Cancel Button
                            Button(action: {
                                isPresented = false
                            }) {
                                Text("取消")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(Color.white.opacity(0.2))
                                    .cornerRadius(8)
                            }
                            
                            // Create Button
                            Button(action: {
                                createNote()
                            }) {
                                Text("创建")
                                    .font(.headline)
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(Color.white)
                                    .cornerRadius(8)
                            }
                            .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || endTime <= startTime)
                            .opacity(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || endTime <= startTime ? 0.5 : 1.0)
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    }
                }
                .background(Color.black)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .ignoresSafeArea(.container, edges: .bottom)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: showEmojiPicker)
        .onChange(of: startTime) { newStartTime in
            // Ensure end time is always after start time
            if endTime <= newStartTime {
                endTime = newStartTime.addingTimeInterval(3600) // Add 1 hour
            }
        }
    }
    
    private func createNote() {
        guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              endTime > startTime else {
            return
        }
        
        let note = Note(
            emoji: selectedEmoji,
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            content: "# \(title.trimmingCharacters(in: .whitespacesAndNewlines))\n\n新建笔记，点击编辑开始记录...", // Default content with title
            startTime: startTime,
            endTime: endTime
        )
        
        onNoteCreated(note)
        isPresented = false
    }
}

#Preview {
    CreateNoteSheet(isPresented: .constant(true)) { note in
        print("Note created: \(note.title)")
    }
}
