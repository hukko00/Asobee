import SwiftUI
import SwiftData

struct ScheduleView: View {
    var plan:Plan
    @State private var showAddscheduleSheet = false
    @Environment(\.modelContext) private var context
    
    @State private var isShowAlertSchedule = false
    @State private var scheduleToDelete: Schedule?
    
    var body: some View {
        ZStack {
            NavigationStack {
                ZStack {
                    Color(.white)
                        .ignoresSafeArea()
                    List {
                        ForEach(plan.schedule.sorted(by: { $0.timedata < $1.timedata })) { schedule in
                            HStack{
                                VStack{
                                    Text(DayformatDate(date: schedule.timedata))
                                        .font(.title)
                                        .padding(.horizontal,16)
                                    Text(TimeformatDate(date: schedule.timedata))
                                        .font(.title2)
                                }
                                VStack(alignment: .leading, spacing: 4){
                                    Text(schedule.title)
                                        .font(.largeTitle)
                                    Text(schedule.note)
                                        .font(.title)
                                }
                            }
                            .padding(4)
                            .frame(maxWidth: .infinity, alignment: .init(horizontal: .leading, vertical: .top))
                            .background(Color(red: 253/255, green: 239/255, blue: 242/255))
                            .cornerRadius(15)
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                }
                VStack {
                    Spacer()
                    
                    Button {
                        withAnimation(.easeInOut) {
                            showAddscheduleSheet = true
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "plus")
                                .font(.system(size: 22, weight: .bold))
                            
                            Text("スケジュールを追加")
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
            }
            .alert("プランを削除しますか？", isPresented: $isShowAlertSchedule) {
                Button("キャンセル", role: .cancel) {
                    scheduleToDelete = nil
                }
                
                Button("削除", role: .destructive) {
                    if let schedule = scheduleToDelete {
                        deleteSchedule(schedule)
                    }
                    scheduleToDelete = nil
                }
            } message: {
                if let schedule = scheduleToDelete {
                    Text("「\(schedule.title)」を削除します。")
                } else {
                    Text("このプランを削除します。")
                }
            }
            
            if showAddscheduleSheet {
                Color.black.opacity(0.15)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeInOut) {
                            showAddscheduleSheet = false
                        }
                    }
                
                VStack {
                    Spacer()
                    
                    AddscheduleView(
                        showAddSheet: $showAddscheduleSheet,
                        plan: plan
                    )
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .padding(.horizontal, 16)
                        .padding(.bottom, 12)
                }
            }
        }
    }
    
    func DayformatDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd日"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }
    func TimeformatDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }
    func stringSizeSelect(_ text: String) -> Int {
        @State var count = text.count
        if count <= 2 {
            return 40
        } else {
            return 80 / count
        }
    }
    
    private func deleteSchedule(_ schedule: Schedule) {
        context.delete(schedule)
        
        do {
            try context.save()
            print("削除成功")
        } catch {
            print("削除失敗: \(error.localizedDescription)")
        }
    }
}

#Preview {
    let plan = Plan(
        plantitle: "サンプル",
        planimageData: Data(),
        planColor: 0,
        planDate: .now
    )

    ScheduleView(plan: plan)
}
