//
//  ink_flow_iosApp.swift
//  ink-flow-ios
//
//  Created by zhoutianpeng on 2025/8/30.
//

import SwiftUI

@main
struct ink_flow_iosApp: App {
    
    init() {
        // TEMPORARY: Reset app data to clean up duplicate records
        // Remove this line after the issue is resolved
        AppInitializer.shared.resetAppData()
        
        // Initialize app on startup
        AppInitializer.shared.initializeApp()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
    // @StateObject private var mainNote = Note(title: "", content: "")
    
    // var body: some Scene {
    //     WindowGroup {
    //         DirectNoteEditor(note: mainNote)
    //             .preferredColorScheme(.dark)
         }
     }
}
