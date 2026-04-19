import FirebaseFirestore
import FirebaseAuth
internal import Combine

struct Plan: Identifiable, Codable {
    @DocumentID var id: String?
    var title: String
    var ownerId: String
    var members: [String]
}

class PlanListViewModel: ObservableObject {
    @Published var plans: [PlanItem] = []
    @Published var ownerNameCache: [String: String] = [:]
    
    private var listener: ListenerRegistration?
    
    func fetchMyPlans() {
        print("fetchmyplans called")
        guard let myUid = Auth.auth().currentUser?.uid else {
            self.plans = []
            return
        }

        let db = Firestore.firestore()
        var results: [PlanItem] = []
        let group = DispatchGroup()

        // owner
        group.enter()
        db.collection("plans")
            .whereField("ownerId", isEqualTo: myUid)
            .getDocuments { snapshot, _ in
                print("owner docs:", snapshot?.documents.count ?? 0)
                if let docs = snapshot?.documents {
                    results += docs.map { self.parse($0) }
                }
                group.leave()
            }

        // invite
        group.enter()
        db.collection("plans")
            .whereField("inviteFriends", arrayContains: myUid)
            .getDocuments { snapshot, _ in
                print("owner docs:", snapshot?.documents.count ?? 0)
                if let docs = snapshot?.documents {
                    results += docs.map { self.parse($0) }
                }
                group.leave()
            }

        group.notify(queue: .main) {
            self.plans = Array(Set(results.map { $0.id })).compactMap { id in
                results.first { $0.id == id }
            }
        }
    }

    private func parse(_ doc: QueryDocumentSnapshot) -> PlanItem {
        let data = doc.data()
        print(data)
        return PlanItem(
            id: doc.documentID,
            title: data["title"] as? String ?? "",
            ownerId: data["ownerId"] as? String ?? "",
            inviteFriends: data["inviteFriends"] as? [String] ?? []
        )
    }
    
    func fetchUserName(uid: String) {
        if ownerNameCache[uid] != nil { return }
        
        let db = Firestore.firestore()
        
        db.collection("users")
            .document(uid)
            .getDocument { [weak self] snapshot, error in
                
                let name = snapshot?.data()?["name"] as? String ?? "名前なし"
                
                DispatchQueue.main.async {
                    self?.ownerNameCache[uid] = name
                }
            }
    }
}
