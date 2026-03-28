import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct AddPlanView: View {
    @State private var text = ""
    @State private var selectedFriendIds: [String] = []
    @State private var isNavigate = false
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                NavigationLink {
                    SelectFriendsView(selectedFriends: $selectedFriendIds)
                } label: {
                    HStack {
                        Text("メンバーを選択")
                        Spacer()
                        Text("\(selectedFriendIds.count)人")
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }
                
                VStack(alignment: .leading) {
                    Text("プランタイトル")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    TextField("例：遊びに行く", text: $text)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                }
                Spacer()
                Button {
                    createPlan(title: text, selectedFriendIds: selectedFriendIds)
                    isNavigate = true
                } label: {
                    Text("プラン作成")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(text.isEmpty ? Color.gray : Color.blue)
                        .cornerRadius(12)
                }
                .disabled(text.isEmpty)
                .navigationDestination(isPresented: $isNavigate) {
                    PlanView()
                }
                
            }
            .padding()
            .navigationTitle("プラン作成")
        }
    }
    
    func createPlan(title: String, selectedFriendIds: [String]) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        
        let planData: [String: Any] = [
            "title": title,
            "ownerId": userId,
            "inviteFriends": selectedFriendIds
        ]
        
        db.collection("plans").addDocument(data: planData) { error in
            if let error = error {
                print("作成失敗: \(error)")
            } else {
                print("作成成功")
                dismiss() 
            }
        }
    }
}
