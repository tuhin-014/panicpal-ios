import SwiftUI
import SwiftData

@MainActor
@Observable
class SettingsViewModel {
    var modelContext: ModelContext?
    
    func getSettings(context: ModelContext) -> UserSettings {
        self.modelContext = context
        let descriptor = FetchDescriptor<UserSettings>()
        let results = (try? context.fetch(descriptor)) ?? []
        if let settings = results.first {
            return settings
        }
        let settings = UserSettings()
        context.insert(settings)
        try? context.save()
        return settings
    }
    
    func save() {
        try? modelContext?.save()
    }
    
    func exportJournalCSV(context: ModelContext) -> String {
        let descriptor = FetchDescriptor<PanicEntry>(sortBy: [SortDescriptor(\.timestamp, order: .reverse)])
        let entries = (try? context.fetch(descriptor)) ?? []
        
        var csv = "Date,Intensity,Duration (min),Triggers,Techniques,Notes\n"
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        
        for entry in entries {
            let date = formatter.string(from: entry.timestamp)
            let triggers = entry.triggerTags.joined(separator: "; ")
            let techniques = entry.techniquesUsed.joined(separator: "; ")
            let notes = (entry.notes ?? "").replacingOccurrences(of: ",", with: ";")
            csv += "\(date),\(entry.intensity),\(entry.durationMinutes),\(triggers),\(techniques),\(notes)\n"
        }
        return csv
    }
}
