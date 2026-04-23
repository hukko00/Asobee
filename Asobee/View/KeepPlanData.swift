import FirebaseFirestore
import FirebaseAuth

func createPlan(title: String, selectedFriendIds: [String]) {
    guard let userId = Auth.auth().currentUser?.uid else { return }
    let db = Firestore.firestore()
    let members = [userId] + selectedFriendIds
    
    let planData: [String: Any] = [
        "title": title,
        "ownerId": userId,
        "members": members,
        "createdAt": Timestamp()
    ]
    db.collection("plans").addDocument(data: planData) { error in
        if let error = error {
            print("作成失敗: \(error)")
        } else {
            print("作成成功")
        }
    }
}
