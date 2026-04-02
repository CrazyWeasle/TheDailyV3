import Foundation
import SwiftData

@Model
final class ReportCounter {
    var id: UUID = UUID()
    var name: String = ""
    
    @Relationship(deleteRule: .cascade, inverse: \CounterIncrement.counter)
    var history: [CounterIncrement]? = []
    
    var reports: [DailyReport]? = []
    
    init(name: String = "") {
        self.id = UUID()
        self.name = name
    }
    
    func count(for date: Date) -> Int {
        let calendar = Calendar.current
        let endOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: date) ?? date
        return history?.filter { $0.timestamp <= endOfDay }
            .reduce(0) { $0 + $1.value } ?? 0
    }
    
    /// Returns history grouped by day with cumulative totals for graphing
    func cumulativeHistory() -> [(date: Date, total: Int)] {
        guard let history = history, !history.isEmpty else { return [] }
        
        let calendar = Calendar.current
        let sortedHistory = history.sorted { $0.timestamp < $1.timestamp }
        
        var cumulativeTotal = 0
        var result: [(Date, Int)] = []
        
        // Group by day and calculate cumulative total at the end of each day
        let grouped = Dictionary(grouping: sortedHistory) { increment in
            calendar.startOfDay(for: increment.timestamp)
        }
        
        let sortedDates = grouped.keys.sorted()
        
        for date in sortedDates {
            let dayTotal = grouped[date]?.reduce(0) { $0 + $1.value } ?? 0
            cumulativeTotal += dayTotal
            result.append((date, cumulativeTotal))
        }
        
        return result
    }
    
    func reportLine(for date: Date) -> String {
        return "\(name): \(count(for: date))"
    }
}

@Model
final class CounterIncrement {
    var id: UUID = UUID()
    var value: Int = 0
    var timestamp: Date = Date()
    
    var counter: ReportCounter?
    
    init(value: Int, timestamp: Date = Date()) {
        self.id = UUID()
        self.value = value
        self.timestamp = timestamp
    }
}
