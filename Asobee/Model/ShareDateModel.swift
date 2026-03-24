import Foundation
internal import Combine
class ShareAppState: ObservableObject {
    @Published var username: String = ""
    @Published var isLoggedIn: Bool = false
}
