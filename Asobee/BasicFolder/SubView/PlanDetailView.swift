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
                List(times) { time in
                    VStack(alignment: .leading) {
                        Text("\(time.departureStation) → \(time.arrivalStation)")
                        Text("\(time.departureTime) - \(time.arrivalTime)")
                            .font(.caption)
                            .foregroundColor(.gray)
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
                completion(results)
            }
    }
}
