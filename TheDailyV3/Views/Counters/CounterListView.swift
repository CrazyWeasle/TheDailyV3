import SwiftUI
import SwiftData

struct CounterListView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ReportCounter.name) private var allCounters: [ReportCounter]
    
    @Bindable var report: DailyReport
    
    @State private var showingAddCounter = false
    @State private var newCounterName = ""
    @State private var startingValue: Int = 0
    
    var body: some View {
        List {
            if allCounters.isEmpty {
                ContentUnavailableView(
                    "No Counters",
                    systemImage: "plus.circle.fill",
                    description: Text("Tap + to add a new counter.")
                )
            } else {
                ForEach(allCounters) { counter in
                    HStack {
                        Button(action: { toggleActive(for: counter) }) {
                            Image(systemName: isCounterActive(counter) ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(isCounterActive(counter) ? .blue : .gray)
                                .font(.title2)
                        }
                        .buttonStyle(.plain)
                        .disabled(report.isSent)
                        
                        Text(counter.name)
                            .font(.headline)
                        
                        Spacer()
                        
                        HStack(spacing: 16) {
                            Button(action: { decrementCounter(counter) }) {
                                Image(systemName: "minus.circle")
                                    .font(.title3)
                            }
                            .buttonStyle(.plain)
                            .disabled(report.isSent)
                            
                            Text("\(counter.count(for: report.timestamp))")
                                .frame(minWidth: 30, alignment: .center)
                                .font(.body.monospacedDigit())
                            
                            Button(action: { incrementCounter(counter) }) {
                                Image(systemName: "plus.circle")
                                    .font(.title3)
                            }
                            .buttonStyle(.plain)
                            .disabled(report.isSent)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle("Counters")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { showingAddCounter = true }) {
                    Image(systemName: "plus")
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    dismiss()
                }
                .fontWeight(.bold)
            }
        }
        .alert("New Counter", isPresented: $showingAddCounter) {
            TextField("Counter Name", text: $newCounterName)
            TextField("Starting Value", value: $startingValue, format: .number)
                .keyboardType(.numberPad)
            
            Button("Cancel", role: .cancel) {
                resetNewCounter()
            }
            Button("Add") {
                addCounter()
            }
            .disabled(newCounterName.trimmingCharacters(in: .whitespaces).isEmpty)
        } message: {
            Text("Enter a name and an optional starting value.")
        }
        .onChange(of: report.counters) { _, _ in
            updateReportSummaries()
        }
        .onDisappear {
            updateReportSummaries()
        }
    }
    
    private func isCounterActive(_ counter: ReportCounter) -> Bool {
        return report.counters?.contains(where: { $0.id == counter.id }) ?? false
    }
    
    private func toggleActive(for counter: ReportCounter) {
        guard !report.isSent else { return }
        var currentCounters = report.counters ?? []
        if let index = currentCounters.firstIndex(where: { $0.id == counter.id }) {
            currentCounters.remove(at: index)
        } else {
            currentCounters.append(counter)
        }
        report.counters = currentCounters
        updateReportSummaries()
    }
    
    @MainActor
    private func incrementCounter(_ counter: ReportCounter) {
        recordIncrement(counter, value: 1)
    }
    
    @MainActor
    private func decrementCounter(_ counter: ReportCounter) {
        recordIncrement(counter, value: -1)
    }
    
    @MainActor
    private func recordIncrement(_ counter: ReportCounter, value: Int) {
        guard !report.isSent else { return }
        
        let increment = CounterIncrement(value: value, timestamp: report.timestamp)
        if counter.history == nil {
            counter.history = []
        }
        counter.history?.append(increment)
        modelContext.insert(increment)
        
        // Auto-activate the counter if modified for this report
        if !isCounterActive(counter) {
            toggleActive(for: counter)
        } else {
            updateReportSummaries()
        }
    }
    
    private func addCounter() {
        let newCounter = ReportCounter(name: newCounterName)
        modelContext.insert(newCounter)
        
        if startingValue != 0 {
            let increment = CounterIncrement(value: startingValue, timestamp: report.timestamp)
            newCounter.history = [increment]
            modelContext.insert(increment)
        }
        
        // Only auto-add to report if it's not sent
        if !report.isSent {
            var currentCounters = report.counters ?? []
            currentCounters.append(newCounter)
            report.counters = currentCounters
            updateReportSummaries()
        }
        
        resetNewCounter()
    }
    
    private func resetNewCounter() {
        newCounterName = ""
        startingValue = 0
    }
    
    private func updateReportSummaries() {
        guard let counters = report.counters else {
            report.counterSummaries = []
            return
        }
        report.counterSummaries = counters.map { $0.reportLine(for: report.timestamp) }
    }
}
