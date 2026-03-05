import SwiftUI

enum ReportStatus {
    case none
    case draft
    case sent
    
    var backgroundColor: Color {
        switch self {
        case .none:
            return .clear
        case .draft:
            return .blue.opacity(0.2)
        case .sent:
            return .green.opacity(0.2)
        }
    }
}

struct DateCell: View {
    let date: Date
    let status: ReportStatus
    let isSelected: Bool
    let isCurrentMonth: Bool
    
    var body: some View {
        VStack {
            Text("\(Calendar.current.component(.day, from: date))")
                .font(.body)
                .foregroundStyle(foregroundForStatus)
                .frame(width: 32, height: 32)
                .background(
                    Circle()
                        .fill(backgroundForStatus)
                )
                .overlay(
                    Circle()
                        .stroke(Color.black, lineWidth: isSelected ? 2 : 0)
                )
        }
        .frame(maxWidth: .infinity, minHeight: 60)
        .contentShape(Rectangle())
    }
    
    private var backgroundForStatus: Color {
        switch status {
        case .none:
            return .clear
        case .draft:
            return .blue.opacity(0.3)
        case .sent:
            return .green.opacity(0.3)
        }
    }
    
    private var foregroundForStatus: Color {
        if !isCurrentMonth {
            return .secondary
        }
        return .primary
    }
}
