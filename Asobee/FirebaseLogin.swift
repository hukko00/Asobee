import Foundation
import FirebaseAuth
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
            self?.isLoggedIn = (user != nil)
        }
    }

    deinit {
        if let handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }

    func signUp() {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let user = result?.user {
                let changeRequest = user.createProfileChangeRequest()
                changeRequest.displayName = self.username
                changeRequest.commitChanges { error in
                    if error == nil {
                        DispatchQueue.main.async {
                            self.isLoggedIn = true
                        }
                    }
                }
            }
        }
    }

    func signIn() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let user = result?.user {

                if user.displayName != self.username {
                    do {
                        try Auth.auth().signOut()
                    } catch {}

                    DispatchQueue.main.async {
                        self.errorMessage = "ユーザー名が違います"
                    }
                    return
                }

                DispatchQueue.main.async {
                    self.isLoggedIn = true
                }
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

