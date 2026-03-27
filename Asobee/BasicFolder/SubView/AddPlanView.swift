import SwiftUI
import FirebaseFirestore
import FirebaseAuth


struct AddPlanView: View {
    @State private var text = ""
    @State private var selectedfriendIds: [String] = []
    let uid = Auth.auth().currentUser?.uid
    var body: some View {
        NavigationStack{
            VStack {
                NavigationLink{
                    
                } label:{
                    
                }
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

    }
    func createPlan(title: String, selectedFriendIds: [String]) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        _ = [userId] + selectedFriendIds
        
        let planData: [String: Any] = [
            "title": title,
            "ownerId": userId,
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
