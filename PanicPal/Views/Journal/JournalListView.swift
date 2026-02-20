import SwiftUI
import SwiftData

struct JournalListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \PanicEntry.timestamp, order: .reverse) private var entries: [PanicEntry]
    @Query(sort: \DailyCheckIn.date, order: .reverse) private var checkIns: [DailyCheckIn]
    @State private var selectedTab = 0
    @State private var showNewEntry = false
    @State private var showCheckIn = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("View", selection: $selectedTab) {
                    Text("Journal").tag(0)
                    Text("Stats").tag(1)
                    Text("Check-Ins").tag(2)
                }
                .pickerStyle(.segmented)
                .padding()
                
                switch selectedTab {
                case 0: journalList
                case 1: HistoryStatsView()
                case 2: checkInList
                default: EmptyView()
                }
            }
            .navigationTitle("Journal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button { showNewEntry = true } label: {
                            Label("Log Panic Entry", systemImage: "plus")
                        }
                        Button { showCheckIn = true } label: {
                            Label("Daily Check-In", systemImage: "face.smiling")
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(AppColors.deepTeal)
                    }
                }
            }
            .sheet(isPresented: $showNewEntry) {
                JournalEntryView()
            }
            .sheet(isPresented: $showCheckIn) {
                DailyCheckInView()
            }
        }
    }
    
    private var journalList: some View {
        Group {
            if entries.isEmpty {
                ContentUnavailableView("No Entries Yet", systemImage: "book.closed", description: Text("Your panic journal entries will appear here."))
            } else {
                List {
                    ForEach(entries) { entry in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(intensityEmoji(entry.intensity))
                                    .font(.title2)
                                VStack(alignment: .leading) {
                                    Text("Intensity: \(entry.intensity)/10")
                                        .font(.headline)
                                    Text(entry.timestamp, style: .date)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Text("\(entry.durationMinutes) min")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            
                            if !entry.triggerTags.isEmpty {
                                HStack {
                                    ForEach(entry.triggerTags, id: \.self) { tag in
                                        Text(tag)
                                            .font(.caption)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 2)
                                            .background(AppColors.deepTeal.opacity(0.1))
                                            .clipShape(Capsule())
                                    }
                                }
                            }
                            
                            if let notes = entry.notes, !notes.isEmpty {
                                Text(notes)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(2)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            modelContext.delete(entries[index])
                        }
                        try? modelContext.save()
                    }
                }
            }
        }
    }
    
    private var checkInList: some View {
        Group {
            if checkIns.isEmpty {
                ContentUnavailableView("No Check-Ins Yet", systemImage: "face.smiling", description: Text("Your daily check-ins will appear here."))
            } else {
                List(checkIns) { checkIn in
                    HStack {
                        Text(anxietyEmoji(checkIn.anxietyLevel))
                            .font(.title2)
                        VStack(alignment: .leading) {
                            Text(anxietyLabel(checkIn.anxietyLevel))
                                .font(.headline)
                            Text(checkIn.date, style: .date)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        if let note = checkIn.note, !note.isEmpty {
                            Text(note)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                    }
                }
            }
        }
    }
    
    private func intensityEmoji(_ level: Int) -> String {
        let emojis = ["😌", "🙂", "😐", "😟", "😣", "😥", "😰", "😨", "😱", "🤯"]
        return emojis[max(0, min(level - 1, emojis.count - 1))]
    }
    
    private func anxietyEmoji(_ level: Int) -> String {
        let emojis = ["😌", "😊", "😐", "😟", "😰"]
        return emojis[max(0, min(level - 1, emojis.count - 1))]
    }
    
    private func anxietyLabel(_ level: Int) -> String {
        let labels = ["Calm", "Good", "Okay", "Anxious", "High"]
        return labels[max(0, min(level - 1, labels.count - 1))]
    }
}
