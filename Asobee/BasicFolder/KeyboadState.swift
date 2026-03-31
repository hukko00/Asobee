import Foundation
import SwiftUI
internal import Combine

class KeyboardObserver: ObservableObject {
    @Published var isVisible = false

    init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(show),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(hide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    @objc func show() {
        isVisible = true
    }

    @objc func hide() {
        isVisible = false
    }
}
