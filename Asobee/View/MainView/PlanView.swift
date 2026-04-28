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
    
    var body: some View {
        ZStack {
            
            VStack(spacing: 0) {
                
                // タイトル
                Text("プラン")
                    .font(.custom("KiwiMaru-Regular",size: 30))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                
                if planviewmodel.plans.isEmpty {
                    
                    VStack(spacing: 12) {
                        Spacer()
                        
                        Image(systemName: "tray")
                            .font(.system(size: 44))
                            .foregroundColor(.gray)
                        
                        Text("まだプランがありません")
                            .font(.custom("KiwiMaru-Regular",size: 18))
                        
                        Text("＋ボタンから追加できます")
                            .font(.custom("KiwiMaru-Regular",size: 13))
                            .foregroundColor(.gray)
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    
                } else {
                    
                    ScrollView {
                        VStack(spacing: 14) {
                            
                            ForEach(planviewmodel.plans) { plan in
                                NavigationLink {
                                    ChatView(plan: plan)
                                } label: {
                                    
                                    HStack {
                                        Text(plan.title)
                                            .font(.custom("KiwiMaru-Regular",size: 19))
                                            .foregroundColor(.black)
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.gray)
                                    }
                                    .padding(18)
                                    .frame(maxWidth: .infinity)
                                    .background(
                                        RoundedRectangle(cornerRadius: 18)
                                            .fill(Color(.systemBackground))
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 18)
                                            .stroke(Color.gray.opacity(0.12))
                                    )
                                    .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain)
                                .onAppear {
                                    if planviewmodel.ownerNameCache[plan.ownerId] == nil {
                                        planviewmodel.fetchUserName(uid: plan.ownerId)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 10)
                        .padding(.bottom, 80) // ← ＋ボタンと被らない
                    }
                    .refreshable {
                        planviewmodel.fetchMyPlans()
                    }
                }
            }
            
            // ＋ボタン
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    
                    NavigationLink {
                        AddPlanView()
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 24, weight: .bold))
                            .padding(20) // ← デカくして押しやすく
                            .background(Color(red: 121/255, green: 144/255, blue: 67/255))
                            .foregroundColor(.white)
                            .clipShape(Circle())
                            .shadow(radius: 6)
                    }
                    .padding(.trailing, 18)
                    .padding(.bottom, 20)
                }
            }
        }
        .onAppear {
            planviewmodel.fetchMyPlans()
        }
    }
}

#Preview {
    PlanView()
}
