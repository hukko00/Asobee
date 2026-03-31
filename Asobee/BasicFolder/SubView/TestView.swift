import SwiftUI
import FirebaseFirestore

struct TimeItem: Identifiable {
    let id: String
    let departureTime: String
    let departureStation: String
    let arrivalTime: String
    let arrivalStation: String
}
struct TestView: View {
    var plan: PlanItem
    
    @State private var times: [TimeItem] = []
    @State private var listener: ListenerRegistration?
    @State private var text: String = ""

    var body: some View {
        ZStack {
            Color(colorcode(r: 247, g: 246, b: 242))//247, 246, 242
                .ignoresSafeArea()

            VStack {
                Spacer()

                HStack(spacing: 12) {
                    Button{
                        
                    } label:{
                        Image(systemName: "plus")
                            .font(.custom("KiwiMaru-Regular", size: 22))
                            .foregroundColor(colorcode(r: 127, g: 183, b: 126))
                    }
                    Button{
                        
                    } label:{
                        Image(systemName: "photo")
                            .font(.system(size: 22))
                            .foregroundColor(colorcode(r: 127, g: 183, b: 126))
                    }
                    
                    TextField("メッセージ", text: $text)
                        .font(.custom("KiwiMaru-Regular", size: 20))
                        .padding(10)
                        .background(Color.white)
                        .cornerRadius(12)
                    Button{
                        
                    } label:{
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(colorcode(r: 255, g: 162, b: 97))
                            .font(.system(size: 22))
                    }
                }
                .padding(12)
                .background(colorcode(r: 234, g: 231, b: 220))//234, 231, 220
                .cornerRadius(20)
                .padding(.horizontal, 16)
                .padding(.bottom, 10)
            }
        }
        .onAppear {
            listenTimes(planId: plan.id)
        }
        .onDisappear {
            listener?.remove()
        }
    }
    func colorcode(r:Int,g:Int,b:Int)-> Color{
        return Color(red: Double(r)/255, green: Double(g)/255, blue: Double(b)/255)
    }
    func listenTimes(planId: String) {
        let db = Firestore.firestore()

        print("🚀 listenTimes開始 planId:", planId)

        // フォーマッタは外で1回だけ
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
                    
                    // 🔥 型チェックしながら取得
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

