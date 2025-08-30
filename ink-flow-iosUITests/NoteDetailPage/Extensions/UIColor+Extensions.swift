//
//  UIColor+Extensions.swift
//  NoteDetailPage
//
//  颜色扩展
//

import UIKit

extension UIColor {
    
    // MARK: - 主题颜色
    static var mainTheme: UIColor {
        return .systemBlue
    }
    
    static var dropDownColor: UIColor {
        return .systemBackground
    }
    
    static var toolbarBorder: UIColor {
        return .separator
    }
    
    static var linksColor: UIColor {
        return .link
    }
    
    static var sidebar: UIColor {
        return .secondarySystemBackground
    }
    
    static var whiteBlack: UIColor {
        return .systemBackground
    }
    
    // MARK: - 便利初始化方法
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            alpha: Double(a) / 255
        )
    }
    
    // MARK: - 颜色操作
    func lighter(by percentage: CGFloat = 30.0) -> UIColor? {
        return self.adjust(by: abs(percentage) )
    }
    
    func darker(by percentage: CGFloat = 30.0) -> UIColor? {
        return self.adjust(by: -1 * abs(percentage) )
    }
    
    func adjust(by percentage: CGFloat = 30.0) -> UIColor? {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        if self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            return UIColor(red: min(red + percentage/100, 1.0),
                          green: min(green + percentage/100, 1.0),
                          blue: min(blue + percentage/100, 1.0),
                          alpha: alpha)
        } else {
            return nil
        }
    }
}
