//
//  TimelineView.swift
//  ink-flow-ios
//
//  Created by zhoutianpeng on 2025/8/30.
//

import SwiftUI

struct TimelineView: View {
    let dateGroups: [(String, [Note])]
    let onNoteSelected: (Note) -> Void
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(Array(dateGroups.enumerated()), id: \.offset) { index, group in
                    let (dateKey, notes) = group
                    
                    DateSectionView(
                        dateKey: dateKey,
                        notes: notes,
                        isFirst: index == 0,
                        isLast: index == dateGroups.count - 1,
                        onNoteSelected: onNoteSelected
                    )
                }
            }
            .padding(.top, 16)
            .padding(.bottom, 100) // Extra padding for floating button
        }
    }
}

#Preview {
    let sampleNotes = [
        Note(emoji: "📝", title: "Meeting Notes", content: "Today we discussed the project timeline and key milestones for the upcoming release.", startTime: Date(), endTime: Date().addingTimeInterval(1800)),
        Note(emoji: "💡", title: "Project Ideas", content: "Some brilliant ideas came up during brainstorming session about user experience improvements.", startTime: Date().addingTimeInterval(-3600), endTime: Date().addingTimeInterval(-1800))
    ]
    
    TimelineView(dateGroups: [("Today", sampleNotes)]) { note in
        print("Selected note: \(note.title)")
    }
    .background(Color.black)
}
