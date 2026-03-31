import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct TimeItem: Identifiable {
    let id: String
    let departureTime: String
    let departureStation: String
    let arrivalTime: String
    let arrivalStation: String
}
struct ChatItem: Identifiable {
    let id: String
    let chat: String
    let createdAt: Date
    let senderId: String
}
struct ChatView: View {
    var plan: PlanItem
    @State private var chats: [ChatItem] = []
    @State private var times: [TimeItem] = []
    @State private var listener: ListenerRegistration?
    @State var text: String = ""
    @EnvironmentObject var tabBarState: TabBarState
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color(colorcode(r: 247, g: 246, b: 242))//247, 246, 242
                .ignoresSafeArea()
            
            VStack {
                ZStack {
                    // タイトル（常に中央）
                    Text(plan.title)
                        .font(.custom("KiwiMaru-Medium", size: 18))
                    
                    HStack {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.custom("KiwiMaru-Regular", size: 22))
                                .foregroundColor(colorcode(r: 255, g: 162, b: 97))
                        }
                        
                        Spacer()
                    }
                }
                .padding(.horizontal, 20)
                ScrollView {
                    LazyVStack(alignment: .leading) {
                        ForEach(chats) { chat in
                            HStack{
                                if chat.senderId == Auth.auth().currentUser?.uid {
                                    Spacer()
                                    Text(chat.chat)
                                        .padding(8)
                                        .font(Font.custom("KiwiMaru-Regular", size: 20))
                                        .background(colorcode(r: 255, g: 162, b: 97))
                                        .cornerRadius(10)
                                        .padding(.horizontal,30)
                                } else{
                                    Text(chat.chat)
                                        .padding(8)
                                        .font(Font.custom("KiwiMaru-Regular", size: 20))
                                        .background(colorcode(r: 127, g: 183, b: 126))
                                        .cornerRadius(10)
                                        .padding(.horizontal,30)
                                    Spacer()
                                }
                            }
                        }
                    }
                }
                Spacer()
                
                HStack(spacing: 12) {
                    Button{
                        
                    } label:{
                        Image(systemName: "plus")
                            .font(.custom("KiwiMaru-Regular", size: 22))
                            .foregroundColor(colorcode(r: 127, g: 183, b: 126))
                    }
                    Button{
                        
                    } label:{
                        Image(systemName: "photo")
                            .font(.system(size: 22))
                            .foregroundColor(colorcode(r: 127, g: 183, b: 126))
                    }
                    
                    TextField("メッセージを入力", text: $text)
                        .font(.custom("KiwiMaru-Regular", size: 20))
                        .padding(10)
                        .background(Color.white)
                        .cornerRadius(12)
                    Button{
                        createChat(chat: text)
                        text = ""
                    } label:{
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(colorcode(r: 255, g: 162, b: 97))
                            .font(.system(size: 22))
                    }
                }
                .padding(12)
                .background(colorcode(r: 234, g: 231, b: 220))
                .cornerRadius(20)
                .padding(.horizontal, 16)
                .padding(.bottom, 10)
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            listenChats(planId: plan.id) { result in
                self.chats = result
            }
        }
        .onAppear {
            tabBarState.isVisible = false
        }
        
        .onDisappear {
            tabBarState.isVisible = true
        }
        .onAppear {
            listenTimes(planId: plan.id)
        }
        .onDisappear {
            listener?.remove()
        }
    }
    func colorcode(r:Int,g:Int,b:Int)-> Color{
        return Color(red: Double(r)/255, green: Double(g)/255, blue: Double(b)/255)
    }
    func listenTimes(planId: String) {
        let db = Firestore.firestore()
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        
        listener = db.collection("plans")
            .document(planId)
            .collection("times")
            .order(by: "departureTime") // ← ここ変更
            .addSnapshotListener { snapshot, error in
                
                if error != nil {
                    return
                }
                
                guard let snapshot = snapshot else {
                    return
                }
                
                var results: [TimeItem] = []
                
                for doc in snapshot.documents {
                    let data = doc.data()
                    
                    print("📄 docID:", doc.documentID)
                    print("📄 data:", data)
                    
                    guard let departureTimestamp = data["departureTime"] as? Timestamp,
                          let arrivalTimestamp = data["arrivalTime"] as? Timestamp,
                          let departureStation = data["departureStation"] as? String,
                          let arrivalStation = data["arrivalStation"] as? String else {
                        
                        continue
                    }
                    
                    let departureTimeString = formatter.string(from: departureTimestamp.dateValue())
                    let arrivalTimeString = formatter.string(from: arrivalTimestamp.dateValue())
                    
                    let time = TimeItem(
                        id: doc.documentID,
                        departureTime: departureTimeString,
                        departureStation: departureStation,
                        arrivalTime: arrivalTimeString,
                        arrivalStation: arrivalStation
                    )
                    
                    results.append(time)
                }
                
                
                DispatchQueue.main.async {
                    self.times = results
                }
            }
    }
    
    // 削除
    func deleteTimeItem(time: TimeItem) {
        let db = Firestore.firestore()
        
        db.collection("plans")
            .document(plan.id)
            .collection("times")
            .document(time.id)
            .delete { error in
                if error != nil {
                } else {
                }
            }
    }
    func createChat(chat: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let db = Firestore.firestore()
        
        db.collection("plans")
            .document(plan.id)
            .collection("messages")
            .addDocument(data: [
                "createdAt": Timestamp(date: Date()),
                "chat": chat,
                "senderId": uid // ← これ追加
            ]) { error in
                
                if let error = error {
                    print("❌ 作成失敗:", error)
                } else {
                    print("✅ 作成成功")
                }
            }
    }
    func listenChats(planId: String, completion: @escaping ([ChatItem]) -> Void) {
        let db = Firestore.firestore()
        
        db.collection("plans")
            .document(planId)
            .collection("messages")
            .order(by: "createdAt")
            .addSnapshotListener { snapshot, error in
                
                if let error = error {
                    print("❌ 取得失敗:", error)
                    completion([])
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    completion([])
                    return
                }
                
                let chats: [ChatItem] = documents.compactMap { doc in
                    let data = doc.data()
                    
                    guard let chat = data["chat"] as? String,
                          let timestamp = data["createdAt"] as? Timestamp,
                          let senderId = data["senderId"] as? String else {
                        return nil
                    }
                    
                    return ChatItem(
                        id: doc.documentID,
                        chat: chat,
                        createdAt: timestamp.dateValue(),
                        senderId: senderId
                    )
                }
                
                completion(chats)
            }
    }
}
#Preview {
    ChatView(
        plan: PlanItem(
            id: "test",
            title: "テストプラン",
            ownerId: "user",
            inviteFriends: []
        )
    )
    .environmentObject(TabBarState())
}
