import SwiftUI
import SwiftData

struct ReportFormView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var report: DailyReport
    @Query private var allEvents: [ReportEvent]
    @State private var showingMessageSheet = false
    @State private var showingPreviewSheet = false

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
        }
        .navigationTitle("Report Form")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if !report.isSent {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        Button {
                            showingPreviewSheet = true
                        } label: {
                            Label("Preview", systemImage: "eye")
                        }
                        
                        Button("Send Report") {
                            presentMessageSheet()
                        }
                        .disabled(!isSendable)
                    }
                }
            }
        }
        .sheet(isPresented: $showingMessageSheet) {
            ReportMessageComposeView(reportDate: report.timestamp) { result in
                showingMessageSheet = false
            }
        }
        .sheet(isPresented: $showingPreviewSheet) {
            ReportPreviewSheet(report: report)
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

struct ReportPreviewSheet: View {
    @Environment(\.dismiss) var dismiss
    let report: DailyReport
    
    var previewText: String {
        var components: [String] = []
        
        if let caption = report.mediaCaption {
            components.append(caption)
            components.append("")
        }
        
        if !report.mealDescription.isEmpty {
            components.append(report.mealDescription)
            components.append("")
        }
        
        if !report.counterSummaries.isEmpty {
            components.append(contentsOf: report.counterSummaries)
        }
        
        if !report.eventSummaries.isEmpty {
            components.append(contentsOf: report.eventSummaries)
        }
        
        if !report.counterSummaries.isEmpty || !report.eventSummaries.isEmpty {
            components.append("")
        }
        
        if !report.dailyActivities.isEmpty {
            components.append(report.dailyActivities)
        }
        
        return components.joined(separator: "\n")
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("This is how your report will appear in Messages:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(previewText)
                        .font(.system(.body, design: .monospaced))
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(12)
                }
                .padding()
            }
            .navigationTitle("Report Preview")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

