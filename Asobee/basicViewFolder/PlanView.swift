import SwiftUI
import SwiftData

struct PlanView: View {
    @State private var showAddSheet = false
    @Query private var plans: [Plan]
    
    var body: some View {
        ZStack {
            NavigationStack {
                ZStack {
                    Color(red: 255/255, green: 255/255, blue: 249/255)
                        .ignoresSafeArea()
                    
                    if plans.isEmpty {
                        ContentUnavailableView(
                            "プランがありません",
                            systemImage: "calendar"
                        )
                    } else {
                        List {
                            ForEach(plans) { plan in
                                VStack{
                                    Text(plan.title)
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
                HStack {
                    Spacer()
                    
                    Button {
                        withAnimation(.easeInOut) {
                            showAddSheet = true
                        }
                    } label: {
                        HStack {
                            Image(systemName: "plus")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundStyle(.white)

                            Spacer()

                            Text("プランの追加")
                                .font(.title2)
                                .foregroundStyle(.white)
                                .padding(10)
                                .bold()
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .clipShape(Capsule())
                    }
                    .padding(.trailing, 24)
                    .padding(.bottom, 24)
                }
            }
            
            if showAddSheet {
                Color.black.opacity(0.15)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeInOut) {
                            showAddSheet = false
                        }
                    }
                
                VStack {
                    Spacer()
                    
                    AddPlanView(showAddSheet: $showAddSheet)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .padding(.horizontal, 16)
                        .padding(.bottom, 12)
                }
                //                .ignoresSafeArea(.keyboard, edges: .bottom)
            }
        }
    }
}
#Preview{
    PlanView()
}
