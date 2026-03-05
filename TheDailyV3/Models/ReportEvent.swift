import Foundation
import SwiftData

@Model
final class ReportEvent {
    var id: UUID = UUID()
    var title: String = ""
    var timestamp: Date = Date()
    var note: String = ""
    
    var report: DailyReport?
    
    init(title: String = "", note: String = "", timestamp: Date = Date()) {
        self.id = UUID()
        self.title = title
        self.note = note
        self.timestamp = timestamp
    }
}
