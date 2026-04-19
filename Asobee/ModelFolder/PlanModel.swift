import FirebaseFirestore
import FirebaseAuth
internal import Combine

struct Plan: Identifiable, Codable {
    @DocumentID var id: String?
    var title: String
    var ownerId: String
    var members: [String]
}

class PlanListViewModel:ObservableObject{
    @Published var plans:[PlanItem] = []
    func fetchMyPlans(completion: @escaping ([PlanItem]) -> Void) {
        guard let myUid = Auth.auth().currentUser?.uid else {
            completion([])
            return
        }
        
        let db = Firestore.firestore()
        
        var results: [PlanItem] = []
        let group = DispatchGroup()
        
        func parseDocs(_ docs: [QueryDocumentSnapshot]) {
            for doc in docs {
                let data = doc.data()
                
                let plan = PlanItem(
                    id: doc.documentID,
                    title: data["title"] as? String ?? "",
                    ownerId: data["ownerId"] as? String ?? "",
                    inviteFriends: data["inviteFriends"] as? [String] ?? []
                )
                
                results.append(plan)
            }
        }
        
        // 自分がオーナー
        db.collection("plans")
            .whereField("ownerId", isEqualTo: myUid)
            .addSnapshotListener { snapshot, error in
                
                guard let docs = snapshot?.documents else { return }
                
                parseDocs(docs)
            }
        
        // 招待されている
        group.enter()
        db.collection("plans")
            .whereField("inviteFriends", arrayContains: myUid)
            .getDocuments { snapshot, error in
                if let docs = snapshot?.documents {
                    parseDocs(docs)
                }
                group.leave()
            }
        
        // 完了後
        group.notify(queue: .main) {
            let unique = Dictionary(grouping: results, by: { $0.id })
                .compactMap { $0.value.first }
            
            completion(unique)
        }
    }
}
