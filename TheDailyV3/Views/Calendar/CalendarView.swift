import SwiftUI
import SwiftData

struct CalendarView: View {
    @Environment(\.modelContext) private var modelContext
    
    @Binding var selectedReport: DailyReport?
    
    @State private var selectedMonth: Date = Date()
    @State private var selectedDate: Date? = nil
    @State private var datesInMonth: [Date] = []
    
    private let calendar = Calendar.current
    private let daysOfWeek = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    
    var body: some View {
        VStack {
            // Month Header
            HStack {
                Button(action: { changeMonth(by: -1) }) {
                    Image(systemName: "chevron.left")
                }
                
                Spacer()
                
                Text(selectedMonth, format: .dateTime.month(.wide).year())
                    .font(.headline)
                
                Spacer()
                
                Button(action: { changeMonth(by: 1) }) {
                    Image(systemName: "chevron.right")
                }
            }
            .padding()
            
            // Days of week header
            HStack {
                ForEach(daysOfWeek, id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                }
            }
            
            // Calendar Grid
            CalendarGridView(
                datesInMonth: datesInMonth,
                selectedMonth: selectedMonth,
                selectedDate: selectedDate,
                onSelect: { date, report in
                    selectedDate = date
                    handleDateSelection(date, existingReport: report)
                }
            )
            
            Spacer()
        }
        .task(id: selectedMonth) {
            await generateDatesInMonth()
        }
    }
    
    private func changeMonth(by value: Int) {
        if let newMonth = calendar.date(byAdding: .month, value: value, to: selectedMonth) {
            selectedMonth = newMonth
        }
    }
    
    private func generateDatesInMonth() async {
        let currentMonth = selectedMonth
        let currentCalendar = calendar
        
        // Perform date calculations off the Main Actor
        let dates = await Task.detached(priority: .userInitiated) { () -> [Date] in
            var dates: [Date] = []
            
            guard let monthInterval = currentCalendar.dateInterval(of: .month, for: currentMonth) else {
                return []
            }
            
            let firstDayOfMonth = monthInterval.start
            
            // Padding for the beginning of the month
            let firstWeekday = currentCalendar.component(.weekday, from: firstDayOfMonth)
            let paddingDays = firstWeekday - 1
            
            if let startOfGrid = currentCalendar.date(byAdding: .day, value: -paddingDays, to: firstDayOfMonth) {
                var currentDate = startOfGrid
                // Show 6 weeks (42 days) to keep grid consistent
                for _ in 0..<42 {
                    dates.append(currentDate)
                    if let nextDate = currentCalendar.date(byAdding: .day, value: 1, to: currentDate) {
                        currentDate = nextDate
                    }
                }
            }
            
            return dates
        }.value
        
        await MainActor.run {
            self.datesInMonth = dates
        }
    }
    
    private func handleDateSelection(_ date: Date, existingReport: DailyReport?) {
        if let existingReport {
            selectedReport = existingReport
        } else {
            let newReport = DailyReport(timestamp: date)
            modelContext.insert(newReport)
            selectedReport = newReport
        }
    }
}

#Preview {
    CalendarView(selectedReport: .constant(nil))
        .modelContainer(for: DailyReport.self, inMemory: true)
}
