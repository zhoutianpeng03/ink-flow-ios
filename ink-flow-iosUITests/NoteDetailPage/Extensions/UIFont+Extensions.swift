//
//  UIFont+Extensions.swift
//  NoteDetailPage
//
//  字体扩展
//

import UIKit

extension UIFont {
    
    // MARK: - 预定义字体
    static var noteFont: UIFont {
        return UIFont.systemFont(ofSize: 16)
    }
    
    static var titleFont: UIFont {
        return UIFont.boldSystemFont(ofSize: 20)
    }
    
    static var headerFont: UIFont {
        return UIFont.boldSystemFont(ofSize: 18)
    }
    
    static var codeFont: UIFont {
        return UIFont.monospacedSystemFont(ofSize: 14, weight: .regular)
    }
    
    // MARK: - 字体样式操作
    func withSize(_ size: CGFloat) -> UIFont {
        return UIFont(descriptor: fontDescriptor, size: size)
    }
    
    func bold() -> UIFont {
        return withTraits(.traitBold)
    }
    
    func italic() -> UIFont {
        return withTraits(.traitItalic)
    }
    
    func boldItalic() -> UIFont {
        return withTraits([.traitBold, .traitItalic])
    }
    
    // MARK: - 动态字体支持
    static func preferredFont(for style: UIFont.TextStyle, weight: UIFont.Weight = .regular) -> UIFont {
        let descriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: style)
        let font = UIFont.systemFont(ofSize: descriptor.pointSize, weight: weight)
        return UIFontMetrics(forTextStyle: style).scaledFont(for: font)
    }
    
    // MARK: - 字体特征检查
    var isBold: Bool {
        return fontDescriptor.symbolicTraits.contains(.traitBold)
    }
    
    var isItalic: Bool {
        return fontDescriptor.symbolicTraits.contains(.traitItalic)
    }
    
    var isMonospace: Bool {
        return fontDescriptor.symbolicTraits.contains(.traitMonoSpace)
    }
}
