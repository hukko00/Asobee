import SwiftUI
import FirebaseAuth
import Firebase

struct ProfileView: View {
    @State private var myCode = ""
    @State private var myFriendCode=""
    @State private var friendStatus=""
    @State private var username = ""
    @State private var followingCount = 0
    @EnvironmentObject var authVM: AuthViewModel

    let mainColor = Color(
        red: 121/255,
        green: 144/255,
        blue: 67/255
    )

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // タイトル
                    HStack {
                        Text("プロフィール")
                            .font(.custom("KiwiMaru-Regular", size: 32))
                        Spacer()
                    }
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .foregroundColor(mainColor)
                    Text(username)
                        .font(.custom("KiwiMaru-Regular", size: 28))
                    VStack(spacing: 12) {
                        InfoRow(
                            title: "フレンドコード",
                            value: myCode
                        )
                        InfoRow(
                            title: "フォロー",
                            value: "\(followingCount)"
                        )
                    }
                    
                    Button {
                        
                    } label: {
                        Text("プロフィール編集")
                            .font(.custom("KiwiMaru-Regular", size: 20))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(mainColor)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                    Button {
                        authVM.signOut()
                    } label: {
                        Text("ログアウト")
                            .font(.custom("KiwiMaru-Regular", size: 20))
                            .foregroundColor(.red)
                    }
                }
                .padding()
            }
            .onAppear {
                fetchUsername { name in
                    self.username = name
                }
            }
            .onAppear {
                fetchFollowingCount { count in
                    followingCount = count
                }
            }
            .onAppear {
                getMyFriendCode { code in
                    if let code = code {
                        myCode = code
                        myFriendCode = code
                    }
                }
                friendStatus = ""
            }
            .navigationBarHidden(true)
        }
    }
    func getMyFriendCode(completion: @escaping (String?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("uid取得失敗")
            completion(nil)
            return
        }
        
        let db = Firestore.firestore()
        
        db.collection("users")
            .document(uid)
            .getDocument { snapshot, error in
                
                if let error = error {
                    print("取得失敗: \(error)")
                    completion(nil)
                    return
                }
                
                guard let data = snapshot?.data(),
                      let code = data["friendCode"] as? String else {
                    print("friendCodeが見つからない")
                    completion(nil)
                    return
                }
                
                completion(code)
            }
    }
    func fetchUsername(completion: @escaping (String) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion("ユーザー")
            return
        }

        Firestore.firestore()
            .collection("users")
            .document(uid)
            .getDocument { snapshot, error in
                if let data = snapshot?.data() {
                    let username = data["userName"] as? String ?? "ユーザー"
                    completion(username)
                } else {
                    completion("ユーザー")
                }
            }
    }
    func fetchFollowingCount(completion: @escaping (Int) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(0)
            return
        }

        Firestore.firestore()
            .collection("users")
            .document(uid)
            .getDocument { snapshot, error in

                guard let data = snapshot?.data(),
                      let following = data["following"] as? [String] else {
                    completion(0)
                    return
                }

                completion(following.count)
            }
    }
}

struct InfoRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
                .font(.custom("KiwiMaru-Regular", size: 18))

            Spacer()

            Text(value)
                .font(.custom("KiwiMaru-Regular", size: 18))
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
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
                        .font(.custom("KiwiMaru-Light",size: 20))
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
        let characters = Array("ABCDEFGHJKLMNPQRSTUVWXYZ23456789!?#")
        var result = ""
        
        for _ in 0..<8 {
            if let randomChar = characters.randomElement() {
                result.append(randomChar)
            }
        }
        
        return result
    }
}
//#Preview {
//    ProfileView()
//}
