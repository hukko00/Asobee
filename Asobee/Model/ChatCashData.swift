import SwiftData
import Foundation

@Model
class CachedChatMessage {

    var id: String
    var text: String
    var senderId: String
    var senderName: String
    var createdAt: Date

    init(
        id: String,
        text: String,
        senderId: String,
        senderName: String,
        createdAt: Date
    ) {
        self.id = id
        self.text = text
        self.senderId = senderId
        self.senderName = senderName
        self.createdAt = createdAt
    }
}
