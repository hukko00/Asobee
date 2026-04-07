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
        VStack(alignment: .leading, spacing: 12) {
            
            Text("フレンド一覧")
                .font(.custom("KiwiMaru-Medium", size: 28))
                .padding(.horizontal)
                .padding(.top)

            ScrollView {
                VStack(spacing: 8) {
                    ForEach(friends) { friend in
                        HStack(spacing: 12) {
                            
                            Circle()
                                .fill(Color.blue.opacity(0.2))
                                .frame(width: 44, height: 44)
                                .overlay(
                                    Text(String(friend.name.prefix(1)))
                                        .font(.custom("KiwiMaru-Medium", size: 18))
                                )
                            
                            Text(friend.name)
                                .font(.custom("KiwiMaru-Medium", size: 17))
                            
                            Spacer()
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.white)
                        )
                        .padding(.horizontal)
                    }
                }
                .padding(.top, 4)
            }
        }
        .background(Color(.systemGroupedBackground))
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
