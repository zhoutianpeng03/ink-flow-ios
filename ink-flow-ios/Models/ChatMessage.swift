//
//  ChatMessage.swift
//  ink-flow-ios
//
//  Created by zhoutianpeng on 2025/8/30.
//

import Foundation

struct ChatMessage: Identifiable, Codable {
    let id = UUID()
    let content: String
    let isFromUser: Bool
    let timestamp: Date
    
    init(content: String, isFromUser: Bool) {
        self.content = content
        self.isFromUser = isFromUser
        self.timestamp = Date()
    }
    
    init(content: String, isFromUser: Bool, timestamp: Date) {
        self.content = content
        self.isFromUser = isFromUser
        self.timestamp = timestamp
    }
}
