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
        ZStack{
            VStack{
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
                            .navigationBarBackButtonHidden(true)
                        }
                        .refreshable {
                            fetchPlans()
                        }
                } else{
                    VStack{
                        ScrollView {
                            VStack(spacing: 12) {
                                ForEach(plans) { plan in
                                    NavigationLink {
                                        ChatView(plan: plan)
                                    } label: {
                                        VStack(alignment: .leading, spacing: 6) {
                                            
                                            Text(plan.title)
                                                .font(.custom("KiwiMaru-Medium", size: 20))
                                                .foregroundColor(.black)
                                            
                                            Text("owner: \(ownerNameCache[plan.ownerId] ?? ownerName)")
                                                .font(.custom("KiwiMaru-Light", size: 14))
                                                .foregroundColor(.gray)
                                        }
                                        .padding()
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(colorcode(r: 235, g: 225, b: 215))
                                        .cornerRadius(16)
                                        .shadow(color: .black.opacity(0.08), radius: 5, x: 0, y: 2)
                                    }
                                    .padding(.horizontal)
                                    .onAppear {
                                        if ownerNameCache[plan.ownerId] == nil {
                                            fetchUserName(uid: plan.ownerId) { name in
                                                ownerNameCache[plan.ownerId] = name
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(.top)
                        }
                        .refreshable {
                            fetchPlans()
                        }
                    }
                    .scrollContentBackground(.hidden)
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
                }
            }
            .onAppear {
                if plans.isEmpty {
                    fetchMyPlans { result in
                        plans = result
                    }
                }
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
    func colorcode(r:Int,g:Int,b:Int)-> Color{
        return Color(red: Double(r)/255, green: Double(g)/255, blue: Double(b)/255)
    }
    init(previewPlans: [PlanItem] = [], previewNames: [String: String] = [:]) {
        if !previewPlans.isEmpty {
            _plans = State(initialValue: previewPlans)
        }
        if !previewNames.isEmpty {
            _ownerNameCache = State(initialValue: previewNames)
        }
    }
}
#Preview {
    PlanView(
        previewPlans: [
            PlanItem(id: "1", title: "放課後あそぶ", ownerId: "user1", inviteFriends: []),
            PlanItem(id: "2", title: "映画いく", ownerId: "user2", inviteFriends: [])
        ],
        previewNames: [
            "user1": "たろう",
            "user2": "じろう"
        ]
    )
}
