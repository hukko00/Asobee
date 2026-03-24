import Foundation
internal import Combine

final class AppState: ObservableObject {
    // Add shared app-wide state here as needed
    @Published var isInitialized: Bool = false
    
    init() {}
}
