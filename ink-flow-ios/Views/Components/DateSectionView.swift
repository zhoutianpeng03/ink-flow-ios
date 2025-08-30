//
//  DateSectionView.swift
//  ink-flow-ios
//
//  Created by zhoutianpeng on 2025/8/30.
//

import SwiftUI

struct DateSectionView: View {
    let dateKey: String
    let notes: [Note]
    let isFirst: Bool
    let isLast: Bool
    
    private var displayDate: String {
        if let firstNote = notes.first {
            return firstNote.formattedDateForTimeline
        }
        return dateKey
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            // Left side - Date label
            HStack {
                Spacer()
                Text(displayDate)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.trailing)
            }
            .frame(width: 50)
            .padding(.top, 20) // Align with timeline dot
            
            // Timeline column
            VStack(spacing: 0) {
                // Top line (hidden for first item)
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 2)
                    .frame(height: isFirst ? 0 : 24)
                
                // Timeline dot
                Circle()
                    .fill(Color.white)
                    .frame(width: 12, height: 12)
                    .overlay(
                        Circle()
                            .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                    )
                
                // Bottom line (hidden for last item)
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 2)
                    .frame(height: isLast ? 0 : nil)
            }
            .frame(width: 12)
            .padding(.horizontal, 16)
            
            // Right content - notes list (aligned with timeline)
            VStack(spacing: 16) {
                ForEach(notes) { note in
                    NoteCell(note: note)
                }
            }
            .padding(.trailing, 16)
            .padding(.bottom, isLast ? 0 : 32)
        }
    }
}

#Preview {
    let sampleNotes = [
        Note(emoji: "📝", title: "Meeting Notes", content: "Today we discussed the project timeline and key milestones for the upcoming release.", startTime: Date(), endTime: Date().addingTimeInterval(1800)),
        Note(emoji: "💡", title: "Project Ideas", content: "Some brilliant ideas came up during brainstorming session about user experience improvements.", startTime: Date().addingTimeInterval(-1800), endTime: Date().addingTimeInterval(-900))
    ]
    
    DateSectionView(
        dateKey: "Today",
        notes: sampleNotes,
        isFirst: true,
        isLast: false
    )
    .background(Color.black)
}
