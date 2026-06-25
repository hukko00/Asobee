import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct FriendView: View {
    @State private var inputCode: String = ""
    @State private var myFriendCode: String = ""
    @State private var myCode: String = ""
    @State private var friendStatus: String = ""
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {

        ZStack {
            
            colorcode(r: 247, g: 246, b: 242)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                
                // ヘッダー
                HStack {

                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 22))
                            .foregroundStyle(
                                colorcode(
                                    r: 255,
                                    g: 162,
                                    b: 97
                                )
                            )
                    }

                    Text("フレンド")
                        .font(.custom("KiwiMaru-Medium", size: 30))

                    Spacer()
                }                .padding(.horizontal)
                
                // 自分のコード
                VStack(spacing: 12) {

                    Text("あなたのフレンドコード")
                        .font(.custom("KiwiMaru-Medium", size: 16))
                        .foregroundStyle(.gray)

                    HStack(spacing: 12) {

                        Text(myCode.isEmpty ? "取得中..." : myCode)
                            .font(.custom("KiwiMaru-Medium", size: 26))
                            .foregroundStyle(.black)

                        Button {
                            UIPasteboard.general.string = myCode
                        } label: {
                            Image(systemName: "doc.on.doc.fill")
                                .font(.system(size: 22))
                                .foregroundStyle(
                                    colorcode(
                                        r: 255,
                                        g: 162,
                                        b: 97
                                    )
                                )
                        }
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(.white)
                .clipShape(
                    RoundedRectangle(cornerRadius: 20)
                )
                .shadow(
                    color: .black.opacity(0.05),
                    radius: 8
                )
                .padding()
                .frame(maxWidth: .infinity)
                .background(.white)
                .clipShape(
                    RoundedRectangle(cornerRadius: 20)
                )
                .shadow(
                    color: .black.opacity(0.05),
                    radius: 8
                )
                .padding(.horizontal)
                
                // フレンド追加
                VStack(alignment: .leading, spacing: 16) {
                    
                    Text("フレンド追加")
                        .font(.custom("KiwiMaru-Medium", size: 20))
                    
                    TextField(
                        "フレンドコードを入力",
                        text: $inputCode
                    )
                    .font(.custom("KiwiMaru-Regular", size: 16))
                    .padding()
                    .background(
                        colorcode(r: 247, g: 246, b: 242)
                    )
                    .clipShape(
                        RoundedRectangle(cornerRadius: 14)
                    )
                    
                    Button {
                        getUserInfoFromFriendCode(
                            friendCode: inputCode
                        ) { uid, name in
                            
                            if let uid {
                                followUser(friendUid: uid)
                                friendStatus = "フレンド申請できました！"
                            } else {
                                friendStatus = "コードが見つかりません"
                            }
                        }
                    } label: {
                        Text("フレンド申請")
                            .font(.custom("KiwiMaru-Medium", size: 18))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                colorcode(
                                    r: 255,
                                    g: 162,
                                    b: 97
                                )
                            )
                            .clipShape(
                                RoundedRectangle(
                                    cornerRadius: 16
                                )
                            )
                    }
                }
                .padding()
                .background(.white)
                .clipShape(
                    RoundedRectangle(cornerRadius: 20)
                )
                .shadow(
                    color: .black.opacity(0.05),
                    radius: 8
                )
                .padding(.horizontal)
                
                // ステータス
                if !friendStatus.isEmpty {
                    
                    Text(friendStatus)
                        .font(
                            .custom(
                                "KiwiMaru-Medium",
                                size: 14
                            )
                        )
                        .foregroundStyle(.gray)
                }
                
                // フレンド一覧
                NavigationLink {
                    FriendListView()
                } label: {
                    
                    HStack {
                        
                        Image(systemName: "person.2.fill")
                        
                        Text("フレンド一覧")
                            .font(
                                .custom(
                                    "KiwiMaru-Medium",
                                    size: 18
                                )
                            )
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                    }
                    .foregroundStyle(.black)
                    .padding()
                    .background(.white)
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: 20
                        )
                    )
                    .shadow(
                        color: .black.opacity(0.05),
                        radius: 8
                    )
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .onAppear {
                getMyFriendCode { code in
                    if let code = code {
                        myCode = code
                        myFriendCode = code
                    }
                }
            }
            .padding(.top)
        }
        .toolbar(.hidden)
        }

    }
    
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
    func colorcode(r:Int,g:Int,b:Int)-> Color {
        Color(
            red: Double(r)/255,
            green: Double(g)/255,
            blue: Double(b)/255
        )
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
