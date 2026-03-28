import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct PlanItem: Identifiable {
    let id: String
    let title: String
    let ownerId: String
    let inviteFriends: [String]
}

struct PlanView: View {
    @State private var plans: [PlanItem] = []
    
    var body: some View {
        NavigationStack {
            List(plans) { plan in
                NavigationLink {
                    PlanDetailView(plan: plan)
                } label: {
                    VStack(alignment: .leading) {
                        Text(plan.title)
                            .font(.headline)
                        
                        Text("owner: \(plan.ownerId)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle("プラン一覧")
            
            .toolbar {
                NavigationLink {
                    AddPlanView()
                } label: {
                    Image(systemName: "plus.circle")
                        .font(.title2)
                }
            }
        }
        .onAppear {
            fetchMyPlans { result in
                plans = result
            }
        }
    }
    
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
        group.enter()
        db.collection("plans")
            .whereField("ownerId", isEqualTo: myUid)
            .getDocuments { snapshot, error in
                if let docs = snapshot?.documents {
                    parseDocs(docs)
                }
                group.leave()
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

