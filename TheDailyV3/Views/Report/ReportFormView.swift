import SwiftUI
import SwiftData

struct ReportFormView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var report: DailyReport
    @Query private var allEvents: [ReportEvent]
    @State private var showingMessageSheet = false

    var isSendable: Bool {
        !report.mealDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        Form {
            Section {
                // Media Section
                VStack(alignment: .leading, spacing: 12) {
                    if let mediaIdentifier = report.mediaIdentifier {
                        // Visual container for media
                        Rectangle()
                            .fill(Color.secondary.opacity(0.2))
                            .frame(height: 200)
                            .overlay(
                                Text("Media ID: \(mediaIdentifier)")
                                    .foregroundColor(.secondary)
                            )
                            .cornerRadius(8)
                    } else {
                        Rectangle()
                            .fill(Color.secondary.opacity(0.1))
                            .frame(height: 200)
                            .overlay(
                                Text("No Image")
                                    .foregroundColor(.secondary)
                            )
                            .cornerRadius(8)
                    }
                    
                    if !report.isSent {
                        Button("Simulate Picking Photo") {
                            simulatePickingPhoto()
                        }
                        .padding(.vertical, 4)
                    }

                    TextField("Add a caption...", text: Binding(
                        get: { report.mediaCaption ?? "" },
                        set: { report.mediaCaption = $0.isEmpty ? nil : $0 }
                    ))
                    .disabled(report.isSent)
                }
            } header: {
                HStack {
                    Text(report.reportTitle)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Spacer()
                    if report.isSent {
                        Text("Sent")
                            .font(.caption)
                            .fontWeight(.bold)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.green.opacity(0.2))
                            .foregroundColor(.green)
                            .clipShape(Capsule())
                    }
                }
            }

            Section("Meal (Required)") {
                ZStack(alignment: .topLeading) {
                    TextEditor(text: $report.mealDescription)
                        .frame(minHeight: 100)
                    
                    if report.mealDescription.isEmpty {
                        Text("Please enter meal information...")
                            .foregroundColor(Color.gray.opacity(0.6))
                            .padding(.top, 8)
                            .padding(.leading, 5)
                            .allowsHitTesting(false)
                    }
                }
                .disabled(report.isSent)
            }

            if !report.counterSummaries.isEmpty || !report.isSent {
                Section("Counters") {
                    if !report.isSent {
                        NavigationLink {
                            CounterListView(report: report)
                        } label: {
                            Label("Edit Counters", systemImage: "number.circle")
                        }
                    }
                    
                    ForEach(report.counterSummaries, id: \.self) { summary in
                        Text(summary)
                    }
                }
            }

            Section("Activities") {
                ZStack(alignment: .topLeading) {
                    TextEditor(text: $report.dailyActivities)
                        .frame(minHeight: 100)
                    
                    if report.dailyActivities.isEmpty {
                        Text("Describe your activities...")
                            .foregroundColor(Color.gray.opacity(0.6))
                            .padding(.top, 8)
                            .padding(.leading, 5)
                            .allowsHitTesting(false)
                    }
                }
                .disabled(report.isSent)
            }

            if !report.eventSummaries.isEmpty || !report.isSent {
                Section("Events") {
                    if !report.isSent {
                        NavigationLink {
                            EventListView(report: report)
                        } label: {
                            Label("Edit Events", systemImage: "flag.circle")
                        }
                    }
                    
                    ForEach(report.eventSummaries, id: \.self) { summary in
                        Text(summary)
                    }
                }
            }
        }
        .navigationTitle("Report Form")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if !report.isSent {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Send Report") {
                        presentMessageSheet()
                    }
                    .disabled(!isSendable)
                }
            }
        }
        .sheet(isPresented: $showingMessageSheet) {
            MessageComposeSheet(isSent: $report.isSent)
        }
        .onDisappear {
            saveChanges()
        }
        .onAppear {
            updateEventSummaries()
        }
    }
    
    private func updateEventSummaries() {
        if report.isSent { return }
        
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
        
        if report.eventSummaries != newSummaries {
            report.eventSummaries = newSummaries
            report.events = activeEvents
            try? modelContext.save()
        }
    }
    
    @MainActor
    private func presentMessageSheet() {
        showingMessageSheet = true
    }
    
    private func saveChanges() {
        try? modelContext.save()
    }
    
    private func simulatePickingPhoto() {
        let newAssetID = UUID().uuidString
        report.mediaIdentifier = newAssetID
        
        // Find or create CustomImageMetadata to increment usage count
        let descriptor = FetchDescriptor<CustomImageMetadata>(predicate: #Predicate { $0.assetID == newAssetID })
        if let existingMetadata = try? modelContext.fetch(descriptor).first {
            existingMetadata.usageCount += 1
            existingMetadata.lastUsed = Date()
        } else {
            let newMetadata = CustomImageMetadata(assetID: newAssetID, source: "CustomStore")
            modelContext.insert(newMetadata)
        }
    }
}

struct MessageComposeSheet: View {
    @Environment(\.dismiss) var dismiss
    @Binding var isSent: Bool
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Simulating Message Compose Sheet")
                    .font(.headline)
                
                Button("Simulate Send Success") {
                    completeMessageSend()
                }
                .buttonStyle(.borderedProminent)
                
                Button("Cancel") {
                    dismiss()
                }
            }
            .navigationTitle("New Message")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    @MainActor
    private func completeMessageSend() {
        isSent = true
        dismiss()
    }
}
