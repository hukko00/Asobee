import Foundation
import FirebaseFirestore

struct RemotePlan: Identifiable {
    let id: String
    let title: String
    let note: String
    let createdAt: Date?
}

final class FirebasePlanRepository {
    private let db = Firestore.firestore()

    func addPlan(title: String, note: String, completion: @escaping (Error?) -> Void) {
        db.collection("plans").addDocument(data: [
            "title": title,
            "note": note,
            "createdAt": Timestamp(date: Date())
        ]) { error in
            completion(error)
        }
    }

    func fetchPlans(completion: @escaping ([RemotePlan]?, Error?) -> Void) {
        db.collection("plans")
            .order(by: "createdAt", descending: true)
            .getDocuments { snapshot, error in
                if let error {
                    completion(nil, error)
                    return
                }

                let plans = snapshot?.documents.compactMap { document in
                    let data = document.data()

                    let title = data["title"] as? String ?? ""
                    let note = data["note"] as? String ?? ""
                    let timestamp = data["createdAt"] as? Timestamp

                    return RemotePlan(
                        id: document.documentID,
                        title: title,
                        note: note,
                        createdAt: timestamp?.dateValue()
                    )
                }

                completion(plans ?? [], nil)
            }
    }
}
