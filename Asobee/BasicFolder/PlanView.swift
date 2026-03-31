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
    @State private var userName: String = ""
    @State private var ownerName: String = "読み込み中..."
    @State private var ownerNameCache: [String: String] = [:]
    
    var body: some View {
        NavigationStack {
            if plans.isEmpty {
                Text("プランがまだありません\nプランを追加して下さい")
                    .foregroundStyle(Color.gray)
                    .font(.title3.bold())
                    .toolbar {
                        NavigationLink {
                            AddPlanView()
                        } label: {
                            Image(systemName: "plus")
                                .font(.title2)
                        }
                    }
                    .refreshable {
                        fetchPlans()
                    }
            } else{
                List {
                    ForEach(plans) { plan in
                        NavigationLink {
                            TestView(plan: plan)
                        } label: {
                            VStack(alignment: .leading) {
                                Text(plan.title)
                                    .font(.headline)

                                Text("owner: \(ownerNameCache[plan.ownerId] ?? ownerName)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .onAppear {
                                if ownerNameCache[plan.ownerId] == nil {
                                    fetchUserName(uid: plan.ownerId) { name in
                                        ownerNameCache[plan.ownerId] = name
                                    }
                                }
                            }
                        }
                        .swipeActions {
                            Button(role: .destructive) {
                                deletePlan(plan: plan)
                            } label: {
                                Label("削除", systemImage: "trash")
                            }
                        }
                    }
                }
                .refreshable {
                    fetchPlans()
                }
                .toolbar {
                    NavigationLink {
                        AddPlanView()
                    } label: {
                        Image(systemName: "plus")
                            .font(.title2)
                    }
                }
                .navigationTitle("プラン一覧")
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
    func deletePlan(plan: PlanItem) {
        let db = Firestore.firestore()
        
        db.collection("plans")
            .document(plan.id)
            .delete { error in
                if let error = error {
                    print("削除失敗: \(error)")
                } else {
                    print("削除成功")
                }
            }
        
        // UI更新
        plans.removeAll { $0.id == plan.id }
    }
    func fetchPlans(){
        fetchMyPlans { result in
            plans = result
        }
    }
    func fetchUserName(uid: String, completion: @escaping (String) -> Void) {
        let db = Firestore.firestore()
        
        db.collection("users")
            .document(uid)
            .getDocument { snapshot, error in
                
                if let error = error {
                    print("取得失敗: \(error)")
                    completion("不明なユーザー")
                    return
                }
                
                guard let data = snapshot?.data() else {
                    completion("不明なユーザー")
                    return
                }
                
                let name = data["name"] as? String ?? "名前なし"
                completion(name)
            }
    }
}

