import SwiftUI
import SwiftData

struct DailyCheckInView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var anxietyLevel = 3
    @State private var note = ""
    
    private let levels = [
        (emoji: "😌", label: "Calm"),
        (emoji: "😊", label: "Good"),
        (emoji: "😐", label: "Okay"),
        (emoji: "😟", label: "Anxious"),
        (emoji: "😰", label: "High")
    ]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                Spacer()
                
                Text("How's your anxiety today?")
                    .font(.title2.weight(.medium))
                    .foregroundStyle(AppColors.deepTeal)
                
                HStack(spacing: 16) {
                    ForEach(0..<5, id: \.self) { index in
                        let level = index + 1
                        Button {
                            anxietyLevel = level
                        } label: {
                            VStack(spacing: 4) {
                                Text(levels[index].emoji)
                                    .font(.system(size: anxietyLevel == level ? 44 : 32))
                                Text(levels[index].label)
                                    .font(.caption2)
                                    .foregroundStyle(anxietyLevel == level ? AppColors.deepTeal : .secondary)
                            }
                        }
                        .scaleEffect(anxietyLevel == level ? 1.1 : 1.0)
                        .animation(.spring(response: 0.3), value: anxietyLevel)
                    }
                }
                
                TextField("Quick note (optional)", text: $note)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal, 40)
                
                Spacer()
                
                Button {
                    save()
                    dismiss()
                } label: {
                    Text("Done")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppColors.deepTeal)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 30)
            }
            .navigationTitle("Daily Check-In")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
    
    private func save() {
        let checkIn = DailyCheckIn(anxietyLevel: anxietyLevel, note: note.isEmpty ? nil : note)
        modelContext.insert(checkIn)
        try? modelContext.save()
    }
}
