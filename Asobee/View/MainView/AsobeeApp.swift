import SwiftUI
import SwiftData
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct AsobeeApp: App {
    @StateObject private var tabBarState = TabBarState()
    @StateObject var authVM = AuthViewModel()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene {
        WindowGroup {
            if authVM.isLoggedIn {
                ContentView()
                    .environmentObject(authVM)
                    .environmentObject(tabBarState)
                    .modelContainer(for: CachedChatMessage.self)
            } else {
                LoginVisionView()
                    .environmentObject(authVM)
                    .environmentObject(tabBarState)
                    .modelContainer(for: CachedChatMessage.self)
            }
        }
    }
}
