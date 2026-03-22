import SwiftUI
import SwiftData

struct PlanView: View {
    @State private var showAddplanSheet = false
    @Query private var plans: [Plan]
    @Environment(\.modelContext) private var context
    
    var body: some View {
        ZStack {
            NavigationStack {
                ZStack {
                    Color(.white)
                        .ignoresSafeArea()
                    
                    if plans.isEmpty {
                        ContentUnavailableView(
                            "プランがありません",
                            systemImage: "calendar"
                        )
                    } else {
                        List {
                            ForEach(plans) { plan in
                                Button{
                                    print("button ok")
                                } label:{
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack{
                                            Text("")
                                                .padding(10)
                                            VStack{
                                                Text(plan.plantitle)
                                                    .font(.system(size: CGFloat(StringSizeselect(String: plan.plantitle))))
                                                    .bold()
                                                    .padding(10)
                                                Text(formatDate(date: plan.planDate))
                                                    .font(.system(size: 15))
                                            }
                                            Spacer()
                                            if let uiImage = UIImage(data: plan.planimageData) {
                                                Image(uiImage: uiImage)
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width: 120, height: 120)
                                                    .clipped()
                                                    .cornerRadius(12)
                                                    .padding(25)
                                            } else {
                                                RoundedRectangle(cornerRadius: 12)
                                                    .fill(Color.gray.opacity(0.2))
                                                    .frame(width: 120, height: 120)
                                                    .overlay(Text("画像なし"))
                                                    .padding(25)
                                            }
                                        }
                                    }
                                }
                                .buttonStyle(.plain)
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button("削除", role: .destructive) {
                                        deletePlan(plan)
                                    }
                                    .tint(.red)
                                }
                            }
                        }
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)
                    }
                }
            }
            
            VStack {
                Spacer()
                
                Button {
                    withAnimation(.easeInOut) {
                        showAddplanSheet = true
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "plus")
                            .font(.system(size: 22, weight: .bold))
                        
                        Text("プランを追加")
                            .font(.headline)
                            .bold()
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
            
            if showAddplanSheet {
                Color.black.opacity(0.15)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeInOut) {
                            showAddplanSheet = false
                        }
                    }
                
                VStack {
                    Spacer()
                    
                    AddPlanView(showAddplanSheet: $showAddplanSheet)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .padding(.horizontal, 16)
                        .padding(.bottom, 12)
                }
            }
        }
    }
    func formatDate(date: Date) -> String {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy年MM月dd日" // 希望のフォーマット
            formatter.locale = Locale(identifier: "ja_JP") // 日本語設定
            return formatter.string(from: date)
    }
    
    func StringSizeselect(String: String) -> Int{
        @State var count = String.count
        if count == 1{
            return 40
        }else if count == 2{
            return 40
        } else{
            return 140/count
        }
    }
    
    private func deletePlan(_ plan: Plan) {
            context.delete(plan)

            do {
                try context.save()
                print("削除成功")
            } catch {
                print("削除失敗: \(error.localizedDescription)")
            }
        }
}
#Preview{
    PlanView()
}

