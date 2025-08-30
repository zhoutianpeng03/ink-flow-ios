//
//  HomePage.swift
//  ink-flow-ios
//
//  Created by zhoutianpeng on 2025/8/30.
//

import SwiftUI

struct HomePage: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var showCreateNoteSheet = false
    @State private var refreshTrigger = UUID()
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color.black
                    .ignoresSafeArea()
                
                // Main content - Timeline
                TimelineView(dateGroups: viewModel.dateGroups)
                    .id(refreshTrigger)
                
                // Floating add button (bottom right)
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            showCreateNoteSheet = true
                        }) {
                            Image(systemName: "plus")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.black)
                                .frame(width: 56, height: 56)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        .padding(.trailing, 24)
                        .padding(.bottom, 32)
                    }
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: ChatView()) {
                        Image(systemName: "message.circle")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                }
            }
            .toolbarBackground(Color.black, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            print("HomePage: onAppear called")
            viewModel.refreshData()
        }
        .sheet(isPresented: $showCreateNoteSheet) {
            CreateNoteSheet(isPresented: $showCreateNoteSheet) { note in
                print("HomePage: Note created callback called for: \(note.title)")
                viewModel.addNote(note)
                // Trigger UI refresh
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    refreshTrigger = UUID()
                }
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
    }
}

#Preview {
    HomePage()
}
