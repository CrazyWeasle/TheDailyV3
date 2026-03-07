import SwiftUI
import MessageUI
import SwiftData
import UniformTypeIdentifiers

struct ReportMessageComposeView: UIViewControllerRepresentable {
    @Environment(\.modelContext) private var modelContext
    let reportDate: Date
    let onComplete: (MessageComposeResult) -> Void
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> MFMessageComposeViewController {
        let controller = MFMessageComposeViewController()
        controller.messageComposeDelegate = context.coordinator
        
        configureMessage(controller)
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: MFMessageComposeViewController, context: Context) {}
    
    private func configureMessage(_ controller: MFMessageComposeViewController) {
        // Fetch Default Contact
        let contactDescriptor = FetchDescriptor<Contact>(
            predicate: #Predicate<Contact> { contact in
                contact.isDefault == true
            }
        )
        if let defaultContact = try? modelContext.fetch(contactDescriptor).first {
            controller.recipients = [defaultContact.phoneNumber]
        }
        
        // 1. Fetch the report
        let startOfDay = Calendar.current.startOfDay(for: reportDate)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let descriptor = FetchDescriptor<DailyReport>(
            predicate: #Predicate<DailyReport> { report in
                report.timestamp >= startOfDay && report.timestamp < endOfDay
            }
        )
        
        guard let report = try? modelContext.fetch(descriptor).first else {
            print("No report found for date: \(reportDate)")
            return
        }
        
        // 2. Compose the body (Strict Ordering per GEMINI.md)
        var bodyComponents: [String] = []
        
        if let caption = report.mediaCaption {
            bodyComponents.append(caption)
            bodyComponents.append("") // Empty line after caption
        }
        
        if !report.mealDescription.isEmpty {
            bodyComponents.append(report.mealDescription)
            bodyComponents.append("") // Empty line after meals
        }
        
        if !report.counterSummaries.isEmpty {
            bodyComponents.append(report.counterSummaries.joined(separator: "\n"))
        }
        
        if !report.eventSummaries.isEmpty {
            bodyComponents.append(report.eventSummaries.joined(separator: "\n"))
        }
        
        if !report.counterSummaries.isEmpty || !report.eventSummaries.isEmpty {
            bodyComponents.append("") // Empty line after data sections
        }
        
        if !report.dailyActivities.isEmpty {
            bodyComponents.append(report.dailyActivities)
        }
        
        controller.body = bodyComponents.joined(separator: "\n")
        
        // 3. Media Attachment Logic (Actual Binary)
        if let mediaIdentifier = report.mediaIdentifier {
            let fileManager = FileManager.default
            let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
            let customStoreURL = documentsURL.appendingPathComponent("CustomStore")
            let fileURL = customStoreURL.appendingPathComponent(mediaIdentifier)
            
            if let fileData = try? Data(contentsOf: fileURL) {
                let utType: UTType = (report.mediaType == "video") ? .movie : .image
                let extensionStr = (report.mediaType == "video") ? "mov" : "jpg"
                controller.addAttachmentData(fileData, typeIdentifier: utType.identifier, filename: "\(mediaIdentifier).\(extensionStr)")
            } else {
                print("Warning: Media file missing for identifier: \(mediaIdentifier)")
            }
        }
    }
    
    class Coordinator: NSObject, MFMessageComposeViewControllerDelegate {
        var parent: ReportMessageComposeView
        
        init(_ parent: ReportMessageComposeView) {
            self.parent = parent
        }
        
        func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
            controller.dismiss(animated: true) { [weak self] in
                guard let self = self else { return }
                if result == .sent {
                    self.updateReportStatus()
                }
                self.parent.onComplete(result)
            }
        }
        
        @MainActor
        private func updateReportStatus() {
            let startOfDay = Calendar.current.startOfDay(for: parent.reportDate)
            let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
            
            let descriptor = FetchDescriptor<DailyReport>(
                predicate: #Predicate<DailyReport> { report in
                    report.timestamp >= startOfDay && report.timestamp < endOfDay
                }
            )
            
            if let report = try? parent.modelContext.fetch(descriptor).first {
                report.isSent = true
                try? parent.modelContext.save()
            }
        }
    }
}
