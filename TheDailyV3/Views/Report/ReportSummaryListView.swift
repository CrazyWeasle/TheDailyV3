import SwiftUI
import SwiftData

struct ReportSummaryListView: View {
    @Query(sort: \DailyReport.timestamp, order: .reverse) private var reports: [DailyReport]
    @Binding var selectedReport: DailyReport?

    var body: some View {
        if reports.isEmpty {
            ContentUnavailableView("No Reports", systemImage: "doc.text", description: Text("Select a date from the calendar to create a report."))
        } else {
            List(reports) { report in
                Button {
                    selectedReport = report
                } label: {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(report.timestamp, format: .dateTime.month().day().year())
                                .font(.headline)
                            Spacer()
                            Text(report.isSent ? "Sent" : "Draft")
                                .font(.caption)
                                .fontWeight(.bold)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(report.isSent ? Color.green.opacity(0.2) : Color.blue.opacity(0.2))
                                .foregroundColor(report.isSent ? .green : .blue)
                                .clipShape(Capsule())
                        }
                        
                        Text(firstLine(of: report.mealDescription))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                        
                        let totalItems = (report.events?.count ?? 0) + (report.counters?.count ?? 0)
                        Text("\(totalItems) Items (Events & Counters)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
                .buttonStyle(.plain)
            }
            .navigationTitle("All Reports")
        }
    }
    
    private func firstLine(of text: String) -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            return "No text"
        }
        return String(trimmed.split(whereSeparator: \.isNewline).first ?? "No text")
    }
}

#Preview {
    ReportSummaryListView(selectedReport: .constant(nil))
        .modelContainer(for: DailyReport.self, inMemory: true)
}
