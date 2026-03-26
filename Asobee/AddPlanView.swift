import SwiftUI
import FirebaseFirestore
import FirebaseAuth


struct AddPlanView: View {
    @State private var text = ""
    @State private var selectedfriendIds: [String] = []
    var body: some View {
        VStack {
            TextField(
                "プランのタイトル",
                text: $text
            )
            .disableAutocorrection(true)
            
            Button{
                createPlan(title: text, selectedFriendIds: [])
            } label:{
                Text("送信")
                    .font(Font.title.bold())
                    .foregroundStyle(Color.white)
                    .padding(10)
                    .background(Color.blue)
                    .clipShape(Capsule())
            }
        }
        .textFieldStyle(.roundedBorder)

    }
    func createPlan(title: String, selectedFriendIds: [String]) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        let members = [userId] + selectedFriendIds
        
        let planData: [String: Any] = [
            "title": title,
            "ownerId": userId,
            "members": members,
            "createdAt": Timestamp()
        ]
        db.collection("plans").addDocument(data: planData) { error in
            if let error = error {
                print("作成失敗: \(error)")
            } else {
                print("作成成功")
            }
        }
    }
}
#Preview {
    AddPlanView()
}
