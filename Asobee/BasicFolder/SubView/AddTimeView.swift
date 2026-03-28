import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct AddTimeView: View {
    @State private var selectedstartTime = Date()
    @State private var selectedlastTime = Date()
    @State private var selectedstartStation = ""
    @State private var selectedlastStation = ""
    @State private var isShowAddView = false
    var plan:PlanItem
    
    var body: some View {
        NavigationStack{
            VStack{
                DatePicker(
                    "出発時間を選択",
                    selection: $selectedstartTime,
                    displayedComponents: .hourAndMinute
                )
                .padding()
                TextField("出発する駅を入力してください 例: 大阪駅", text: $selectedstartStation)
                    .padding()
                DatePicker(
                    "到着時間を選択",
                    selection: $selectedlastTime,
                    displayedComponents: .hourAndMinute
                )
                .padding()
                TextField("到着する駅を入力して下さい 例: 東京駅", text: $selectedlastStation)
                    .padding()
                Button {
                    createPlan(
                        time: selectedstartTime,
                        station: selectedstartStation,
                        lastTime: selectedlastTime,
                        lastStation: selectedlastStation,
                        id: plan.id
                    )
                    isShowAddView = true
                } label: {
                    HStack {
                        Image(systemName: "plus")
                            .font(.title)
                        Text("追加")
                            .font(.largeTitle)
                    }
                    .padding()
                    .foregroundStyle(Color.white)
                    .background(.blue)
                    .clipShape(Capsule())
                    .bold()
                    .padding()
                }
                .navigationDestination(isPresented: $isShowAddView) {
                    PlanDetailView(plan: plan)
                }
            }
        }
    }
    func createPlan(time: Date, station: String,lastTime: Date,lastStation: String,id:String) {
        guard (Auth.auth().currentUser?.uid) != nil else { return }
        let db = Firestore.firestore()
        
        
        let planData: [String: Any] = [
            "departuretime" : time,
            "departurestation" : station,
            "arrivaltime" : lastTime,
            "arrivestation" : lastStation,
            "Planid" : id,
        ]
        
        db.collection("times").addDocument(data: planData) { error in
            if let error = error {
                print("作成失敗: \(error)")
            } else {
                print("作成成功")
            }
        }
    }
}
