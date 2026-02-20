import SwiftUI
import SwiftData

struct JournalEntryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    var technique: String = ""
    
    @State private var intensity: Double = 5
    @State private var selectedDuration: Int = 10
    @State private var selectedTriggers: Set<String> = []
    @State private var selectedTechniques: Set<String> = []
    @State private var notes: String = ""
    
    private let intensityEmojis = ["😌", "🙂", "😐", "😟", "😣", "😥", "😰", "😨", "😱", "🤯"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Intensity") {
                    VStack {
                        HStack {
                            Text(intensityEmojis[max(0, Int(intensity) - 1)])
                                .font(.system(size: 40))
                            Text("\(Int(intensity))/10")
                                .font(.title2.weight(.medium))
                                .foregroundStyle(AppColors.deepTeal)
                        }
                        Slider(value: $intensity, in: 1...10, step: 1)
                            .tint(AppColors.deepTeal)
                    }
                }
                
                Section("Duration") {
                    Picker("Minutes", selection: $selectedDuration) {
                        ForEach(DurationOptions.minutes, id: \.self) { min in
                            Text(min == 60 ? "60+" : "\(min) min").tag(min)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section("Triggers") {
                    FlowLayout(items: TriggerTags.all) { tag in
                        TagButton(title: tag, isSelected: selectedTriggers.contains(tag)) {
                            if selectedTriggers.contains(tag) {
                                selectedTriggers.remove(tag)
                            } else {
                                selectedTriggers.insert(tag)
                            }
                        }
                    }
                }
                
                Section("What Helped") {
                    FlowLayout(items: TechniqueOptions.all) { tech in
                        TagButton(title: tech, isSelected: selectedTechniques.contains(tech)) {
                            if selectedTechniques.contains(tech) {
                                selectedTechniques.remove(tech)
                            } else {
                                selectedTechniques.insert(tech)
                            }
                        }
                    }
                }
                
                Section("Notes (optional)") {
                    TextField("How are you feeling?", text: $notes, axis: .vertical)
                        .lineLimit(3...5)
                        .onChange(of: notes) { _, newValue in
                            if newValue.count > 500 {
                                notes = String(newValue.prefix(500))
                            }
                        }
                }
            }
            .navigationTitle("Log Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        save()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
            .onAppear {
                if !technique.isEmpty {
                    selectedTechniques.insert(technique)
                }
            }
        }
    }
    
    private func save() {
        let entry = PanicEntry(
            intensity: Int(intensity),
            durationMinutes: selectedDuration,
            triggerTags: Array(selectedTriggers),
            techniquesUsed: Array(selectedTechniques),
            notes: notes.isEmpty ? nil : notes
        )
        modelContext.insert(entry)
        try? modelContext.save()
    }
}

struct TagButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? AppColors.deepTeal : AppColors.deepTeal.opacity(0.1))
                .foregroundStyle(isSelected ? .white : AppColors.deepTeal)
                .clipShape(Capsule())
        }
    }
}

struct FlowLayout: View {
    let items: [String]
    let content: (String) -> TagButton
    
    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 8)], spacing: 8) {
            ForEach(items, id: \.self) { item in
                content(item)
            }
        }
    }
}
