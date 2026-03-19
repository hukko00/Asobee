import SwiftUI
import SwiftData

struct PlanListView: View {
    @Environment(\.modelContext) private var context
    @Query private var plan:[Plan]
    @State private var title = ""
    @State private var note = ""
    @State private var time = Date()
    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 255.0 / 255.0, green: 255.0 / 255.0, blue: 249.0 / 255.0)
                    .ignoresSafeArea()
                
                Form {
                    Section("新しいTodoを追加") {
                        TextField("タイトル", text: $title)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("内容")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            ZStack(alignment: .topLeading) {
                                if note.isEmpty {
                                    Text("具体的な内容を入力")
                                        .foregroundColor(.gray)
                                        .padding(.top, 6)
                                        .padding(.leading, 2)
                                }
                                
                                TextEditor(text: $note)
                                    .frame(minHeight: 50)
                            }
                        }
                        DatePicker(
                            "期日",
                            selection: $time,
                            displayedComponents: .date
                        )
                    }
                }
                .scrollContentBackground(.hidden)
                .background(Color.clear)
            }
        }
    }
    func addPlan() {
            let newplan = Plan(
                title: title,
                note: note
            )

            context.insert(newplan)

            do {
                try context.save()
            } catch {
                print("保存エラー: \(error)")
            }
    }
    func deletePlan(plan:Plan){
        context.delete(plan)
        
        do {
            try context.save()
        } catch {
            print("削除エラー: \(error)")
        }
    }
}

#Preview {
    PlanListView()
        .modelContainer(for: Plan.self)
}
