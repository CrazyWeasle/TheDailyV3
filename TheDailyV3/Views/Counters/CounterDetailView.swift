import SwiftUI
import Charts
import SwiftData

struct CounterDetailView: View {
    let counter: ReportCounter
    
    var historyData: [(date: Date, dailyIncrement: Int, cumulativeTotal: Int)] {
        counter.cumulativeHistory()
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Summary Header
                VStack(alignment: .leading, spacing: 8) {
                    Text(counter.name)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    if let lastEntry = historyData.last {
                        Text("Current Total: \(lastEntry.cumulativeTotal)")
                            .font(.title2)
                            .foregroundColor(.secondary)
                    } else {
                        Text("No history recorded yet.")
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal)
                
                // Chart Section
                if !historyData.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Progress Over Time")
                            .font(.headline)
                        
                        Chart {
                            ForEach(historyData, id: \.date) { entry in
                                // Daily Increment (Bar - Left Axis)
                                BarMark(
                                    x: .value("Date", entry.date),
                                    y: .value("Daily Change", entry.dailyIncrement)
                                )
                                .foregroundStyle(Color.blue.opacity(0.4))
                                
                                // Cumulative Total (Line - Right Axis)
                                LineMark(
                                    x: .value("Date", entry.date),
                                    y: .value("Total", entry.cumulativeTotal)
                                )
                                .foregroundStyle(Color.orange)
                                .interpolationMethod(.monotone)
                                .symbol(Circle().strokeBorder(lineWidth: 2))
                            }
                        }
                        .frame(height: 300)
                        .chartYAxis {
                            // Left Axis for Bar Chart
                            AxisMarks(position: .leading) { _ in
                                AxisGridLine()
                                AxisValueLabel()
                                    .foregroundStyle(.blue)
                            }
                            // Right Axis for Line Chart
                            AxisMarks(position: .trailing) { _ in
                                AxisValueLabel()
                                    .foregroundStyle(.orange)
                            }
                        }
                        .chartXAxis {
                            AxisMarks(values: .stride(by: .day)) { value in
                                AxisGridLine()
                                AxisValueLabel(format: .dateTime.month(.abbreviated).day())
                            }
                        }
                        
                        // Legend
                        HStack(spacing: 20) {
                            HStack(spacing: 4) {
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(Color.blue.opacity(0.4))
                                    .frame(width: 12, height: 12)
                                Text("Daily Change")
                                    .font(.caption)
                            }
                            HStack(spacing: 4) {
                                Circle()
                                    .stroke(Color.orange, lineWidth: 2)
                                    .frame(width: 10, height: 10)
                                Text("Cumulative Total")
                                    .font(.caption)
                            }
                        }
                        .padding(.top, 4)
                    }
                    .padding()
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(12)
                    .padding(.horizontal)
                } else {
                    ContentUnavailableView(
                        "No Data",
                        systemImage: "chart.line.uptrend.xyaxis",
                        description: Text("History will appear here once increments are recorded.")
                    )
                }
                
                // Detailed History List
                VStack(alignment: .leading, spacing: 12) {
                    Text("Daily History")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ForEach(historyData.reversed(), id: \.date) { entry in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(entry.date, style: .date)
                                    .font(.body)
                                Text("Change: \(entry.dailyIncrement > 0 ? "+" : "")\(entry.dailyIncrement)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Text("\(entry.cumulativeTotal)")
                                .font(.body.monospacedDigit())
                                .fontWeight(.semibold)
                        }
                        .padding(.horizontal)
                        Divider()
                            .padding(.horizontal)
                    }
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("Counter Detail")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: ReportCounter.self, CounterIncrement.self, configurations: config)
    
    let counter = ReportCounter(name: "Sample Counter")
    container.mainContext.insert(counter)
    
    // Add some sample data
    let calendar = Calendar.current
    let day1 = calendar.date(byAdding: .day, value: -2, to: Date())!
    let day2 = calendar.date(byAdding: .day, value: -1, to: Date())!
    let day3 = Date()
    
    counter.history?.append(CounterIncrement(value: 5, timestamp: day1))
    counter.history?.append(CounterIncrement(value: 3, timestamp: day2))
    counter.history?.append(CounterIncrement(value: -2, timestamp: day3))
    
    return NavigationStack {
        CounterDetailView(counter: counter)
    }
    .modelContainer(container)
}
