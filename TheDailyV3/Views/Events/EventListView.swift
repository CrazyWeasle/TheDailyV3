import SwiftUI
import SwiftData

struct EventListView: View {
    let report: DailyReport
    
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ReportEvent.title) private var allEvents: [ReportEvent]
    
    @State private var showingAddSheet = false
    
    var body: some View {
        List {
            if allEvents.isEmpty {
                ContentUnavailableView(
                    "No Events",
                    systemImage: "calendar.badge.plus",
                    description: Text("Add an event to track time since or until it occurs.")
                )
            } else {
                ForEach(allEvents) { event in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(event.title).font(.headline)
                            Text(event.targetDate, format: .dateTime.year().month().day())
                                .font(.caption)
                                .foregroundColor(.secondary)
                            if event.isAnniversary {
                                Text("Anniversary")
                                    .font(.caption2)
                                    .padding(.horizontal, 4)
                                    .padding(.vertical, 2)
                                    .background(Color.blue.opacity(0.2))
                                    .foregroundColor(.blue)
                                    .cornerRadius(4)
                            }
                        }
                        
                        Spacer()
                        
                        Toggle("", isOn: Binding(
                            get: { event.isActive },
                            set: { newValue in
                                event.isActive = newValue
                                updateReportSummaries()
                            }
                        ))
                        .labelsHidden()
                    }
                }
                .onDelete(perform: deleteEvents)
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingAddSheet = true }) {
                    Label("Add Event", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            AddEventSheet {
                updateReportSummaries()
            }
        }
        .onAppear {
            updateReportSummaries()
        }
        .onChange(of: allEvents) { _, _ in
            updateReportSummaries()
        }
    }
    
    private func deleteEvents(offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(allEvents[index])
        }
        try? modelContext.save()
        updateReportSummaries()
    }
    
    private func updateReportSummaries() {
        let calendar = Calendar.current
        let reportDate = report.timestamp
        let reportMonth = calendar.component(.month, from: reportDate)
        let reportDay = calendar.component(.day, from: reportDate)
        
        var newSummaries: [String] = []
        var activeEvents: [ReportEvent] = []
        
        for event in allEvents {
            var shouldInclude = event.isActive
            
            if !shouldInclude && event.isAnniversary {
                let eventMonth = calendar.component(.month, from: event.targetDate)
                let eventDay = calendar.component(.day, from: event.targetDate)
                if eventMonth == reportMonth && eventDay == reportDay {
                    shouldInclude = true
                }
            }
            
            if shouldInclude {
                newSummaries.append(event.reportLine(for: reportDate))
                activeEvents.append(event)
            }
        }
        
        report.eventSummaries = newSummaries
        report.events = activeEvents
        try? modelContext.save()
    }
}

struct AddEventSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var title: String = ""
    @State private var targetDate: Date = Date()
    @State private var isAnniversary: Bool = false
    @State private var isActive: Bool = true
    
    var onSave: () -> Void
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Event Title", text: $title)
                DatePicker("Target Date", selection: $targetDate, displayedComponents: .date)
                Toggle("Track as Anniversary", isOn: $isAnniversary)
                Toggle("Active in Reports", isOn: $isActive)
            }
            .navigationTitle("New Event")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let newEvent = ReportEvent(
                            title: title,
                            targetDate: targetDate,
                            isAnniversary: isAnniversary,
                            isActive: isActive
                        )
                        modelContext.insert(newEvent)
                        try? modelContext.save()
                        onSave()
                        dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}
