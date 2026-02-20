import SwiftUI
import SwiftData

struct HistoryStatsView: View {
    @Query(sort: \PanicEntry.timestamp, order: .reverse) private var entries: [PanicEntry]
    @Query(sort: \DailyCheckIn.date, order: .reverse) private var checkIns: [DailyCheckIn]
    
    private var weekEntries: [PanicEntry] {
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return entries.filter { $0.timestamp >= weekAgo }
    }
    
    private var monthEntries: [PanicEntry] {
        let monthAgo = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
        return entries.filter { $0.timestamp >= monthAgo }
    }
    
    private var daysSinceLastAttack: Int? {
        guard let last = entries.first else { return nil }
        return Calendar.current.dateComponents([.day], from: last.timestamp, to: Date()).day
    }
    
    private var avgIntensity: Double {
        guard !entries.isEmpty else { return 0 }
        return Double(entries.reduce(0) { $0 + $1.intensity }) / Double(entries.count)
    }
    
    private var avgDuration: Double {
        guard !entries.isEmpty else { return 0 }
        return Double(entries.reduce(0) { $0 + $1.durationMinutes }) / Double(entries.count)
    }
    
    private var topTriggers: [(String, Int)] {
        var counts: [String: Int] = [:]
        for entry in entries {
            for tag in entry.triggerTags {
                counts[tag, default: 0] += 1
            }
        }
        return counts.sorted { $0.value > $1.value }.prefix(3).map { ($0.key, $0.value) }
    }
    
    private var techniqueBreakdown: [(String, Int)] {
        var counts: [String: Int] = [:]
        for entry in entries {
            for tech in entry.techniquesUsed {
                counts[tech, default: 0] += 1
            }
        }
        return counts.sorted { $0.value > $1.value }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if let days = daysSinceLastAttack {
                    StatCard(
                        title: "Days Since Last Attack",
                        value: "\(days)",
                        icon: "calendar.badge.checkmark",
                        color: AppColors.deepTeal
                    )
                }
                
                HStack(spacing: 12) {
                    StatCard(title: "This Week", value: "\(weekEntries.count)", icon: "chart.bar", color: AppColors.deepTeal)
                    StatCard(title: "This Month", value: "\(monthEntries.count)", icon: "chart.bar", color: AppColors.deepTeal)
                    StatCard(title: "All Time", value: "\(entries.count)", icon: "chart.bar", color: AppColors.deepTeal)
                }
                
                HStack(spacing: 12) {
                    StatCard(title: "Avg Intensity", value: String(format: "%.1f", avgIntensity), icon: "flame", color: .orange)
                    StatCard(title: "Avg Duration", value: String(format: "%.0f min", avgDuration), icon: "clock", color: .blue)
                }
                
                if !topTriggers.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Top Triggers")
                            .font(.headline)
                        ForEach(topTriggers, id: \.0) { trigger, count in
                            HStack {
                                Text(trigger)
                                Spacer()
                                Text("\(count)")
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(color: .black.opacity(0.05), radius: 4)
                }
                
                if !techniqueBreakdown.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Most Effective Techniques")
                            .font(.headline)
                        ForEach(techniqueBreakdown, id: \.0) { tech, count in
                            HStack {
                                Text(tech)
                                Spacer()
                                let pct = entries.isEmpty ? 0 : Int(Double(count) / Double(entries.count) * 100)
                                Text("\(pct)%")
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(color: .black.opacity(0.05), radius: 4)
                }
                
                // Anxiety trend from check-ins
                if !checkIns.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Anxiety Trend")
                            .font(.headline)
                        
                        let recent = Array(checkIns.prefix(14).reversed())
                        HStack(alignment: .bottom, spacing: 4) {
                            ForEach(Array(recent.enumerated()), id: \.offset) { _, checkIn in
                                VStack {
                                    Rectangle()
                                        .fill(barColor(checkIn.anxietyLevel))
                                        .frame(width: 16, height: CGFloat(checkIn.anxietyLevel) * 12)
                                }
                            }
                        }
                        .frame(height: 70)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(color: .black.opacity(0.05), radius: 4)
                }
                
                // Weekly bar chart
                if !entries.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Last 7 Days")
                            .font(.headline)
                        
                        HStack(alignment: .bottom, spacing: 8) {
                            ForEach(0..<7, id: \.self) { daysAgo in
                                let day = Calendar.current.date(byAdding: .day, value: -6 + daysAgo, to: Date())!
                                let startOfDay = Calendar.current.startOfDay(for: day)
                                let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
                                let count = entries.filter { $0.timestamp >= startOfDay && $0.timestamp < endOfDay }.count
                                
                                VStack {
                                    Text("\(count)")
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                    Rectangle()
                                        .fill(AppColors.deepTeal)
                                        .frame(width: 24, height: max(4, CGFloat(count) * 20))
                                    Text(dayLabel(daysAgo - 6))
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .frame(height: 80)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(color: .black.opacity(0.05), radius: 4)
                }
            }
            .padding()
        }
    }
    
    private func barColor(_ level: Int) -> Color {
        switch level {
        case 1: return .green
        case 2: return .green.opacity(0.7)
        case 3: return .yellow
        case 4: return .orange
        default: return .red
        }
    }
    
    private func dayLabel(_ offset: Int) -> String {
        let date = Calendar.current.date(byAdding: .day, value: offset, to: Date())!
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
            Text(value)
                .font(.title2.weight(.bold))
                .foregroundStyle(color)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 4)
    }
}
