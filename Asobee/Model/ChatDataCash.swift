import SwiftData
import SwiftUI
import Foundation

@Model
final class CachedChat {

    var id: String
    var planId: String
    var chat: String
    var senderId: String
    var senderName: String
    var createdAt: Date

    init(
        id: String,
        planId: String,
        chat: String,
        senderId: String,
        senderName: String,
        createdAt: Date
    ) {
        self.id = id
        self.planId = planId
        self.chat = chat
        self.senderId = senderId
        self.senderName = senderName
        self.createdAt = createdAt
    }
}
