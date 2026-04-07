import SwiftUI
import FirebaseFirestore

struct PlanDetailView: View {
    var plan: PlanItem
    
    @State private var times: [TimeItem] = []
    @State private var listener: ListenerRegistration?

    var body: some View {
        NavigationStack {
            VStack {
                
                List {
                    if times.isEmpty {
                        Text("時間のデータがまだありません\nデータを追加して下さい")
                            .foregroundStyle(Color.gray)
                            .font(.title3.bold())
                            .frame(maxWidth: .infinity, alignment: .center)
                    } else {
                        ForEach(times) { time in
                            VStack(alignment: .leading) {
                                Text("\(time.departureStation) → \(time.arrivalStation)")
                                Text("\(time.departureTime) - \(time.arrivalTime)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .swipeActions {
                                Button(role: .destructive) {
                                    deleteTimeItem(time: time)
                                } label: {
                                    Label("削除", systemImage: "trash")
                                }
                            }
                        }
                    }
                }
                
                NavigationLink {
                    AddTimeView(plan: plan)
                } label: {
                    HStack {
                        Image(systemName: "plus")
                        Text("電車時刻の追加")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
                }
                .padding()
            }
            .navigationTitle("詳細")
        }
        .onAppear {
            listenTimes(planId: plan.id)
        }
        .onDisappear {
            listener?.remove()
        }
    }
    
    
    func listenTimes(planId: String) {
        let db = Firestore.firestore()

        print("🚀 listenTimes開始 planId:", planId)

        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"

        listener = db.collection("plans")
            .document(planId)
            .collection("times")
            .order(by: "departureTime") // ← ここ変更
            .addSnapshotListener { snapshot, error in
                
                print("🔥 snapshot受信")
                
                if let error = error {
                    print("❌ 取得失敗:", error)
                    return
                }
                
                guard let snapshot = snapshot else {
                    print("❌ snapshotがnil")
                    return
                }
                
                print("📦 documents数:", snapshot.documents.count)
                
                var results: [TimeItem] = []
                
                for doc in snapshot.documents {
                    let data = doc.data()
                    
                    print("📄 docID:", doc.documentID)
                    print("📄 data:", data)
                    
                    guard let departureTimestamp = data["departureTime"] as? Timestamp,
                          let arrivalTimestamp = data["arrivalTime"] as? Timestamp,
                          let departureStation = data["departureStation"] as? String,
                          let arrivalStation = data["arrivalStation"] as? String else {
                        
                        print("⚠️ データ不正:", data)
                        continue
                    }
                    
                    let departureTimeString = formatter.string(from: departureTimestamp.dateValue())
                    let arrivalTimeString = formatter.string(from: arrivalTimestamp.dateValue())
                    
                    let time = TimeItem(
                        id: doc.documentID,
                        departureTime: departureTimeString,
                        departureStation: departureStation,
                        arrivalTime: arrivalTimeString,
                        arrivalStation: arrivalStation
                    )
                    
                    results.append(time)
                }
                
                print("✅ 最終results数:", results.count)
                
                DispatchQueue.main.async {
                    print("🎯 UI更新")
                    self.times = results
                }
            }
    }
    
    // 削除
    func deleteTimeItem(time: TimeItem) {
        let db = Firestore.firestore()
        
        db.collection("plans")
            .document(plan.id)
            .collection("times")
            .document(time.id)
            .delete { error in
                if let error = error {
                    print("削除失敗: \(error)")
                } else {
                    print("削除成功")
                }
            }
    }
}
