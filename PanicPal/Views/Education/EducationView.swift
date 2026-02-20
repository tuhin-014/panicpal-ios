import SwiftUI
import SwiftData

struct EducationLesson: Identifiable {
    let id: Int
    let title: String
    let body: String
}

let educationLessons: [EducationLesson] = [
    EducationLesson(id: 0, title: "What is a panic attack?",
        body: "A panic attack is your fight-or-flight system misfiring. Your brain detects a threat that isn't there and floods your body with adrenaline.\n\nThis causes rapid heartbeat, shortness of breath, dizziness, tingling, and a feeling of dread. It's extremely uncomfortable, but never dangerous.\n\nYour body is doing exactly what it's designed to do — it's just doing it at the wrong time."),
    EducationLesson(id: 1, title: "Why your heart races",
        body: "When your brain detects danger (real or imagined), it releases adrenaline. This hormone increases your heart rate to pump blood to your muscles — preparing you to run from a tiger.\n\nThe problem? There's no tiger. But your heart doesn't know that. It's doing its job perfectly.\n\nYour heart is strong. It can handle this. It's designed to speed up and slow down."),
    EducationLesson(id: 2, title: "The panic cycle",
        body: "Here's what happens: You feel a strange sensation → you think 'something is wrong' → anxiety increases → more physical symptoms → more fear → panic attack.\n\nThis is the panic cycle. Fear of panic creates more anxiety, which creates more panic.\n\nThe good news? Understanding this cycle is the first step to breaking it. When you recognize it happening, you take away its power."),
    EducationLesson(id: 3, title: "Why panic attacks always end",
        body: "Your body physically cannot sustain a panic attack indefinitely. Here's why:\n\nAdrenaline depletes. Your body has a limited supply, and it burns through it quickly.\n\nYour parasympathetic nervous system (the 'brake pedal') automatically activates to calm you down.\n\nMost panic attacks peak at 10 minutes and are over within 20-30 minutes. Every single one ends."),
    EducationLesson(id: 4, title: "Panic attack vs heart attack",
        body: "Panic Attack:\n• Tingling in hands/feet\n• Racing thoughts\n• Feeling of unreality\n• Peaks in ~10 minutes\n• Triggered by anxiety/stress\n\nHeart Attack:\n• Crushing chest pressure\n• Pain in left arm/jaw\n• Cold sweats\n• Doesn't come and go\n• Often during physical exertion\n\nIf you're ever unsure, call 911. But if you're reading this on your phone and thinking clearly — that's a very good sign."),
    EducationLesson(id: 5, title: "Common triggers",
        body: "Panic attacks often have identifiable triggers:\n\n☕ Caffeine — stimulates the same pathways as anxiety\n😴 Poor sleep — lowers your stress threshold\n📱 Stress — work, relationships, finances\n💨 Hyperventilation — breathing too fast causes many panic symptoms\n🏥 Health anxiety — monitoring body sensations too closely\n🔄 Major life changes — even positive ones\n\nTracking your triggers in the journal can reveal patterns you didn't notice."),
    EducationLesson(id: 6, title: "Why avoidance makes it worse",
        body: "When you avoid a situation because you had a panic attack there, your brain learns: 'That place was dangerous — good thing we escaped.'\n\nBut it wasn't dangerous. By avoiding it, you've confirmed a false belief.\n\nEach avoidance makes the fear stronger. Each time you face the situation and survive (which you will), your brain learns it's safe.\n\nThis is the core principle of exposure therapy. Not jumping in the deep end — but gradually showing your brain the truth."),
    EducationLesson(id: 7, title: "The role of breathing",
        body: "During panic, you often hyperventilate — breathing too fast and too shallow. This actually causes many panic symptoms:\n\n• Dizziness (too much oxygen, not enough CO2)\n• Tingling in hands and feet\n• Feeling lightheaded or faint\n• Chest tightness\n\nSlow, controlled breathing reverses all of these. It's not just relaxation — it's directly fixing the chemical imbalance caused by hyperventilation.\n\nThat's why breathing exercises work so well during panic."),
    EducationLesson(id: 8, title: "Your nervous system explained",
        body: "You have two systems:\n\n🚗 Sympathetic (gas pedal): Fight or flight. Speeds everything up. Heart races, muscles tense, pupils dilate.\n\n🛑 Parasympathetic (brake pedal): Rest and digest. Slows everything down. Heart calms, muscles relax, you feel safe.\n\nDuring panic, your gas pedal is floored. But here's the trick: slow exhaling directly activates the brake pedal through the vagus nerve.\n\nEvery slow breath is literally pressing the brake. Your body will respond."),
    EducationLesson(id: 9, title: "You're not going crazy",
        body: "During panic, you might experience:\n\n🌀 Depersonalization — feeling detached from yourself\n🌀 Derealization — the world looks unreal or dreamlike\n💭 Intrusive thoughts — scary 'what if' thoughts\n🫠 Feeling like you're 'losing it'\n\nAll of these are completely normal panic symptoms. They are caused by adrenaline and hyperventilation, not by mental illness.\n\nThey pass when the panic passes. Every single time.\n\nYou are not going crazy. You are having a well-understood, temporary biological response.")
]

struct EducationView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var progress: [LessonProgress]
    @State private var currentIndex = 0
    
    private func isRead(_ index: Int) -> Bool {
        progress.contains { $0.lessonIndex == index && $0.read }
    }
    
    var body: some View {
        NavigationStack {
            TabView(selection: $currentIndex) {
                ForEach(educationLessons) { lesson in
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("\(lesson.id + 1)/\(educationLessons.count)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Spacer()
                                if isRead(lesson.id) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(AppColors.deepTeal)
                                }
                            }
                            
                            Text(lesson.title)
                                .font(.title2.weight(.bold))
                                .foregroundStyle(AppColors.deepTeal)
                            
                            Text(lesson.body)
                                .font(.body)
                                .lineSpacing(6)
                            
                            Button {
                                toggleRead(lesson.id)
                            } label: {
                                Text(isRead(lesson.id) ? "Mark Unread" : "Mark as Read")
                                    .font(.subheadline.weight(.medium))
                                    .foregroundStyle(AppColors.deepTeal)
                            }
                            .padding(.top, 8)
                        }
                        .padding(24)
                    }
                    .tag(lesson.id)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .navigationTitle("Understanding Panic")
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
    
    private func toggleRead(_ index: Int) {
        if let existing = progress.first(where: { $0.lessonIndex == index }) {
            existing.read.toggle()
            existing.readAt = existing.read ? Date() : nil
        } else {
            let lp = LessonProgress(lessonIndex: index, read: true)
            lp.readAt = Date()
            modelContext.insert(lp)
        }
        try? modelContext.save()
    }
}
