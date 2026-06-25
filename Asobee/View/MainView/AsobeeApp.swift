import SwiftUI
import SwiftData
import FirebaseCore
import FirebaseMessaging
import FirebaseAuth
import FirebaseFirestore
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate {
    
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        
        FirebaseApp.configure()
        
        print("BundleID:", Bundle.main.bundleIdentifier ?? "nil")
        
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            print("通知状態:", settings.authorizationStatus.rawValue)
        }
        
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .badge, .sound]
        ) { granted, error in
            
            if let error = error {
                print("通知許可エラー:", error)
                return
            }
            
            print("通知許可:", granted)
            
            DispatchQueue.main.async {
                application.registerForRemoteNotifications()
                print("📲 registerForRemoteNotifications 呼び出し")
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            UIApplication.shared.registerForRemoteNotifications()
            print("🔁 再登録")
        }
        
        return true
    }
    
    func applicationDidBecomeActive(
        _ application: UIApplication
    ) {
        print("Application Active")
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        
        print("🔥 APNs callback")
        print("🚀 APNs登録成功")
        
        let token = deviceToken.map {
            String(format: "%02.2hhx", $0)
        }.joined()
        
        print("APNs Token:", token)
        
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        
        print("❌ APNs登録失敗")
        print(error.localizedDescription)
    }
    
    
}

extension AppDelegate: MessagingDelegate {
    
    func messaging(
        _ messaging: Messaging,
        didReceiveRegistrationToken fcmToken: String?
    ) {
        
        guard let token = fcmToken else {
            print("FCM Token nil")
            return
        }
        
        print("FCM Token更新:", token)
        
        guard let uid = Auth.auth().currentUser?.uid else {
            print("未ログイン")
            return
        }
        
        Firestore.firestore()
            .collection("users")
            .document(uid)
            .setData([
                "fcmToken": token
            ], merge: true) { error in
                
                if let error = error {
                    print("FCM保存失敗:", error)
                } else {
                    print("FCM保存成功")
                }
            }
    }
    
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        
        print("📩 通知受信")
        
        return [
            .banner,
            .badge,
            .sound
        ]
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        
        print("👆 通知タップ")
        print(response.notification.request.content.userInfo)
    }
}

@main
struct AsobeeApp: App {
    
    @StateObject private var tabBarState = TabBarState()
    @StateObject private var chatBarState = ChatBarState()
    @StateObject var authVM = AuthViewModel()
    
    @UIApplicationDelegateAdaptor(AppDelegate.self)
    var delegate
    
    var body: some Scene {
        
        WindowGroup {
            
            if authVM.isLoggedIn {
                
                ContentView()
                    .environmentObject(authVM)
                    .environmentObject(tabBarState)
                    .environmentObject(chatBarState)
                    .modelContainer(for: CachedChat.self)
                
            } else {
                
                LoginVisionView()
                    .environmentObject(authVM)
                    .environmentObject(tabBarState)
                    .environmentObject(chatBarState)
                    .modelContainer(for: CachedChat.self)
            }
        }
    }
}
