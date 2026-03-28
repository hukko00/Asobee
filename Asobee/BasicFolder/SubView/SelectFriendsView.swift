import Firebase
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct Friend3: Identifiable {
    let id: String
    let name: String
}

struct SelectFriendsView: View {
    @State private var friends: [Friend3] = []
    @Binding var selectedFriends: [String]
    @State private var statusMessage = ""
    @State private var statusImage = "plus.circle"


    var body: some View {
        List(friends) { friend in
            HStack{
                Text(friend.name)
                Text(statusMessage)
                    .font(Font.title3.bold())
                Button{
                    if !selectedFriends.contains(friend.id) {
                        selectedFriends.append(friend.id)
                        print("保存完了")
                        statusMessage = "保存完了"
                    } else {
                        print("保存失敗")
                        statusMessage = "保存失敗 もう追加しています"
                    }
                    statusImage = "checkmark.circle"
                } label:{
                    Image(systemName:statusImage)
                        .font(Font.title3.bold())
                }
            }
        }
        .onAppear {
            selectedFriends = []
        }
        .onAppear {
            fetchFriends { result in
                friends = result
            }
        }
    }
    func fetchFriends(completion: @escaping ([Friend3]) -> Void) {
        guard let myUid = Auth.auth().currentUser?.uid else {
            completion([])
            return
        }
        
        let db = Firestore.firestore()
        
        db.collection("users").document(myUid).getDocument { snapshot, error in
            let myFollowing = snapshot?.data()?["following"] as? [String] ?? []
            
            var friends: [Friend3] = []
            let group = DispatchGroup()
            
            for uid in myFollowing {
                group.enter()
                
                db.collection("users").document(uid).getDocument { doc, error in
                    let data = doc?.data()
                    let otherFollowing = data?["following"] as? [String] ?? []
                    let name = data?["userName"] as? String ?? "名前なし"
                    
                    if otherFollowing.contains(myUid) {
                        friends.append(Friend3(id: uid, name: name))
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

#Preview {
    FriendListView()
}
