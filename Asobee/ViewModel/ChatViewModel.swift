import Foundation
internal import Combine
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

class chatviewmodel:ObservableObject{
    @Published var chats: [ChatItem] = []
    @Published var times: [TimeItem] = []
    @Published var maps: [MapItem] = []
    @Published var questions: [QuestionItem] = []
    private var listeners: [ListenerRegistration] = []
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
    func listenChats(planId: String) {
        let db = Firestore.firestore()

        let listener = db.collection("plans")
            .document(planId)
            .collection("messages")
            .order(by: "createdAt")
            .addSnapshotListener { [weak self] snapshot, error in
                
                guard let documents = snapshot?.documents else { return }

                let chats = documents.compactMap { doc -> ChatItem? in
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
                        senderName: senderName
                    )
                }

                DispatchQueue.main.async {
                    self?.chats = chats
                }
            }

        listeners.append(listener)
    }
    func listenMaps(planId: String) {
        let db = Firestore.firestore()
        
        db.collection("plans")
            .document(planId)
            .collection("maps")
            .order(by: "createdAt")
            .getDocuments { snapshot, _ in
                
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
    func createChat(chat: String, planId: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let db = Firestore.firestore()
        
        db.collection("users").document(uid).getDocument { snapshot, _ in
            
            let name = snapshot?.data()?["userName"] as? String ?? "不明"
            
            db.collection("plans")
                .document(planId) // ←ここ修正
                .collection("messages")
                .addDocument(data: [
                    "createdAt": Timestamp(date: Date()),
                    "chat": chat,
                    "senderId": uid,
                    "senderName": name
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
        listenChats(planId: planId)
        listenTimes(planId: planId)
        listenMaps(planId: planId)
        listenQuestions(planId: planId)
    }
    func stop() {
        listeners.forEach { $0.remove() }
        listeners.removeAll()
    }
}
