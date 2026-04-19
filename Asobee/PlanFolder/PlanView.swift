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
    @StateObject var planviewmodel = PlanListViewModel()
    @State private var userName: String = ""
    
    var body: some View {
        ZStack{
            VStack{
                if planviewmodel.plans.isEmpty {
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
                            planviewmodel.fetchMyPlans()
                        }
                } else{
                    VStack{
                        ScrollView {
                            VStack(spacing: 12) {
                                ForEach(planviewmodel.plans) { plan in
                                    NavigationLink {
                                        ChatView(plan: plan)
                                    } label: {
                                        VStack(alignment: .leading, spacing: 6) {
                                            
                                            Text(plan.title)
                                                .font(.custom("KiwiMaru-Medium", size: 20))
                                                .foregroundColor(.black)
                                            
                                            Text("owner: \(planviewmodel.ownerNameCache[plan.ownerId] ?? "読み込み中...")")
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
                                        if planviewmodel.ownerNameCache[plan.ownerId] == nil {
                                            planviewmodel.fetchUserName(uid: plan.ownerId)
                                        }
                                    }
                                }
                            }
                            .padding(.top)
                        }
                        .refreshable {
                            planviewmodel.fetchMyPlans()
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .refreshable {
                        planviewmodel.fetchMyPlans()
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
                print("onAppear")
                planviewmodel.fetchMyPlans()
            }
        }
    }
    func colorcode(r:Int,g:Int,b:Int)-> Color{
        return Color(red: Double(r)/255, green: Double(g)/255, blue: Double(b)/255)
    }
    init(previewPlans: [PlanItem] = [], previewNames: [String: String] = [:]) {
        let vm = PlanListViewModel()
        vm.plans = previewPlans
        vm.ownerNameCache = previewNames
        _planviewmodel = StateObject(wrappedValue: vm)
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
