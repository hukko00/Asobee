import Firebase
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct Friend: Identifiable {
    let id: String
    let name: String
}

struct FriendListView: View {
    @State private var friends: [Friend] = []


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
    func fetchFriends(completion: @escaping ([Friend]) -> Void) {
        guard let myUid = Auth.auth().currentUser?.uid else {
            completion([])
            return
        }
        
        let db = Firestore.firestore()
        
        db.collection("users").document(myUid).getDocument { snapshot, error in
            let myFollowing = snapshot?.data()?["following"] as? [String] ?? []
            
            var friends: [Friend] = []
            let group = DispatchGroup()
            
            for uid in myFollowing {
                group.enter()
                
                db.collection("users").document(uid).getDocument { doc, error in
                    let data = doc?.data()
                    let otherFollowing = data?["following"] as? [String] ?? []
                    let name = data?["userName"] as? String ?? "名前なし"
                    
                    if otherFollowing.contains(myUid) {
                        friends.append(Friend(id: uid, name: name))
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
