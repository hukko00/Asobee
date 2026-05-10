import FirebaseFirestore
import FirebaseAuth
import SwiftUI

struct Questions{
    var title:String
    var choicec:[String]
}
struct QuestionnaireView: View {
    var plan:PlanItem
    var isValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty &&
        choices.filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }.count >= 2
    }
    @State private var selected: String? = nil
    @State private var choices:[String] = [""]
    @State private var title:String = ""
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {

                    VStack(alignment: .leading, spacing: 8) {
                        Text("アンケート作成")
                            .font(.title.bold())
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)

                    TextField("タイトル", text: $title)
                        .padding()
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: .black.opacity(0.05), radius: 5)

                    ForEach(choices.indices, id: \.self) { index in
                        HStack {

                            TextField("選択肢\(index + 1)", text: $choices[index])

                            Button {
                                if choices.count > 1 {
                                    choices.remove(at: index)
                                }
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(.red)
                            }
                        }
                        .padding()
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: .black.opacity(0.05), radius: 5)
                    }

                    Button {
                        withAnimation {
                            choices.append("")
                        }
                    } label: {
                        Label("選択肢を追加", systemImage: "plus")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }

                    Button {
                        createQuestion(title: title, choices: choices)
                        dismiss()
                    } label: {
                        Text("作成する")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isValid ? Color.blue : Color.gray)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .disabled(!isValid)

                }
                .padding()
            }
        }
    }
    func createQuestion(title:String,choices:[String]) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let db = Firestore.firestore()
        
        db.collection("users").document(uid).getDocument { snapshot, _ in
            
            let name = snapshot?.data()?["userName"] as? String ?? "不明"
            
            db.collection("plans")
                .document(plan.id)
                .collection("questions")
                .addDocument(data: [
                    "title": title,
                    "choices":choices,
                    "createdAt": Timestamp(date: Date()),
                    "senderId": uid,
                    "senderName": name
                ])
        }
    }
}

#Preview {
    NavigationStack {
        QuestionnaireView(
            plan: PlanItem(
                id: "preview-id",
                title: "テストプラン",
                ownerId: "user1",
                inviteFriends: ["user2","user3"]
            )
        )
    }
}
