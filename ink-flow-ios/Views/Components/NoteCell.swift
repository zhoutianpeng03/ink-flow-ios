//
//  NoteCell.swift
//  ink-flow-ios
//
//  Created by zhoutianpeng on 2025/8/30.
//

import SwiftUI

struct NoteCell: View {
    let note: Note
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Left side - Emoji icon
            Text(note.emoji)
                .font(.title)
                .frame(width: 60, height: 60)
                .background(Color.gray.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            
            // Right side - Content
            VStack(alignment: .leading, spacing: 6) {
                // Title
                Text(note.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                // Content preview
                Text(note.contentPreview)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                // Time
                Text(note.formattedTime)
                    .font(.caption)
                    .foregroundColor(.gray.opacity(0.7))
                    .padding(.top, 2)
            }
            
            Spacer()
        }
        .padding(16)
        .background(Color.gray.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
}

#Preview {
    NoteCell(note: Note(emoji: "📝", title: "Sample Note", content: "This is a sample note content that shows how the preview will look in the card layout.", startTime: Date(), endTime: Date().addingTimeInterval(1800)))
        .padding()
        .background(Color.black)
}
