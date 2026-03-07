import SwiftUI
import SwiftData

enum SidebarItem: Hashable {
    case calendar
    case counters
    case events
    case gallery
    case settings
}

struct ContentView: View {
    @State private var columnVisibility: NavigationSplitViewVisibility = .all
    @State private var selectedSidebarItem: SidebarItem? = .calendar
    @State private var selectedReport: DailyReport?
    
    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            List(selection: $selectedSidebarItem) {
                NavigationLink(value: SidebarItem.calendar) {
                    Label("Calendar", systemImage: "calendar")
                }
                
                NavigationLink(value: SidebarItem.counters) {
                    Label("Counters", systemImage: "number")
                }
                
                NavigationLink(value: SidebarItem.events) {
                    Label("Events", systemImage: "flag")
                }
                
                NavigationLink(value: SidebarItem.gallery) {
                    Label("Gallery", systemImage: "photo.on.rectangle")
                }
                
                NavigationLink(value: SidebarItem.settings) {
                    Label("Settings", systemImage: "gear")
                }
            }
            .navigationTitle("The Daily")
        } content: {
            switch selectedSidebarItem {
            case .calendar, .none:
                CalendarView(selectedReport: $selectedReport)
                    .navigationTitle("Calendar")
            case .counters:
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
            case .events:
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
            case .gallery:
                Text("Image Gallery placeholder")
                    .navigationTitle("Gallery")
            case .settings:
                SettingsView()
            }
        } detail: {
            if let selectedReport {
                ReportFormView(report: selectedReport)
            } else {
                ReportSummaryListView(selectedReport: $selectedReport)
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [DailyReport.self], inMemory: true)
}
