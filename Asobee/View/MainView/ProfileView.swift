import SwiftUI
import FirebaseAuth
import Firebase
struct ProfileView: View {
    @EnvironmentObject var authVM: AuthViewModel
    var body: some View {
        NavigationStack {
            VStack {
                Button{
                    authVM.signOut()
                } label:{
                    Text("ログアウト")
                        .font(.custom("KiwiMaru-Regular",size: 25))
                }
            }
        }
    }
}
struct LoginVisionView: View {
    @EnvironmentObject var authVM: AuthViewModel
    
    @State private var isLogin = true
    
    private let mainColor = Color(red: 121/255, green: 144/255, blue: 67/255)

    var body: some View {
        VStack(spacing: 25) {
            VStack(spacing:5){
                Text("Asobean")
                    .font(.custom("KiwiMaru-Regular",size: 40))
                Text("〜遊びの案 すぐまとまる〜")
                    .font(.custom("KiwiMaru-Regular",size: 20))
            }
            // タブ
            HStack {
                Button {
                    isLogin = true
                }label:{
                    Text("ログイン")
                        .font(.custom("KiwiMaru-Regular",size: 20))
                    .foregroundColor(isLogin ? .white : mainColor)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(isLogin ? mainColor : Color.clear)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                
                Button {
                    isLogin = false
                } label:{
                    Text("新規登録")
                        .font(.custom("KiwiMaru-Regular",size: 20))
                        .foregroundColor(!isLogin ? .white : mainColor)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(!isLogin ? mainColor : Color.clear)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
            
            // 入力
            VStack(spacing: 12) {
                
                if !isLogin {
                    TextField("ユーザー名", text: $authVM.username)
                        .padding()
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                
                TextField("メールアドレス", text: $authVM.email)
                    .font(.custom("KiwiMaru-Regular",size: 20))
                    .textInputAutocapitalization(.never)
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                
                SecureField("パスワード", text: $authVM.password)
                    .font(.custom("KiwiMaru-Regular",size: 20))
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            
            // ボタン
            Button {
                if isLogin {
                    authVM.signIn()
                } else {
                    authVM.signUp { success in
                        if success {
                            createUser(Name: authVM.username, selectedFriendIds: [])
                        }
                    }
                }
            } label: {
                Text(isLogin ? "ログイン" : "新規登録")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(mainColor)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            
            // エラー
            if !authVM.errorMessage.isEmpty {
                Text(authVM.errorMessage)
                    .foregroundColor(.red)
            }
            
            Spacer()
        }
        .padding()
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
        let characters = Array("ABCDEFGHJKLMNOPQRSTUVWXYZ234567890!?#")
        var result = ""
        
        for _ in 0..<8 {
            if let randomChar = characters.randomElement() {
                result.append(randomChar)
            }
        }
        
        return result
    }
}
#Preview {
    ProfileView()
}
