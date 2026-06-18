import Foundation
import FirebaseAuth
import FirebaseMessaging
import FirebaseFirestore
internal import Combine

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isLoggedIn = false
    @Published var errorMessage = ""
    @Published var username = ""

    private var handle: AuthStateDidChangeListenerHandle?

    init() {
        handle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.isLoggedIn = (user != nil)
            }
        }
    }

    deinit {
        if let handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
    func signUp(completion: @escaping (Bool) -> Void) {
        errorMessage = ""

        Auth.auth().createUser(
            withEmail: email,
            password: password
        ) { result, error in

            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                }
                completion(false)
                return
            }

            guard let user = result?.user else {
                completion(false)
                return
            }

            let uid = user.uid

            let changeRequest = user.createProfileChangeRequest()
            changeRequest.displayName = self.username

            changeRequest.commitChanges { error in

                if let error = error {
                    DispatchQueue.main.async {
                        self.errorMessage = error.localizedDescription
                    }
                    completion(false)
                    return
                }

                Messaging.messaging().token { token, error in

                    if let error = error {
                        print("FCMトークン取得失敗: \(error)")
                        completion(true)
                        return
                    }

                    guard let token = token else {
                        completion(true)
                        return
                    }

                    Firestore.firestore()
                        .collection("users")
                        .document(uid)
                        .setData([
                            "fcmToken": token
                        ], merge: true) { error in

                            if let error = error {
                                print("FCMトークン保存失敗: \(error)")
                            } else {
                                print("FCMトークン保存成功")
                            }

                            completion(true)
                        }
                }
            }
        }
    }

    func signIn() {
        errorMessage = ""

        Auth.auth().signIn(withEmail: email, password: password) { result, error in

            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                }
                return
            }

            guard let uid = result?.user.uid else {
                return
            }

            Messaging.messaging().token { token, error in

                guard let token = token else {
                    print("FCMトークン取得失敗")
                    return
                }

                Firestore.firestore()
                    .collection("users")
                    .document(uid)
                    .setData([
                        "fcmToken": token
                    ], merge: true)

                print("FCMトークン保存成功")
            }
        }
    }

    func signOut() {
        errorMessage = ""

        do {
            try Auth.auth().signOut()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
