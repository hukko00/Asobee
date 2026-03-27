import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct RootView: View {
    @StateObject private var authVM = AuthViewModel()

    var body: some View {
        Group {
            if authVM.isLoggedIn {
                LoggedInView()
                    .environmentObject(authVM)
            } else {
                LoginVisionView()
                    .environmentObject(authVM)
            }
        }
    }
}

struct LoginVisionView: View {
    @EnvironmentObject var authVM: AuthViewModel
    

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                TextField("ユーザー名", text: $authVM.username)
                    .textFieldStyle(.roundedBorder)
                TextField("メールアドレス", text: $authVM.email)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    .autocorrectionDisabled()
                    .textFieldStyle(.roundedBorder)

                SecureField("パスワード", text: $authVM.password)
                    .textFieldStyle(.roundedBorder)

                Button("新規登録") {
                    authVM.signUp { success in
                        if success {
                            createUser(Name: authVM.username, selectedFriendIds: [])
                        }
                    }
                }
                .buttonStyle(.borderedProminent)

                Button("ログイン") {
                    authVM.signIn()
                }
                .buttonStyle(.bordered)
                if let user = Auth.auth().currentUser {
                    Text(user.displayName ?? "名前なし")
                }

                if !authVM.errorMessage.isEmpty {
                    Text(authVM.errorMessage)
                        .foregroundStyle(.red)
                        .font(.footnote)
                }

                Spacer()
            }
            .padding()
            .navigationTitle("ログイン")
        }
    }
    
    func createUser(Name: String, selectedFriendIds: [String]) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("uid取得失敗")
            return
        }
        
        let friendCode = generateCode()
        let db = Firestore.firestore()
        
        let userData: [String: Any] = [
            "userID": userId,
            "userName": Name,
            "following": selectedFriendIds,
            "friendCode": friendCode
        ]
        
        db.collection("users")
            .document(userId) // ← ここが一番重要
            .setData(userData) { error in
                
                if let error = error {
                    print("作成失敗: \(error)")
                } else {
                    print("作成成功")
                }
            }
        
        print("OK!!")
    }
    private func generateCode() -> String {
        let characters = Array("ABCDEFGHJKLMNOPQRSTUVWXYZ234567890")
        var result = ""

        for _ in 0..<8 {
            if let randomChar = characters.randomElement() {
                result.append(randomChar)
            }
        }

        return result
    }
}

struct LoggedInView: View {
    @EnvironmentObject var authVM: AuthViewModel

    var body: some View {
        VStack(spacing: 16) {
            Text("ログイン中")
                .font(.title)

            if let user = Auth.auth().currentUser {
                Text(user.email ?? "メールなし")
            }

            Button("ログアウト") {
                authVM.signOut()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}
