//
//  SimpleEditTextView.swift
//  NoteDetailPage
//
//  简化的文本编辑器视图
//

import UIKit

class SimpleEditTextView: UITextView {
    
    // MARK: - Properties
    public var note: SimpleNote?
    public var typingFont: UIFont?
    private var lastSelectedRange: NSRange = NSRange(location: 0, length: 0)
    
    // MARK: - Initialization
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setupTextView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupTextView()
    }
    
    private func setupTextView() {
        // 基本设置
        font = UIFont.systemFont(ofSize: 16)
        backgroundColor = .systemBackground
        textColor = .label
        
        // 边距设置
        textContainerInset = UIEdgeInsets(top: 20, left: 16, bottom: 20, right: 16)
        
        // 键盘设置
        autocorrectionType = .default
        spellCheckingType = .default
        autocapitalizationType = .sentences
        
        // 滚动设置
        alwaysBounceVertical = true
        
        // 设置默认字体
        setupDefaultFont()
    }
    
    private func setupDefaultFont() {
        let defaultFont = UIFont.systemFont(ofSize: 16)
        typingFont = defaultFont
        
        // 设置段落样式
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4
        paragraphStyle.paragraphSpacing = 8
        
        typingAttributes = [
            .font: defaultFont,
            .foregroundColor: UIColor.label,
            .paragraphStyle: paragraphStyle
        ]
    }
    
    // MARK: - Public Methods
    func loadNote(_ note: SimpleNote) {
        self.note = note
        
        if note.content.length > 0 {
            attributedText = note.content
        } else {
            text = ""
        }
        
        // 恢复光标位置
        selectedRange = lastSelectedRange
    }
    
    func saveNote() {
        guard let note = note else { return }
        note.updateContent(attributedText)
        note.save()
    }
    
    func insertText(_ textToInsert: String, at range: NSRange? = nil) {
        let insertRange = range ?? selectedRange
        
        guard insertRange.location <= textStorage.length else { return }
        
        let mutableText = textStorage.mutableCopy() as! NSMutableAttributedString
        mutableText.replaceCharacters(in: insertRange, with: textToInsert)
        
        attributedText = mutableText
        selectedRange = NSRange(location: insertRange.location + textToInsert.count, length: 0)
        
        saveNote()
    }
    
    func replaceText(in range: NSRange, with text: String) {
        guard range.location + range.length <= textStorage.length else { return }
        
        let mutableText = textStorage.mutableCopy() as! NSMutableAttributedString
        mutableText.replaceCharacters(in: range, with: text)
        
        attributedText = mutableText
        selectedRange = NSRange(location: range.location + text.count, length: 0)
        
        saveNote()
    }
    
    // MARK: - Text Style Methods
    func toggleBold() {
        applyStyleToSelection { font in
            if font.fontDescriptor.symbolicTraits.contains(.traitBold) {
                return font.withoutTraits(.traitBold)
            } else {
                return font.withTraits(.traitBold)
            }
        }
    }
    
    func toggleItalic() {
        applyStyleToSelection { font in
            if font.fontDescriptor.symbolicTraits.contains(.traitItalic) {
                return font.withoutTraits(.traitItalic)
            } else {
                return font.withTraits(.traitItalic)
            }
        }
    }
    
    private func applyStyleToSelection(fontTransform: (UIFont) -> UIFont) {
        let range = selectedRange
        guard range.length > 0 else { return }
        
        let mutableText = textStorage.mutableCopy() as! NSMutableAttributedString
        
        mutableText.enumerateAttribute(.font, in: range) { value, range, _ in
            if let currentFont = value as? UIFont {
                let newFont = fontTransform(currentFont)
                mutableText.addAttribute(.font, value: newFont, range: range)
            }
        }
        
        attributedText = mutableText
        selectedRange = range
        saveNote()
    }
    
    // MARK: - UITextView Delegate Methods
    override func textViewDidChange(_ textView: UITextView) {
        super.textViewDidChange(textView)
        saveNote()
    }
    
    override func textViewDidChangeSelection(_ textView: UITextView) {
        super.textViewDidChangeSelection(textView)
        lastSelectedRange = selectedRange
    }
}

// MARK: - UIFont Extensions
extension UIFont {
    func withTraits(_ traits: UIFontDescriptor.SymbolicTraits) -> UIFont {
        guard let descriptor = fontDescriptor.withSymbolicTraits(fontDescriptor.symbolicTraits.union(traits)) else {
            return self
        }
        return UIFont(descriptor: descriptor, size: 0)
    }
    
    func withoutTraits(_ traits: UIFontDescriptor.SymbolicTraits) -> UIFont {
        guard let descriptor = fontDescriptor.withSymbolicTraits(fontDescriptor.symbolicTraits.subtracting(traits)) else {
            return self
        }
        return UIFont(descriptor: descriptor, size: 0)
    }
}
