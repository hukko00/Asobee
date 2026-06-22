import Foundation
internal import Combine
import FirebaseFirestore
import FirebaseAuth
import SwiftData

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
    let readUsers: [String]
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
    case question
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
    let readUsers: [String]?
}

struct QuestionItem: Identifiable {
    let id: String
    let title: String
    let choices: [String]
    let answerCounts: [String:Int]
    let answeredUsers: [String]
    let createdAt: Date
    let senderId: String
    let senderName: String
}

class chatviewmodel:ObservableObject{
    @Published var chats: [ChatItem] = []
    @Published var times: [TimeItem] = []
    @Published var maps: [MapItem] = []
    @Published var questions: [QuestionItem] = []
    @Published var isLoading = false
    @Published var hasMoreChats = true
    private var lastDocument: DocumentSnapshot?
    private let pageSize = 15
    private let loadSize = 10
    private var listeners: [ListenerRegistration] = []
    var context: ModelContext?
    func listenTimes(planId: String) {
        let db = Firestore.firestore()
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        
        let listener = db.collection("plans")
            .document(planId)
            .collection("times")
            .order(by: "departureTime")
            .addSnapshotListener { [weak self] snapshot, error in
                
                if let error = error {
                    print("❌ error:", error)
                    return
                }
                
                guard let snapshot = snapshot else { return }
                
                var results: [TimeItem] = []
                
                for doc in snapshot.documents {
                    let data = doc.data()
                    
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
                    self?.times = results
                }
            }
        
        listeners.append(listener)
    }
    func loadChatsFromCache(planId: String) {
        
        guard let context else { return }
        
        do {
            let descriptor = FetchDescriptor<CachedChat>(
                predicate: #Predicate {
                    $0.planId == planId
                },
                sortBy: [
                    SortDescriptor(\.createdAt)
                ]
            )
            
            let cachedChats = try context.fetch(descriptor)
            
            self.chats = cachedChats.map {
                ChatItem(
                    id: $0.id,
                    chat: $0.chat,
                    createdAt: $0.createdAt,
                    senderId: $0.senderId,
                    senderName: $0.senderName,
                    readUsers: []
                )
            }
            
            print("キャッシュ読込: \(cachedChats.count)件")
            
        } catch {
            print("キャッシュ読込失敗: \(error)")
        }
    }
    func loadFirstChats(planId: String) {

        let db = Firestore.firestore()

        db.collection("plans")
            .document(planId)
            .collection("messages")
            .order(by: "createdAt", descending: true)
            .limit(to: 15)
            .getDocuments { [weak self] snapshot, error in

                guard let self = self else { return }

                if let error = error {
                    print("チャット取得失敗: \(error)")
                    return
                }

                guard let docs = snapshot?.documents else { return }

                self.lastDocument = docs.last

                let messages: [ChatItem] = docs.compactMap { doc in

                    let data = doc.data()

                    guard
                        let chat = data["chat"] as? String,
                        let timestamp = data["createdAt"] as? Timestamp,
                        let senderId = data["senderId"] as? String,
                        let senderName = data["senderName"] as? String
                    else {
                        return nil
                    }

                    return ChatItem(
                        id: doc.documentID,
                        chat: chat,
                        createdAt: timestamp.dateValue(),
                        senderId: senderId,
                        senderName: senderName,
                        readUsers: data["readUsers"] as? [String] ?? []
                    )
                }

                DispatchQueue.main.async {
                    self.chats = messages
                    // ここでSwiftDataへ保存
                    self.saveChatsToCache(
                        messages,
                        planId: planId
                    )
                }
            }
    }
    func loadMoreChats(planId: String) {
        guard hasMoreChats else { return }
        guard !isLoading else { return }
        print("loadMoreChats")
        isLoading = true
        
        guard let lastDocument else {
            isLoading = false
            return
        }
        
        let db = Firestore.firestore()
        
        db.collection("plans")
            .document(planId)
            .collection("messages")
            .order(by: "createdAt", descending: true)
            .start(afterDocument: lastDocument)
            .limit(to: loadSize)
            .getDocuments { [weak self] snapshot, error in
                
                guard let docs = snapshot?.documents else { return }
                
                self?.lastDocument = docs.last
                
                let newChats = docs.compactMap { doc -> ChatItem? in
                    
                    let data = doc.data()
                    
                    guard
                        let chat = data["chat"] as? String,
                        let timestamp = data["createdAt"] as? Timestamp,
                        let senderId = data["senderId"] as? String,
                        let senderName = data["senderName"] as? String
                    else { return nil }
                    
                    return ChatItem(
                        id: doc.documentID,
                        chat: chat,
                        createdAt: timestamp.dateValue(),
                        senderId: senderId,
                        senderName: senderName,
                        readUsers: data["readUsers"] as? [String] ?? []
                    )
                }
                DispatchQueue.main.async {
                    if docs.count < self?.loadSize ?? 0 {
                        self?.hasMoreChats = false
                    }
                    let sortedChats = newChats.reversed()
                    self?.chats.insert(contentsOf: sortedChats, at: 0)
                    self?.isLoading = false
                }
            }
    }
    func listenQuestions(planId: String) {
        let db = Firestore.firestore()
        
        db.collection("plans")
            .document(planId)
            .collection("questions")
            .order(by: "createdAt")
            .getDocuments { snapshot, _ in
                
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
                    
                    let answerCounts =
                    data["answerCounts"] as? [String:Int] ?? [:]
                    let answeredUsers = data["answeredUsers"] as? [String] ?? []
                    
                    results.append(
                        QuestionItem(
                            id: doc.documentID,
                            title: title,
                            choices: choices,
                            answerCounts: answerCounts,
                            answeredUsers: answeredUsers,
                            createdAt: timestamp.dateValue(),
                            senderId: senderId,
                            senderName: senderName
                        )
                    )
                }
                
                self.questions = results
            }
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
                choices: nil,
                readUsers: $0.readUsers
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
                choices: nil,
                readUsers:nil
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
                choices: $0.choices,
                readUsers:nil
            )
        }
        
        return (chatItems + mapItems + questionItems)
            .sorted { $0.createdAt < $1.createdAt }
    }
    func createChat(chat: String, planId: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let db = Firestore.firestore()
        
        db.collection("users").document(uid).getDocument { snapshot, _ in
            
            let name = snapshot?.data()?["userName"] as? String ?? "不明"
            
            db.collection("plans")
                .document(planId)
                .collection("messages")
                .addDocument(data: [
                    "createdAt": Timestamp(date: Date()),
                    "chat": chat,
                    "senderId": uid,
                    "senderName": name,
                    "readUsers": [uid]
                ])
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
    func start(planId: String) {
        loadChatsFromCache(planId: planId)
        loadFirstChats(planId: planId)
        listenChats(planId: planId)
        listenTimes(planId: planId)
        listenQuestions(planId: planId)
    }
    func stop() {
        listeners.forEach { $0.remove() }
        listeners.removeAll()
    }
    func enableSwipeBack() {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let navigationController = scene.windows.first?.rootViewController as? UINavigationController
        else { return }
        
        navigationController.interactivePopGestureRecognizer?.isEnabled = true
    }
    func markAllAsRead(planId: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let db = Firestore.firestore()
        
        db.collection("plans")
            .document(planId)
            .collection("messages")
            .getDocuments { snapshot, error in
                
                guard let docs = snapshot?.documents else { return }
                
                for doc in docs {
                    doc.reference.updateData([
                        "readUsers": FieldValue.arrayUnion([uid])
                    ])
                }
            }
    }
    func listenChats(planId: String) {

        let db = Firestore.firestore()

        let listener = db.collection("plans")
            .document(planId)
            .collection("messages")
            .order(by: "createdAt")
            .addSnapshotListener { [weak self] snapshot, error in

                guard let self = self else { return }

                if let error = error {
                    print("チャット監視失敗: \(error)")
                    return
                }

                guard let snapshot else { return }

                for change in snapshot.documentChanges {

                    guard change.type == .added else { continue }

                    let data = change.document.data()

                    guard
                        let chat = data["chat"] as? String,
                        let timestamp = data["createdAt"] as? Timestamp,
                        let senderId = data["senderId"] as? String,
                        let senderName = data["senderName"] as? String
                    else {
                        continue
                    }

                    let item = ChatItem(
                        id: change.document.documentID,
                        chat: chat,
                        createdAt: timestamp.dateValue(),
                        senderId: senderId,
                        senderName: senderName,
                        readUsers: data["readUsers"] as? [String] ?? []
                    )

                    // 重複防止
                    if self.chats.contains(where: { $0.id == item.id }) {
                        continue
                    }

                    DispatchQueue.main.async {

                        self.chats.append(item)

                        self.saveNewChat(
                            item,
                            planId: planId
                        )
                    }
                }
            }

        listeners.append(listener)
    }
    func saveNewChat(
        _ item: ChatItem,
        planId: String
    ) {

        guard let context else { return }

        do {
            let chatId = item.id

            let exists = try context.fetch(
                FetchDescriptor<CachedChat>(
                    predicate: #Predicate<CachedChat> {
                        $0.id == chatId
                    }
                )
            )

            if !exists.isEmpty {
                return
            }

            let chat = CachedChat(
                id: item.id,
                planId: planId,
                chat: item.chat,
                senderId: item.senderId,
                senderName: item.senderName,
                createdAt: item.createdAt
            )

            context.insert(chat)

            let allChats = try context.fetch(
                FetchDescriptor<CachedChat>(
                    predicate: #Predicate {
                        $0.planId == planId
                    },
                    sortBy: [
                        SortDescriptor(
                            \.createdAt,
                            order: .reverse
                        )
                    ]
                )
            )

            if allChats.count > 15 {

                for oldChat in allChats.dropFirst(15) {
                    context.delete(oldChat)
                }
            }

            try context.save()

        } catch {
            print("キャッシュ更新失敗: \(error)")
        }
    }
    func formatTime(_ date: Date) -> String {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        
        return formatter.string(from: date)
    }
    func saveChatsToCache(
        _ chats: [ChatItem],
        planId: String
    ) {
        
        guard let context else { return }
        
        do {
            let descriptor = FetchDescriptor<CachedChat>(
                predicate: #Predicate {
                    $0.planId == planId
                }
            )
            
            let oldChats = try context.fetch(descriptor)
            
            for chat in oldChats {
                context.delete(chat)
            }
            
            for item in chats {
                
                let cachedChat = CachedChat(
                    id: item.id,
                    planId: planId,
                    chat: item.chat,
                    senderId: item.senderId,
                    senderName: item.senderName,
                    createdAt: item.createdAt
                )
                
                context.insert(cachedChat)
            }
            
            try context.save()
            
        } catch {
            print("キャッシュ保存失敗: \(error)")
        }
    }
}
