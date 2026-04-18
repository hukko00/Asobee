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
    let senderName: String
}
struct MapItem: Identifiable {
    let id: String
    let lat: Double
    let lng: Double
    let createdAt: Date
    let senderId: String
    let senderName: String
}

enum ItemType {
    case chat
    case map
    case question   // ←追加
}

struct TimelineItem: Identifiable {
    let id: String
    let senderId: String
    let senderName: String
    let createdAt: Date
    let type: ItemType
    
    let chat: String?
    let lat: Double?
    let lng: Double?
    let title: String?
    let choices: [String]?
}

struct QuestionItem: Identifiable {
    let id: String
    let title: String
    let choices: [String]
    let createdAt: Date
    let senderId: String
    let senderName: String
}

struct ChatView: View {
    var plan: PlanItem
    @State private var chats: [ChatItem] = []
    @State private var times: [TimeItem] = []
    @State private var maps: [MapItem] = []
    @State private var listener: ListenerRegistration?
    @State var text: String = ""
    @EnvironmentObject var tabBarState: TabBarState
    @Environment(\.dismiss) var dismiss
    @State private var showScrollButton = false
    @State private var showPlusMenu = false
    @State private var navigationNumber = 0
    @State private var questions: [QuestionItem] = []
    
    var body: some View {
        ZStack {
            Color(colorcode(r: 247, g: 246, b: 242))
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
                ScrollViewReader { proxy in
                    ZStack(alignment: .bottomTrailing) {
                        
                        ScrollView {
                            LazyVStack(alignment: .leading, spacing: 12) {
                                
                                let items = makeTimelineItems(
                                    chats: chats,
                                    maps: maps,
                                    questions: questions
                                )
                                
                                ForEach(items) { item in
                                    HStack {
                                        
                                        if item.senderId == Auth.auth().currentUser?.uid ?? "" {
                                            Spacer()
                                            messageView(item: item, isMe: true)
                                        } else {
                                            messageView(item: item, isMe: false)
                                            Spacer()
                                        }
                                    }
                                    .padding(.horizontal, 8)
                                    .id(item.id)
                                }
                            }
                            .padding(.vertical, 10)
                        }
                        
                        if showScrollButton {
                            Button {
                                let items = makeTimelineItems(
                                    chats: chats,
                                    maps: maps,
                                    questions: questions
                                )
                                
                                if let last = items.last {
                                    withAnimation {
                                        proxy.scrollTo(last.id, anchor: .bottom)
                                    }
                                }
                                
                                showScrollButton = false
                            } label: {
                                Image(systemName: "arrow.down.circle.fill")
                                    .font(.system(size: 44))
                                    .foregroundStyle(Color.gray.opacity(0.7))
                                    .background(
                                        Circle()
                                            .fill(Color.white)
                                            .shadow(radius: 4)
                                    )
                            }
                            .padding(.trailing, 16)
                            .padding(.bottom, 16)
                        }
                    }
                    .onChange(of: chats.count) {
                        showScrollButton = true
                    }
                }
                Spacer()
                
                HStack(spacing: 10) {
                    Button {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            showPlusMenu.toggle()
                        }
                    } label:{
                        Image(systemName: "plus")
                            .font(.system(size: 20))
                            .foregroundColor(colorcode(r: 127, g: 183, b: 126))
                    }

                    Button{
                        
                    } label:{
                        Image(systemName: "photo")
                            .font(.system(size: 20))
                            .foregroundColor(colorcode(r: 127, g: 183, b: 126))
                    }

                    TextField("メッセージを入力", text: $text)
                        .font(.custom("KiwiMaru-Regular", size: 18))
                        .padding(10)
                        .background(Color.white)
                        .cornerRadius(10)

                    Button{
                        if !text.isEmpty {
                            createChat(chat: text)
                            text = ""
                        }
                    } label:{
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 20))
                            .foregroundColor(colorcode(r: 255, g: 162, b: 97))
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(colorcode(r: 234, g: 231, b: 220))
                )
                .padding(.horizontal, 12)
                .padding(.bottom, 10)
            }
            if showPlusMenu {
                
                Color.black.opacity(0.2)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation {
                            showPlusMenu = false
                        }
                    }
                
                VStack {
                    Spacer()
                    
                    PlusButtonView { number in
                        showPlusMenu = false
                        navigationNumber = number
                    }
                    .padding(.bottom, 90)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: showPlusMenu)
        .navigationDestination(isPresented: Binding(
            get: { navigationNumber != 0 },
            set: { _ in navigationNumber = 0 }
        )) {
            
            switch navigationNumber {
            case 1:
                QuestionnaireView(plan: plan)
                
            case 2:
                ItineraryView()
                
            case 3:
                MapView(plan: plan)
                
            case 4:
                RouteView()
                
            default:
                EmptyView()
            }
        }
        .navigationBarBackButtonHidden(true)
        
        .onAppear {
            listenChats(planId: plan.id) { result in
                self.chats = result
            }
        }
        .onAppear {
            listenTimes(planId: plan.id)
        }
        .onDisappear {
            listener?.remove()
        }
        .onAppear {
            listenMaps(planId: plan.id)
        }
        .onAppear {
            listenQuestions(planId: plan.id)
        }
        .task {
            tabBarState.isVisible = false
            print("taskOK")
        }
        
        .onDisappear{
            tabBarState.isVisible = true
            print("DisappearOK")
        }
        .onChange(of: tabBarState.isVisible) {
            print("TabBar:", tabBarState.isVisible)
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
        
        // 先に自分の名前取得（簡易）
        db.collection("users").document(uid).getDocument { snapshot, _ in
            
            let name = snapshot?.data()?["userName"] as? String ?? "不明"
            
            db.collection("plans")
                .document(plan.id)
                .collection("messages")
                .addDocument(data: [
                    "createdAt": Timestamp(date: Date()),
                    "chat": chat,
                    "senderId": uid,
                    "senderName": name // ← 追加
                ])
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
                          let senderId = data["senderId"] as? String,
                          let senderName = data["senderName"] as? String else {
                        return nil
                    }
                    
                    return ChatItem(
                        id: doc.documentID,
                        chat: chat,
                        createdAt: timestamp.dateValue(),
                        senderId: senderId,
                        senderName: senderName // ← 追加
                    )
                }
                
                completion(chats)
            }
    }
    func getUserName(uid: String, completion: @escaping (String) -> Void) {
        let db = Firestore.firestore()
        
        db.collection("users")
            .document(uid)
            .getDocument { snapshot, error in
                
                if let data = snapshot?.data(),
                   let name = data["userName"] as? String {
                    completion(name)
                } else {
                    completion("不明")
                }
            }
    }
    @ViewBuilder
    func messageView(item: TimelineItem, isMe: Bool) -> some View {
        VStack(alignment: isMe ? .trailing : .leading, spacing: 4) {
            
            if item.type == .chat {
                
                Text(item.chat ?? "")
                    .padding(12)
                    .font(.custom("KiwiMaru-Regular", size: 18))
                    .background(
                        isMe ?
                        colorcode(r: 255, g: 162, b: 97)
                        :
                            colorcode(r: 127, g: 183, b: 126)
                    )
                    .cornerRadius(14)
                
            } else if item.type == .map {
                
                VStack(spacing: 6) {
                    Image(systemName: "map.fill")
                        .font(.system(size: 26))
                    
                    Text("位置情報")
                        .font(.caption)
                }
                .padding(12)
                .background(
                    isMe ?
                    colorcode(r: 255, g: 162, b: 97)
                    :
                        colorcode(r: 127, g: 183, b: 126)
                )
                .cornerRadius(14)
                
            } else if item.type == .question {
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(item.title ?? "")
                        .font(.custom("KiwiMaru-Regular", size: 18))
                        .bold()
                    
                    ForEach(item.choices ?? [], id: \.self) { choice in
                        Text("・\(choice)")
                            .font(.custom("KiwiMaru-Regular", size: 16))
                    }
                }
                .padding(12)
                .background(
                    isMe ?
                    colorcode(r: 255, g: 162, b: 97)
                    :
                        colorcode(r: 127, g: 183, b: 126)
                )
                .cornerRadius(14)
            }
            
            Text(item.senderName)
                .font(.custom("KiwiMaru-Regular", size: 11))
                .foregroundColor(.gray)
        }
        .padding(.horizontal, 16)
    }
    func makeTimelineItems(
        chats: [ChatItem],
        maps: [MapItem],
        questions: [QuestionItem]
    ) -> [TimelineItem] {
        
        let chatItems = chats.map {
            TimelineItem(
                id: $0.id,
                senderId: $0.senderId,
                senderName: $0.senderName,
                createdAt: $0.createdAt,
                type: .chat,
                chat: $0.chat,
                lat: nil,
                lng: nil,
                title: nil,
                choices: nil
            )
        }
        
        let mapItems = maps.map {
            TimelineItem(
                id: $0.id,
                senderId: $0.senderId,
                senderName: $0.senderName,
                createdAt: $0.createdAt,
                type: .map,
                chat: nil,
                lat: $0.lat,
                lng: $0.lng,
                title: nil,
                choices: nil
            )
        }
        
        let questionItems = questions.map {
            TimelineItem(
                id: $0.id,
                senderId: $0.senderId,
                senderName: $0.senderName,
                createdAt: $0.createdAt,
                type: .question,
                chat: nil,
                lat: nil,
                lng: nil,
                title: $0.title,
                choices: $0.choices
            )
        }
        
        return (chatItems + mapItems + questionItems)
            .sorted { $0.createdAt < $1.createdAt }
    }
    func listenMaps(planId: String) {
        let db = Firestore.firestore()
        
        db.collection("plans")
            .document(planId)
            .collection("maps")
            .order(by: "createdAt")
            .addSnapshotListener { snapshot, _ in
                
                guard let snapshot = snapshot else { return }
                
                var results: [MapItem] = []
                
                for doc in snapshot.documents {
                    let data = doc.data()
                    
                    guard
                        let lat = data["latitude"] as? Double,
                        let lng = data["longitude"] as? Double,
                        let senderId = data["senderId"] as? String,
                        let senderName = data["senderName"] as? String,
                        let timestamp = data["createdAt"] as? Timestamp
                    else { continue }
                    
                    results.append(
                        MapItem(
                            id: doc.documentID,
                            lat: lat,
                            lng: lng,
                            createdAt: timestamp.dateValue(),
                            senderId: senderId,
                            senderName: senderName
                        )
                    )
                }
                
                self.maps = results
            }
    }
    func listenQuestions(planId: String) {
        let db = Firestore.firestore()
        
        db.collection("plans")
            .document(planId)
            .collection("questions")
            .order(by: "createdAt")
            .addSnapshotListener { snapshot, _ in
                
                guard let snapshot = snapshot else { return }
                
                var results: [QuestionItem] = []
                
                for doc in snapshot.documents {
                    let data = doc.data()
                    
                    guard
                        let title = data["title"] as? String,
                        let choices = data["choices"] as? [String],
                        let senderId = data["senderId"] as? String,
                        let senderName = data["senderName"] as? String,
                        let timestamp = data["createdAt"] as? Timestamp
                    else { continue }
                    
                    results.append(
                        QuestionItem(
                            id: doc.documentID,
                            title: title,
                            choices: choices,
                            createdAt: timestamp.dateValue(),
                            senderId: senderId,
                            senderName: senderName
                        )
                    )
                }
                
                self.questions = results
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
