import SwiftUI
import FirebaseAuth

struct RootView: View {
    @StateObject private var authVM = AuthViewModel()

    var body: some View {
        Group {
            if authVM.isLoggedIn {
                LoggedInView()
                    .environmentObject(authVM)
            } else {
                LoginView()
                    .environmentObject(authVM)
            }
        }
    }
}

struct LoginView: View {
    @EnvironmentObject var authVM: AuthViewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                TextField("メールアドレス", text: $authVM.email)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    .autocorrectionDisabled()
                    .textFieldStyle(.roundedBorder)

                SecureField("パスワード", text: $authVM.password)
                    .textFieldStyle(.roundedBorder)

                Button("新規登録") {
                    authVM.signUp()
                }
                .buttonStyle(.borderedProminent)

                Button("ログイン") {
                    authVM.signIn()
                }
                .buttonStyle(.bordered)

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
