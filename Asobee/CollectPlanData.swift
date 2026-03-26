import FirebaseFirestore
import FirebaseAuth
internal import Combine

class PlanViewModel: ObservableObject {
    @Published var plans: [Plan] = []
    
    private var db = Firestore.firestore()
    
    func fetchPlans() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        db.collection("plans")
            .whereField("members", arrayContains: userId)
            .addSnapshotListener { snapshot, error in
                
                if let error = error {
                    print("取得失敗: \(error)")
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                
                self.plans = documents.compactMap { doc in
                    try? doc.data(as: Plan.self)
                }
            }
    }
}
