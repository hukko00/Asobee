import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct FriendView: View {
    @State private var inputCode: String = ""
    @State private var myFriendCode: String = ""
    @State private var myCode: String = ""
    @State private var friendStatus: String = ""
    
    var body: some View {
        NavigationStack{
            VStack {
                Text("あなたのフレンドコード:\(myCode)")
                    .font(.title3)
                    .padding()
                TextField("フレンドコードを入力してください", text: $inputCode)
                    .padding(.horizontal, 50)
                    .padding()
                Button {
                    getUserInfoFromFriendCode(friendCode: inputCode) { uid, name in
                        if let uid = uid {
                            print("UID:", uid)
                            followUser(friendUid: uid)
                            friendStatus = "フレンド申請できました！"
                        } else {
                            print("ユーザーが見つかりません")
                            friendStatus = "コードが違います！入力されたコードを確認して下さい！"
                        }
                    }
                } label: {
                    Text("フレンド申請")
                        .font(.title)
                        .padding(15)
                        .foregroundStyle(Color.white)
                        .bold()
                        .background(Color.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                }
                Text(friendStatus)
                    .font(.title3)
                    .foregroundStyle(Color.red)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink {
                        FriendListView()
                    } label: {
                        Image(systemName: "list.bullet")
                    }
                }
            }
            .onAppear {
                getMyFriendCode { code in
                    if let code = code {
                        DispatchQueue.main.async {
                            myCode = code
                            myFriendCode = code
                        }
                    }
                }
                friendStatus = ""
            }
        }
    }
    
    // 🔹 friendCode → uid取得
    func getUserInfoFromFriendCode(friendCode: String, completion: @escaping (String?, String?) -> Void) {
        let db = Firestore.firestore()
        
        db.collection("users")
            .whereField("friendCode", isEqualTo: friendCode)
            .getDocuments { snapshot, error in
                
                if let error = error {
                    print("検索エラー: \(error)")
                    completion(nil, nil)
                    return
                }
                
                guard let document = snapshot?.documents.first else {
                    completion(nil, nil)
                    return
                }
                
                let uid = document.documentID
                let name = document.data()["userName"] as? String
                
                completion(uid, name)
            }
    }
    
    func checkMutualFollow(otherUid: String, completion: @escaping (Bool) -> Void) {
        guard let myUid = Auth.auth().currentUser?.uid else {
            print("uid取得失敗")
            completion(false)
            return
        }
        
        let db = Firestore.firestore()
        
        // 自分のデータ取得
        db.collection("users").document(myUid).getDocument { mySnapshot, error in
            
            if let error = error {
                print("自分取得失敗: \(error)")
                completion(false)
                return
            }
            
            let myFollowing = mySnapshot?.data()?["following"] as? [String] ?? []
            
            // 相手のデータ取得
            db.collection("users").document(otherUid).getDocument { otherSnapshot, error in
                
                if let error = error {
                    print("相手取得失敗: \(error)")
                    completion(false)
                    return
                }
                
                let otherFollowing = otherSnapshot?.data()?["following"] as? [String] ?? []
                
                // 相互フォロー判定
                let isMutual =
                    myFollowing.contains(otherUid) &&
                    otherFollowing.contains(myUid)
                
                completion(isMutual)
            }
        }
    }
    
    func followUser(friendUid: String, completion: ((Bool) -> Void)? = nil) {
        guard let myUid = Auth.auth().currentUser?.uid else {
            print("uid取得失敗")
            completion?(false)
            return
        }
        if friendUid == myUid {
            print("自分はフォローできない")
            completion?(false)
            return
        }
        
        let db = Firestore.firestore()
        
        db.collection("users")
            .document(myUid)
            .setData([
                "following": FieldValue.arrayUnion([friendUid])
            ], merge: true) { error in
                
                if let error = error {
                    print("フォロー失敗: \(error)")
                    completion?(false)
                } else {
                    print("フォロー成功")
                    completion?(true)
                }
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
    func fetchFriends(completion: @escaping ([String]) -> Void) {
        guard let myUid = Auth.auth().currentUser?.uid else {
            completion([])
            return
        }
        
        let db = Firestore.firestore()
        
        db.collection("users").document(myUid).getDocument { snapshot, error in
            let myFollowing = snapshot?.data()?["following"] as? [String] ?? []
            
            var friends: [String] = []
            let group = DispatchGroup()
            
            for uid in myFollowing {
                group.enter()
                
                db.collection("users").document(uid).getDocument { doc, error in
                    let otherFollowing = doc?.data()?["following"] as? [String] ?? []
                    
                    if otherFollowing.contains(myUid) {
                        friends.append(uid)
                    }
                    
                    group.leave()
                }
            }
            
            group.notify(queue: .main) {
                completion(friends)
            }
        }
    }
}
#Preview{
    FriendView()
}
