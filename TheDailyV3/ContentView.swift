import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var columnVisibility: NavigationSplitViewVisibility = .all
    @State private var selectedReport: DailyReport?
    
    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            List {
                NavigationLink {
                    CalendarView(selectedReport: $selectedReport)
                        .navigationTitle("Calendar")
                } label: {
                    Label("Calendar", systemImage: "calendar")
                }
                
                NavigationLink {
                    if let selectedReport {
                        CounterListView(report: selectedReport)
                            .navigationTitle("Counters")
                    } else {
                        ContentUnavailableView(
                            "No Report Selected",
                            systemImage: "calendar.badge.exclamationmark",
                            description: Text("Please select a date from the calendar to manage its counters.")
                        )
                    }
                } label: {
                    Label("Counters", systemImage: "number")
                }
                
                NavigationLink {
                    if let selectedReport {
                        EventListView(report: selectedReport)
                            .navigationTitle("Events")
                    } else {
                        ContentUnavailableView(
                            "No Report Selected",
                            systemImage: "calendar.badge.exclamationmark",
                            description: Text("Please select a date from the calendar to manage its events.")
                        )
                    }
                } label: {
                    Label("Events", systemImage: "flag")
                }
            }
            .navigationTitle("The Daily")
        } content: {
            Text("Select a date from the calendar")
        } detail: {
            if let selectedReport {
                ReportFormView(report: selectedReport)
            } else {
                Text("Select a report")
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [DailyReport.self], inMemory: true)
}
