//
//  NoteDetailViewController.swift
//  NoteDetailPage
//
//  笔记详情编辑控制器
//

import UIKit
import PhotosUI

class NoteDetailViewController: UIViewController {
    
    // MARK: - Properties
    var note: SimpleNote? {
        didSet {
            if isViewLoaded {
                loadNote()
            }
        }
    }
    
    private var textFormatter: SimpleTextFormatter?
    
    // MARK: - UI Components
    private lazy var textView: SimpleEditTextView = {
        let textView = SimpleEditTextView()
        textView.delegate = self
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    private lazy var toolbar: SimpleToolbar = {
        let toolbar = SimpleToolbar()
        toolbar.toolbarDelegate = self
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        return toolbar
    }()
    
    private var toolbarBottomConstraint: NSLayoutConstraint!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupKeyboardNotifications()
        loadNote()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateNavigationBar()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        textView.saveNote()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(textView)
        view.addSubview(toolbar)
        
        // 设置标题
        title = "笔记详情"
        
        // 导航栏按钮
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "完成",
            style: .done,
            target: self,
            action: #selector(donePressed)
        )
        
        // 如果是模态展示，添加关闭按钮
        if isModal {
            navigationItem.leftBarButtonItem = UIBarButtonItem(
                barButtonSystemItem: .close,
                target: self,
                action: #selector(closePressed)
            )
        }
    }
    
    private func setupConstraints() {
        toolbarBottomConstraint = toolbar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        
        NSLayoutConstraint.activate([
            // TextView 约束
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            textView.bottomAnchor.constraint(equalTo: toolbar.topAnchor),
            
            // Toolbar 约束
            toolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            toolbar.heightAnchor.constraint(equalToConstant: 44),
            toolbarBottomConstraint
        ])
    }
    
    private func setupKeyboardNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    private func loadNote() {
        guard let note = note else { return }
        
        textView.loadNote(note)
        textFormatter = SimpleTextFormatter(textView: textView, note: note)
        
        // 更新标题
        if !note.title.isEmpty {
            title = note.title
        }
        
        updateToolbarButtons()
    }
    
    private func updateNavigationBar() {
        // 可以根据需要更新导航栏样式
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    private func updateToolbarButtons() {
        guard let formatter = textFormatter else { return }
        toolbar.updateUndoRedoButtons(
            canUndo: formatter.canUndo(),
            canRedo: formatter.canRedo()
        )
    }
    
    // MARK: - Actions
    @objc private func donePressed() {
        textView.resignFirstResponder()
        textView.saveNote()
        
        if isModal {
            dismiss(animated: true)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    @objc private func closePressed() {
        textView.saveNote()
        dismiss(animated: true)
    }
    
    // MARK: - Keyboard Handling
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
            return
        }
        
        let keyboardHeight = keyboardFrame.height
        toolbarBottomConstraint.constant = -keyboardHeight
        
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
            return
        }
        
        toolbarBottomConstraint.constant = 0
        
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: - Image Picker
    private func presentImagePicker() {
        if #available(iOS 14, *) {
            var configuration = PHPickerConfiguration()
            configuration.selectionLimit = 1
            configuration.filter = .images
            
            let picker = PHPickerViewController(configuration: configuration)
            picker.delegate = self
            present(picker, animated: true)
        } else {
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = self
            present(picker, animated: true)
        }
    }
    
    // MARK: - Utility
    private var isModal: Bool {
        return presentingViewController != nil ||
               navigationController?.presentingViewController?.presentedViewController == navigationController ||
               tabBarController?.presentingViewController is UITabBarController
    }
}

// MARK: - UITextViewDelegate
extension NoteDetailViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        updateToolbarButtons()
        
        // 如果笔记标题为空，从内容中提取标题
        if let note = note, note.title.isEmpty {
            let content = textView.text ?? ""
            let firstLine = content.components(separatedBy: .newlines).first ?? ""
            if !firstLine.isEmpty {
                let title = String(firstLine.prefix(50)) // 限制标题长度
                note.updateTitle(title)
                self.title = title
            }
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        updateToolbarButtons()
    }
}

// MARK: - SimpleToolbarDelegate
extension NoteDetailViewController: SimpleToolbarDelegate {
    func didTapBold() {
        textFormatter?.toggleBold()
        updateToolbarButtons()
    }
    
    func didTapItalic() {
        textFormatter?.toggleItalic()
        updateToolbarButtons()
    }
    
    func didTapHeader() {
        textFormatter?.insertHeader()
        updateToolbarButtons()
    }
    
    func didTapList() {
        textFormatter?.insertList()
        updateToolbarButtons()
    }
    
    func didTapCode() {
        textFormatter?.insertCodeBlock()
        updateToolbarButtons()
    }
    
    func didTapImage() {
        presentImagePicker()
    }
    
    func didTapUndo() {
        textFormatter?.undo()
        updateToolbarButtons()
    }
    
    func didTapRedo() {
        textFormatter?.redo()
        updateToolbarButtons()
    }
}

// MARK: - PHPickerViewControllerDelegate
@available(iOS 14, *)
extension NoteDetailViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        guard let result = results.first else { return }
        
        result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
            DispatchQueue.main.async {
                if let image = object as? UIImage {
                    self?.handleSelectedImage(image)
                }
            }
        }
    }
}

// MARK: - UIImagePickerControllerDelegate
extension NoteDetailViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        if let image = info[.originalImage] as? UIImage {
            handleSelectedImage(image)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

// MARK: - Image Handling
extension NoteDetailViewController {
    private func handleSelectedImage(_ image: UIImage) {
        // 简化版本：将图片转换为 base64 并插入到文本中
        if let imageData = image.jpegData(compressionQuality: 0.7) {
            let base64String = imageData.base64EncodedString()
            let imageMarkdown = "![图片](data:image/jpeg;base64,\(base64String))"
            textFormatter?.insertText(imageMarkdown)
        }
    }
    
    private func insertTextToEditor(_ text: String) {
        let currentRange = textView.selectedRange
        textView.insertText(text, at: currentRange)
    }
}
