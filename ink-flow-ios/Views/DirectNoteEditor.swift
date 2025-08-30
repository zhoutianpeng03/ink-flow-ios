//
//  DirectNoteEditor.swift
//  ink-flow-ios
//
//  直接的笔记编辑器 - 占据整个页面，模仿苹果备忘录
//

import SwiftUI

struct DirectNoteEditor: View {
    @ObservedObject var note: Note
    @State private var isKeyboardVisible = false
    
    // 计算标题（第一行内容）
    private var noteTitle: String {
        if note.content.isEmpty {
            return "新建笔记"
        }
        let firstLine = note.content.components(separatedBy: .newlines).first ?? ""
        return firstLine.isEmpty ? "新建笔记" : String(firstLine.prefix(30))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 标题栏
            HStack {
                Text(noteTitle)
                    .font(.headline)
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                Spacer()
                
                if !note.content.isEmpty {
                    Text(note.formattedDate)
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.black)
            .overlay(
                Rectangle()
                    .frame(height: 0.5)
                    .foregroundColor(Color.gray.opacity(0.3)),
                alignment: .bottom
            )
            
            // 主要编辑区域 - TextEditor自带滚动
            ZStack(alignment: .topLeading) {
                // 占位符
                if note.content.isEmpty {
                    HStack {
                        Text("开始编写...")
                            .foregroundColor(.gray)
                            .font(.system(size: 17))
                            .padding(.horizontal, 20)
                            .padding(.top, 12)
                        Spacer()
                    }
                }
                
                // 主文本编辑器
                TextEditor(text: Binding(
                    get: { note.content },
                    set: { note.updateContent($0) }
                ))
                .font(.system(size: 17))
                .lineSpacing(4)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.black)
                .foregroundColor(.white)
                .scrollContentBackground(.hidden) // iOS 16+ 隐藏默认背景
                .scrollDismissesKeyboard(.interactively) // 滚动时收起键盘
            }
            .background(Color.black)
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
                withAnimation(.easeInOut(duration: 0.3)) {
                    isKeyboardVisible = true
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
                withAnimation(.easeInOut(duration: 0.3)) {
                    isKeyboardVisible = false
                }
            }
            
            // 底部工具栏（当键盘显示时）
            if isKeyboardVisible {
                KeyboardToolbar(note: note)
                    .transition(.move(edge: .bottom))
            }
        }
        .background(Color.black)
        .ignoresSafeArea(.keyboard, edges: .bottom) // 允许内容在键盘下方滚动
        .onAppear {
            // 自动保存功能
            Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
                note.save()
            }
        }
    }
}

// MARK: - 键盘工具栏

struct KeyboardToolbar: View {
    @ObservedObject var note: Note
    
    var body: some View {
        VStack(spacing: 0) {
            // 分隔线
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(Color.gray.opacity(0.3))
            
            // 工具栏内容
            HStack(spacing: 0) {
                // 格式化按钮
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        ToolbarIconButton(icon: "bold", action: { insertFormatting("**", "**") })
                        ToolbarIconButton(icon: "italic", action: { insertFormatting("*", "*") })
                        ToolbarIconButton(icon: "list.bullet", action: { insertListItem() })
                        ToolbarIconButton(icon: "list.number", action: { insertNumberedList() })
                        ToolbarIconButton(icon: "textformat.size", action: { insertHeader() })
                        ToolbarIconButton(icon: "checklist", action: { insertCheckbox() })
                    }
                    .padding(.horizontal, 16)
                }
                
                Spacer()
                
                // 完成按钮
                Button("完成") {
                    hideKeyboard()
                }
                .foregroundColor(.white)
                .font(.system(size: 16, weight: .medium))
                .padding(.trailing, 16)
            }
            .frame(height: 44)
            .background(Color.black.opacity(0.9))
        }
    }
    
    // MARK: - Formatting Actions
    
    private func insertFormatting(_ prefix: String, _ suffix: String) {
        let currentContent = note.content
        let formattedText = prefix + "文本" + suffix
        note.updateContent(currentContent + formattedText)
    }
    
    private func insertListItem() {
        let currentContent = note.content
        let newItem = currentContent.isEmpty ? "• " : "\n• "
        note.updateContent(currentContent + newItem)
    }
    
    private func insertNumberedList() {
        let currentContent = note.content
        let newItem = currentContent.isEmpty ? "1. " : "\n1. "
        note.updateContent(currentContent + newItem)
    }
    
    private func insertHeader() {
        let currentContent = note.content
        let newHeader = currentContent.isEmpty ? "# " : "\n\n# "
        note.updateContent(currentContent + newHeader)
    }
    
    private func insertCheckbox() {
        let currentContent = note.content
        let checkbox = currentContent.isEmpty ? "- [ ] " : "\n- [ ] "
        note.updateContent(currentContent + checkbox)
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - Preview

#Preview {
    DirectNoteEditor(note: Note(title: "", content: ""))
}

#Preview("有内容") {
    DirectNoteEditor(note: Note(title: "示例", content: "这是一些示例文本内容，用来展示编辑器的外观。\n\n可以换行，也可以很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长的内容。"))
}
