import SwiftUI
import SwiftData

struct CalendarGridView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var reports: [DailyReport]
    
    let datesInMonth: [Date]
    let selectedMonth: Date
    @Binding var selectedDate: Date?
    @Binding var selectedReport: DailyReport?
    
    private let calendar = Calendar.current
    
    init(datesInMonth: [Date], selectedMonth: Date, selectedDate: Binding<Date?>, selectedReport: Binding<DailyReport?>) {
        self.datesInMonth = datesInMonth
        self.selectedMonth = selectedMonth
        self._selectedDate = selectedDate
        self._selectedReport = selectedReport
        
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
                let isFuture = calendar.startOfDay(for: date) > calendar.startOfDay(for: Date())
                
                NavigationLink {
                    ReportDestinationView(date: date, selectedReport: $selectedReport)
                        .onAppear {
                            selectedDate = date
                        }
                } label: {
                    DateCell(
                        date: date,
                        status: status,
                        isSelected: calendar.isDate(date, inSameDayAs: selectedDate ?? Date.distantPast),
                        isCurrentMonth: calendar.isDate(date, equalTo: selectedMonth, toGranularity: .month),
                        isFuture: isFuture
                    )
                }
                .buttonStyle(.plain)
                .disabled(isFuture)
            }
        }
    }
}

struct ReportDestinationView: View {
    let date: Date
    @Binding var selectedReport: DailyReport?
    
    @Environment(\.modelContext) private var modelContext
    @Query private var reports: [DailyReport]
    
    init(date: Date, selectedReport: Binding<DailyReport?>) {
        self.date = date
        self._selectedReport = selectedReport
        
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: date)
        let end = calendar.date(byAdding: .day, value: 1, to: start)!
        
        _reports = Query(filter: #Predicate<DailyReport> {
            $0.timestamp >= start && $0.timestamp < end
        })
    }
    
    var body: some View {
        Group {
            if let report = reports.first {
                ReportFormView(report: report)
                    .onAppear {
                        // Only update if it's different to avoid redundant state updates
                        if selectedReport?.id != report.id {
                            selectedReport = report
                        }
                    }
            } else {
                ProgressView()
                    .onAppear {
                        let newReport = DailyReport(timestamp: date)
                        modelContext.insert(newReport)
                        // SwiftData will save, @Query will refresh, and the UI will navigate to the report
                    }
            }
        }
    }
}
