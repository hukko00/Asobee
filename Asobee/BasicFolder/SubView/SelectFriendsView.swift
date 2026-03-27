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


    var body: some View {
        List(friends) { friend in
            Text(friend.name)
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
