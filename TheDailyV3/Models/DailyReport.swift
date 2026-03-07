import Foundation
import SwiftData

@Model
final class DailyReport {
    var id: UUID = UUID()
    var timestamp: Date = Date()
    var reportTitle: String = ""
    var isSent: Bool = false
    
    var mealDescription: String = ""
    var dailyActivities: String = ""
    var eventSummaries: [String] = []
    var counterSummaries: [String] = []
    
    var mediaIdentifier: String?
    var mediaCaption: String?
    var mediaType: String?
    
    @Relationship var events: [ReportEvent]? = []
    @Relationship var counters: [ReportCounter]? = []
    
    init(timestamp: Date = Date()) {
        self.id = UUID()
        self.timestamp = Calendar.current.startOfDay(for: timestamp)
        self.isSent = false
        self.reportTitle = DailyReport.formatTitle(for: self.timestamp)
    }
    
    static func formatTitle(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return "Report for \(formatter.string(from: date))"
    }
}
