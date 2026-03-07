import Foundation
import SwiftData

@Model
final class ReportEvent {
    var id: UUID = UUID()
    var title: String = ""
    var targetDate: Date = Date()
    var isAnniversary: Bool = false
    var isActive: Bool = false
    
    init(title: String = "", targetDate: Date = Date(), isAnniversary: Bool = false, isActive: Bool = true) {
        self.id = UUID()
        self.title = title
        self.targetDate = Calendar.current.startOfDay(for: targetDate)
        self.isAnniversary = isAnniversary
        self.isActive = isActive
    }
    
    func reportLine(for reportDate: Date) -> String {
        let calendar = Calendar.current
        let startOfReport = calendar.startOfDay(for: reportDate)
        let startOfTarget = calendar.startOfDay(for: targetDate)
        
        let isFuture = startOfTarget > startOfReport
        let start = min(startOfTarget, startOfReport)
        let end = max(startOfTarget, startOfReport)
        
        let components = calendar.dateComponents([.year, .month, .day], from: start, to: end)
        
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.year, .month, .day]
        formatter.zeroFormattingBehavior = .dropAll
        formatter.unitsStyle = .full
        
        var intervalString = formatter.string(from: components) ?? ""
        if intervalString.isEmpty {
            intervalString = "0 days"
        }
        
        let direction = isFuture ? "until" : "since"
        return "\(intervalString) \(direction) \(title)"
    }
}
