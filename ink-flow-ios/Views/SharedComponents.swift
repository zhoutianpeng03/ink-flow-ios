//
//  SharedComponents.swift
//  ink-flow-ios
//
//  共享的UI组件
//

import SwiftUI

// MARK: - 通用工具栏按钮

struct ToolbarIconButton: View {
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
                .frame(width: 32, height: 32)
        }
    }
}
