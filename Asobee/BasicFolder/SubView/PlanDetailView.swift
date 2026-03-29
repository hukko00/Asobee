import SwiftUI
import FirebaseFirestore

struct TimeItem: Identifiable {
    let id: String
    let departureTime: String
    let departureStation: String
    let arrivalTime: String
    let arrivalStation: String
}

struct PlanDetailView: View {
    var plan: PlanItem
    @State private var times: [TimeItem] = []
    
    var body: some View {
        NavigationStack {
            VStack {
                List {
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
            
            getTimes(planId: plan.id) { times in
                self.times = times
            }
        }
    }
    
    func getTimes(planId: String, completion: @escaping ([TimeItem]) -> Void) {
        let db = Firestore.firestore()
        
        db.collection("times")
            .whereField("Planid", isEqualTo: planId)
            .getDocuments { snapshot, error in
                
                if error != nil {
                    completion([])
                    return
                }
                
                var results: [TimeItem] = []
                
                for doc in snapshot?.documents ?? [] {
                    let data = doc.data()
                    
                    print("📄 data:", data)
                    let departureTime = (data["departuretime"] as? Timestamp)?.dateValue()
                    let arrivalTime = (data["arrivaltime"] as? Timestamp)?.dateValue()
                    
                    let formatter = DateFormatter()
                    formatter.dateFormat = "HH:mm"
                    
                    let time = TimeItem(
                        id: doc.documentID,
                        departureTime: departureTime != nil ? formatter.string(from: departureTime!) : "",
                        departureStation: data["departurestation"] as? String ?? "",
                        arrivalTime: arrivalTime != nil ? formatter.string(from: arrivalTime!) : "",
                        arrivalStation: data["arrivestation"] as? String ?? ""
                    )
                    
                    results.append(time)
                }
                completion(
                    results.sorted {
                        $0.arrivalTime < $1.arrivalTime
                    }
                )
            }
    }
    func deleteTimeItem(time: TimeItem) {
        let db = Firestore.firestore()
        
        db.collection("times")
            .document(time.id)
            .delete { error in
                if let error = error {
                    print("削除失敗: \(error)")
                } else {
                    print("削除成功")
                }
            }
        
        // UI更新
        times.removeAll { $0.id == time.id }
    }
}
