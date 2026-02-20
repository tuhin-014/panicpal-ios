import SwiftUI

struct SituationGuide: Identifiable {
    let id: Int
    let title: String
    let icon: String
    let steps: [String]
    let encouragement: String
    let relatedTools: [String]
}

let situationGuides: [SituationGuide] = [
    SituationGuide(id: 0, title: "Panic while driving", icon: "car.fill", steps: [
        "Pull over safely if possible",
        "If you can't pull over: grip the wheel, focus on the road line",
        "4-count breathing (inhale 4, exhale 4 — simple)",
        "Turn on the AC or open a window for cold air"
    ], encouragement: "You are in control of this car. The panic is a passenger, not the driver.", relatedTools: ["Breathing"]),
    
    SituationGuide(id: 1, title: "Panic at work or school", icon: "building.2.fill", steps: [
        "Excuse yourself to restroom if possible",
        "If you can't leave: cold water on wrists, discrete breathing",
        "Ground: feel your feet on the floor, hands on the desk",
        "Count objects: 5 things on your desk, 4 colors you see"
    ], encouragement: "No one can tell you're panicking. You look normal.", relatedTools: ["Breathing", "Grounding"]),
    
    SituationGuide(id: 2, title: "Panic in a store or public place", icon: "cart.fill", steps: [
        "Find a wall to lean against (physical anchor)",
        "Count items: 5 red things, 4 blue things...",
        "Focus on your feet on the ground",
        "You can leave anytime — but try staying"
    ], encouragement: "You can leave anytime. But try staying — the panic will pass.", relatedTools: ["Grounding"]),
    
    SituationGuide(id: 3, title: "Panic at night in bed", icon: "moon.fill", steps: [
        "Get out of bed. Sit in a chair. Change the environment.",
        "Cold water on face (triggers dive reflex)",
        "Try a body scan lying down",
        "Turn on a dim light — darkness can amplify fear"
    ], encouragement: "Nighttime panic is scary but harmless. Your body is safe.", relatedTools: ["Cold Exposure", "Body Scan"]),
    
    SituationGuide(id: 4, title: "Panic during a social event", icon: "person.3.fill", steps: [
        "Step outside for 2 minutes (fresh air)",
        "Text your emergency contact",
        "Physiological sigh (double inhale, long exhale)",
        "Hold something cold — a drink, ice from the bar"
    ], encouragement: "You don't have to explain. Just take a moment.", relatedTools: ["Breathing", "Cold Exposure"]),
    
    SituationGuide(id: 5, title: "Health anxiety panic", icon: "heart.text.square.fill", steps: [
        "Remember: Panic vs Heart Attack — if you're reading this, you're thinking clearly",
        "Check: Am I catastrophizing a normal body sensation?",
        "Put your hand on your chest — feel your steady heartbeat",
        "Schedule a doctor visit for peace of mind — but right now, breathe"
    ], encouragement: "If you're reading this, you're conscious and thinking clearly — that's a good sign.", relatedTools: ["Breathing", "Education"])
]

struct SituationGuidesView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(situationGuides) { guide in
                        NavigationLink {
                            SituationDetailView(guide: guide)
                        } label: {
                            HStack(spacing: 16) {
                                Image(systemName: guide.icon)
                                    .font(.title2)
                                    .foregroundStyle(AppColors.deepTeal)
                                    .frame(width: 44)
                                
                                Text(guide.title)
                                    .font(.headline)
                                    .foregroundStyle(.primary)
                                    .multilineTextAlignment(.leading)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(.secondary)
                            }
                            .padding()
                            .background(Color(.systemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .shadow(color: .black.opacity(0.05), radius: 4)
                        }
                    }
                }
                .padding()
            }
            .background(AppColors.safetyWhite)
            .navigationTitle("Situation Guides")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                    }
                }
            }
        }
    }
}

struct SituationDetailView: View {
    let guide: SituationGuide
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                HStack {
                    Image(systemName: guide.icon)
                        .font(.title)
                        .foregroundStyle(AppColors.deepTeal)
                    Text(guide.title)
                        .font(.title2.weight(.bold))
                        .foregroundStyle(AppColors.deepTeal)
                }
                
                // Steps
                ForEach(Array(guide.steps.enumerated()), id: \.offset) { index, step in
                    HStack(alignment: .top, spacing: 12) {
                        Text("\(index + 1)")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(width: 28, height: 28)
                            .background(AppColors.deepTeal)
                            .clipShape(Circle())
                        
                        Text(step)
                            .font(.body)
                            .lineSpacing(4)
                    }
                }
                
                // Encouragement
                Text(guide.encouragement)
                    .font(.title3.weight(.medium))
                    .foregroundStyle(AppColors.deepTeal)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(AppColors.deepTeal.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                
                // Related tools
                if !guide.relatedTools.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Related Tools")
                            .font(.headline)
                        HStack {
                            ForEach(guide.relatedTools, id: \.self) { tool in
                                Text(tool)
                                    .font(.subheadline)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(AppColors.deepTeal.opacity(0.1))
                                    .clipShape(Capsule())
                            }
                        }
                    }
                }
            }
            .padding(24)
        }
    }
}
