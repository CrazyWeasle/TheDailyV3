import SwiftUI
import Charts
import SwiftData

struct CounterDetailView: View {
    let counter: ReportCounter
    
    var historyData: [(date: Date, total: Int)] {
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
                        Text("Current Total: \(lastEntry.total)")
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
                                LineMark(
                                    x: .value("Date", entry.date),
                                    y: .value("Total", entry.total)
                                )
                                .interpolationMethod(.monotone)
                                .symbol(Circle().strokeBorder(lineWidth: 2))
                                
                                AreaMark(
                                    x: .value("Date", entry.date),
                                    y: .value("Total", entry.total)
                                )
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.blue.opacity(0.3), .clear],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                            }
                        }
                        .frame(height: 250)
                        .chartYAxis {
                            AxisMarks(position: .leading)
                        }
                        .chartXAxis {
                            AxisMarks(values: .stride(by: .day)) { value in
                                AxisGridLine()
                                AxisValueLabel(format: .dateTime.month(.abbreviated).day())
                            }
                        }
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
                            Text(entry.date, style: .date)
                                .font(.body)
                            Spacer()
                            Text("\(entry.total)")
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
