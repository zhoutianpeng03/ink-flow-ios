//
//  ChatView.swift
//  ink-flow-ios
//
//  Created by zhoutianpeng on 2025/8/30.
//

import SwiftUI

struct ChatView: View {
    @StateObject private var viewModel = ChatViewModel()
    @FocusState private var isInputFocused: Bool
    
    private var isSendDisabled: Bool {
        viewModel.currentMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        viewModel.isLoading ||
        viewModel.isStreaming
    }
    
    var body: some View {
        ZStack {
            // Background
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Messages area
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 8) {
                            ForEach(viewModel.messages) { message in
                                MessageBubble(message: message)
                                    .id(message.id)
                            }
                            
                            // Loading indicator
                            if viewModel.isLoading {
                                HStack {
                                    HStack(spacing: 4) {
                                        ForEach(0..<3, id: \.self) { index in
                                            Circle()
                                                .fill(Color.white.opacity(0.6))
                                                .frame(width: 8, height: 8)
                                                .scaleEffect(viewModel.isLoading ? 1.0 : 0.5)
                                                .animation(
                                                    Animation.easeInOut(duration: 0.6)
                                                        .repeatForever()
                                                        .delay(Double(index) * 0.2),
                                                    value: viewModel.isLoading
                                                )
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                    .background(Color.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 18))
                                    .frame(maxWidth: UIScreen.main.bounds.width * 0.7, alignment: .leading)
                                    
                                    Spacer()
                                }
                                .padding(.horizontal, 16)
                                .id("loading")
                            }
                        }
                        .padding(.top, 8)
                    }
                    .onChange(of: viewModel.messages.count) { _ in
                        // Auto scroll to bottom when new message arrives
                        if let lastMessage = viewModel.messages.last {
                            withAnimation(.easeOut(duration: 0.3)) {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                    .onChange(of: viewModel.isLoading) { isLoading in
                        if isLoading {
                            withAnimation(.easeOut(duration: 0.3)) {
                                proxy.scrollTo("loading", anchor: .bottom)
                            }
                        }
                    }
                    .onChange(of: viewModel.isStreaming) { isStreaming in
                        // Keep scrolling to bottom during streaming
                        if isStreaming, let lastMessage = viewModel.messages.last {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
                
                // Input area
                VStack(spacing: 12) {
                    Divider()
                        .background(Color.white.opacity(0.3))
                    
                    HStack(spacing: 12) {
                        // Text input
                        TextField("Type your message...", text: $viewModel.currentMessage, axis: .vertical)
                            .focused($isInputFocused)
                            .font(.body)
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color.white.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .lineLimit(1...4)
                        
                        // Send button
                        Button(action: {
                            viewModel.sendMessage()
                            isInputFocused = false
                        }) {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.title2)
                                .foregroundColor(isSendDisabled ? Color.white.opacity(0.3) : Color.white)
                        }
                        .disabled(isSendDisabled)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)
                }
                .background(Color.black)
            }
        }
        .navigationTitle("AI Chat")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.black, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
}

#Preview {
    ChatView()
}