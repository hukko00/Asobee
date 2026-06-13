import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct AddPlanView: View {
    @State private var text = ""
    @State private var selectedFriendIds: [String] = []
    @State private var isNavigate = false
    @State private var errorMessage: String? = nil
    @State private var showError: Bool = false
    @EnvironmentObject var tabBarState: TabBarState
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        
        ZStack {
            
            Color(
                red: 247 / 255,
                green: 246 / 255,
                blue: 242 / 255
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                
                // ヘッダー
                ZStack {
                    
                    Text("プラン作成")
                        .font(.custom("KiwiMaru-Medium", size: 20))
                    
                    HStack {
                        
                        Button {
                            dismiss()
                        } label: {
                            
                            Image(systemName: "chevron.left")
                                .font(.system(size: 22))
                                .foregroundColor(
                                    Color(
                                        red: 255 / 255,
                                        green: 162 / 255,
                                        blue: 97 / 255
                                    )
                                )
                        }
                        
                        Spacer()
                    }
                }
                .padding(.horizontal, 20)
//                @
                NavigationLink {
                    
                    SelectFriendsView(
                        selectedFriends: $selectedFriendIds
                    )
                    
                } label: {
                    
                    HStack {
                        
                        Text("メンバーを選択")
                            .font(
                                .custom(
                                    "KiwiMaru-Regular",
                                    size: 18
                                )
                            )
                            .foregroundStyle(.black)
                        
                        Spacer()
                        
                        Text("\(selectedFriendIds.count)人")
                            .foregroundStyle(.gray)
                        
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.gray)
                    }
                    .padding()
                    .background(.white)
                    .cornerRadius(18)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    
                    Text("プランタイトル")
                        .font(
                            .custom(
                                "KiwiMaru-Regular",
                                size: 14
                            )
                        )
                        .foregroundStyle(.gray)
                    
                    TextField(
                        "例：遊びに行く",
                        text: $text
                    )
                    .font(
                        .custom(
                            "KiwiMaru-Regular",
                            size: 18
                        )
                    )
                    .padding()
                    .background(.white)
                    .cornerRadius(18)
                }
                
                Spacer()
                
                Button {
                    
                    createPlan(
                        title: text,
                        selectedFriendIds: selectedFriendIds
                    ) { error in
                        
                        if let error {
                            
                            errorMessage =
                            error.localizedDescription
                            
                            showError = true
                        }
                    }
                } label: {
                    
                    Text("プラン作成")
                        .font(
                            .custom(
                                "KiwiMaru-Medium",
                                size: 20
                            )
                        )
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            text.isEmpty
                            ? Color.gray
                            : Color(
                                red: 255 / 255,
                                green: 162 / 255,
                                blue: 97 / 255
                            )
                        )
                        .cornerRadius(18)
                }
                .disabled(text.isEmpty)
            }
            .padding()
        }
        .onAppear {
            tabBarState.isVisible = false
        }
        .navigationBarBackButtonHidden(true)
        .alert("エラー", isPresented: $showError) {
            
            Button("OK", role: .cancel) {}
            
        } message: {
            
            Text(errorMessage ?? "")
        }
    }
    
    func createPlan(
        title: String,
        selectedFriendIds: [String],
        completion: @escaping (Error?) -> Void
    ) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(NSError(domain: "AuthError", code: 0, userInfo: [NSLocalizedDescriptionKey: "ユーザーがいません"]))
            return
        }
        
        let db = Firestore.firestore()
        
        let planData: [String: Any] = [
            "title": title,
            "ownerId": userId,
            "inviteFriends": selectedFriendIds
        ]
        
        db.collection("plans").addDocument(data: planData) { error in
            if let error = error {
                print("作成失敗: \(error)")
                completion(error)
            } else {
                print("作成成功")
                dismiss()
                completion(nil)
            }
        }
    }
}
