//
//  ChatViewModel.swift
//  ink-flow-ios
//
//  Created by zhoutianpeng on 2025/8/30.
//

import Foundation
import Combine

// MARK: - Array Extension for Safe Access
extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var currentMessage: String = ""
    @Published var isLoading: Bool = false
    @Published var isStreaming: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    private var responseIndex = 0
    private var streamingTimer: Timer?
    
    init() {
        // Add welcome message from AI
        addWelcomeMessage()
    }
    
    private func addWelcomeMessage() {
        let welcomeMessage = ChatMessage(content: "你好！我是你的AI助手，基于你的笔记内容来提供个性化建议。有什么我可以帮助你的吗？", isFromUser: false)
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
        
        // Simulate initial connection delay
        DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 0.8...1.5)) {
            self.isLoading = false
            self.startStreamingResponse()
        }
    }
    
    private func startStreamingResponse() {
        // Script-based responses (shorter and more natural)
        let scriptResponses = [
            "我明白你的感受，压力和怀疑自己是很常见的。给自己一些宽容，每个人都会经历迷茫。你之前的努力是有价值的，不必担心短期的结果。可以尝试放慢脚步，探索的方向，找到自己真正感兴趣的东西。偶尔的调整和迷茫是正常的，重要的是继续前行。",
            "听起来你现在真的很不开心，选择一个环境不适合的工作确实会让人很烦躁。或许现在是个反思的好时机，看看自己当初选择这份工作的原因，是为了什么，是否还符合你现在的目标。如果同事和领导让你感到不舒服，可能是时候考虑转变了，至少调整一下心态，找到自己能忍受的工作方式，或者考虑其他更合适的机会。",
            "如果现在的工作让你压力太大，且不开心，可以考虑换工作，但要确保有足够的财务准备，至少能支撑几个月的生活。你现在还有房贷，可以先规划好未来的方向，考虑在准备好后再辞职，避免做出冲动的决定。"
        ]
        
        // Get response based on current index, cycle through if needed
        let fullResponseText = scriptResponses[safe: responseIndex] ?? scriptResponses.last!
        responseIndex = (responseIndex + 1) % scriptResponses.count
        
        // Create empty AI message that will be filled gradually
        let aiMessage = ChatMessage(content: "", isFromUser: false)
        messages.append(aiMessage)
        
        // Start streaming
        isStreaming = true
        streamText(fullResponseText, messageIndex: messages.count - 1)
    }
    
    private func streamText(_ fullText: String, messageIndex: Int) {
        let characters = Array(fullText)
        var currentIndex = 0
        
        // Clean up existing timer
        streamingTimer?.invalidate()
        
        // Create streaming timer
        streamingTimer = Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            // Check if we've finished streaming
            if currentIndex >= characters.count {
                timer.invalidate()
                self.streamingTimer = nil
                self.isStreaming = false
                return
            }
            
            // Add random delays to simulate real streaming
            if Bool.random() && Double.random(in: 0...1) < 0.1 {
                // 10% chance of slight delay
                return
            }
            
            // Update message content
            let endIndex = min(currentIndex + 1, characters.count)
            let currentText = String(characters[0..<endIndex])
            
            if messageIndex < self.messages.count {
                self.messages[messageIndex] = ChatMessage(
                    content: currentText,
                    isFromUser: false,
                    timestamp: self.messages[messageIndex].timestamp
                )
            }
            
            currentIndex += 1
        }
    }
    
    deinit {
        streamingTimer?.invalidate()
    }
}
