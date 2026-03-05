import Foundation
import SwiftData

@Model
final class ReportCounter {
    var id: UUID = UUID()
    var name: String = ""
    
    @Relationship(deleteRule: .cascade, inverse: \CounterIncrement.counter)
    var history: [CounterIncrement]? = []
    
    init(name: String = "") {
        self.id = UUID()
        self.name = name
    }
    
    func count(for date: Date) -> Int {
        let calendar = Calendar.current
        return history?.filter { calendar.isDate($0.timestamp, inSameDayAs: date) }
            .reduce(0) { $0 + $1.value } ?? 0
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
