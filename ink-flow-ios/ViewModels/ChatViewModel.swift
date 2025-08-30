//
//  ChatViewModel.swift
//  ink-flow-ios
//
//  Created by zhoutianpeng on 2025/8/30.
//

import Foundation
import Combine

class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var currentMessage: String = ""
    @Published var isLoading: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Add welcome message from AI
        addWelcomeMessage()
    }
    
    private func addWelcomeMessage() {
        let welcomeMessage = ChatMessage(content: "Hello! I'm your AI assistant. How can I help you today?", isFromUser: false)
        messages.append(welcomeMessage)
    }
    
    func sendMessage() {
        guard !currentMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        // Add user message
        let userMessage = ChatMessage(content: currentMessage, isFromUser: true)
        messages.append(userMessage)
        
        let messageToSend = currentMessage
        currentMessage = ""
        
        // Simulate AI response
        generateAIResponse(for: messageToSend)
    }
    
    private func generateAIResponse(for userMessage: String) {
        isLoading = true
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.isLoading = false
            
            // Simple AI response simulation
            let responses = [
                "That's an interesting question! Let me think about that.",
                "I understand what you're asking. Here's my perspective on that.",
                "Great point! I'd be happy to help you with that.",
                "That's a thoughtful question. Let me provide you with some insights.",
                "I can help you with that. Here's what I think about your request."
            ]
            
            let randomResponse = responses.randomElement() ?? "Thank you for your message!"
            let aiMessage = ChatMessage(content: randomResponse, isFromUser: false)
            self.messages.append(aiMessage)
        }
    }
}
