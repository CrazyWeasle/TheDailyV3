import SwiftUI
import SwiftData

struct CalendarGridView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var reports: [DailyReport]
    
    let datesInMonth: [Date]
    let selectedMonth: Date
    let selectedDate: Date?
    let onSelect: (Date, DailyReport?) -> Void
    
    private let calendar = Calendar.current
    
    init(datesInMonth: [Date], selectedMonth: Date, selectedDate: Date?, onSelect: @escaping (Date, DailyReport?) -> Void) {
        self.datesInMonth = datesInMonth
        self.selectedMonth = selectedMonth
        self.selectedDate = selectedDate
        self.onSelect = onSelect
        
        // Predicate for the month
        guard let monthInterval = calendar.dateInterval(of: .month, for: selectedMonth) else {
            _reports = Query()
            return
        }
        
        let start = monthInterval.start
        let end = monthInterval.end
        
        _reports = Query(filter: #Predicate<DailyReport> {
            $0.timestamp >= start && $0.timestamp < end
        })
    }
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 0) {
            ForEach(datesInMonth, id: \.self) { date in
                let report = reports.first { calendar.isDate($0.timestamp, inSameDayAs: date) }
                let status: ReportStatus = {
                    guard let report = report else { return .none }
                    return report.isSent ? .sent : .draft
                }()
                
                DateCell(
                    date: date,
                    status: status,
                    isSelected: calendar.isDate(date, inSameDayAs: selectedDate ?? Date.distantPast),
                    isCurrentMonth: calendar.isDate(date, equalTo: selectedMonth, toGranularity: .month)
                )
                .onTapGesture {
                    onSelect(date, report)
                }
            }
        }
    }
}
