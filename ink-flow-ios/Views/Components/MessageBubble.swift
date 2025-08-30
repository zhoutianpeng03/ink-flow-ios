//
//  MessageBubble.swift
//  ink-flow-ios
//
//  Created by zhoutianpeng on 2025/8/30.
//

import SwiftUI

struct MessageBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isFromUser {
                Spacer()
                userMessageBubble
            } else {
                aiMessageBubble
                Spacer()
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 4)
    }
    
    private var userMessageBubble: some View {
        Text(message.content)
            .font(.body)
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.gray.opacity(0.8))
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .frame(maxWidth: UIScreen.main.bounds.width * 0.7, alignment: .trailing)
    }
    
    private var aiMessageBubble: some View {
        Text(message.content)
            .font(.body)
            .foregroundColor(.black)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .frame(maxWidth: UIScreen.main.bounds.width * 0.7, alignment: .leading)
    }
}

#Preview {
    VStack {
        MessageBubble(message: ChatMessage(content: "Hello! This is a user message.", isFromUser: true))
        MessageBubble(message: ChatMessage(content: "Hi there! This is an AI response message.", isFromUser: false))
    }
    .background(Color.black)
}
