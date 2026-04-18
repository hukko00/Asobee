import FirebaseFirestore
import FirebaseAuth
import SwiftUI

struct Questions{
    var title:String
    var choicec:[String]
}
struct QuestionnaireView: View {
    var plan:PlanItem
    @State private var selected: String? = nil
    @State private var choices:[String] = [""]
    @State private var title:String = ""
    
    var body: some View {
        ScrollView{
            VStack(spacing: 20) {
                TextField("タイトル", text: $title)
                    .font(.custom("KiwiMaru-Regular", size: 25))
                    .padding(14)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.white)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.gray.opacity(0.2))
                    )
                    .padding(.horizontal, 20)
                
                // 選択肢
                ForEach(choices.indices, id: \.self) { index in
                    HStack(spacing: 10) {
                        
                        TextField("選択肢\(index + 1)", text: $choices[index])
                            .font(.custom("KiwiMaru-Regular", size: 21))
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white)
                            )
                        
                        Button {
                            choices.remove(at: index)
                        } label: {
                            Image(systemName: "minus.circle.fill")
                                .foregroundColor(.red)
                                .font(.system(size: 20))
                        }
                    }
                    .padding(.horizontal, 20)
                }
                
                Button{
                    choices.append("")
                } label:{
                    HStack {
                        Image(systemName:"plus")
                            .foregroundStyle(Color.black)
                        
                        Text("選択肢を追加")
                            .font(.custom("KiwiMaru-Regular", size: 20))
                            .foregroundColor(.black)
                        
                        Spacer()
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.2))
                    )
                    .padding(.horizontal,20)
                }
                Button{
                    createQuestion(title: title, choices: choices)
                } label:{
                    HStack {
                        Image(systemName:"checkmark")
                            .foregroundStyle(Color.black)
                        
                        Text("確定")
                            .font(.custom("KiwiMaru-Regular", size: 20))
                            .foregroundColor(.black)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.2))
                    )
                    .padding(.horizontal,20)
                }
            }
            .padding(.vertical,40)
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
