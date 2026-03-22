import Foundation
import SwiftData

@Model
final class schedule {
    var title: String
    var note: String
    var timedata: Date
    var imageData: Data?
    var linkData:URL?
    var dateCandidates: [DateCandidate]
    var placeCandidates: [PlaceCandidate]

    init(
        title: String,
        note: String = "",
        timedata: Date = .now,
        imageData:Data? = nil,
        linkData:URL? = nil,
        dateCandidates: [DateCandidate] = [],
        placeCandidates: [PlaceCandidate] = []
    ) {
        self.title = title
        self.note = note
        self.timedata = timedata
        self.imageData = imageData
        self.linkData = linkData
        self.dateCandidates = dateCandidates
        self.placeCandidates = placeCandidates
    }
}
@Model
final class Plan {
    var plantitle: String
    var planimageData: Data
    var planColor: Int
    var planDate: Date
    init(plantitle: String, planimageData: Data, planColor: Int, planDate: Date) {
        self.plantitle = plantitle
        self.planimageData = planimageData
        self.planColor = planColor
        self.planDate = planDate
    }
}
@Model
final class DateCandidate {
    var date: Date
    var availability: Int   // 0: 行けない, 1: 微妙, 2: 行ける

    init(date: Date, availability: Int = 2) {
        self.date = date
        self.availability = availability
    }
}

@Model
final class PlaceCandidate {
    var name: String
    var votes: Int

    init(name: String, votes: Int = 0) {
        self.name = name
        self.votes = votes
    }
}
