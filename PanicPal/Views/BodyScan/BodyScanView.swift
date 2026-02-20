import SwiftUI

struct MuscleGroup: Identifiable {
    let id: Int
    let name: String
    let icon: String
}

struct BodyScanView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var isQuick = true
    @State private var started = false
    @State private var currentGroupIndex = 0
    @State private var phase: ScanPhase = .tense
    @State private var countdown: Int = 5
    @State private var timer: Timer?
    @State private var showCompletion = false
    @State private var showJournalPrompt = false
    
    enum ScanPhase { case tense, release, pause }
    
    private let quickGroups: [MuscleGroup] = [
        MuscleGroup(id: 0, name: "Legs", icon: "figure.walk"),
        MuscleGroup(id: 1, name: "Torso", icon: "figure.stand"),
        MuscleGroup(id: 2, name: "Arms", icon: "hand.raised"),
        MuscleGroup(id: 3, name: "Face", icon: "face.smiling")
    ]
    
    private let fullGroups: [MuscleGroup] = [
        MuscleGroup(id: 0, name: "Feet", icon: "shoe"),
        MuscleGroup(id: 1, name: "Calves", icon: "figure.walk"),
        MuscleGroup(id: 2, name: "Thighs", icon: "figure.stand"),
        MuscleGroup(id: 3, name: "Stomach", icon: "figure.mind.and.body"),
        MuscleGroup(id: 4, name: "Chest", icon: "heart"),
        MuscleGroup(id: 5, name: "Hands", icon: "hand.raised"),
        MuscleGroup(id: 6, name: "Arms & Shoulders", icon: "figure.arms.open"),
        MuscleGroup(id: 7, name: "Face", icon: "face.smiling")
    ]
    
    private var groups: [MuscleGroup] { isQuick ? quickGroups : fullGroups }
    
    var body: some View {
        ZStack {
            AppColors.softLavender.opacity(0.2).ignoresSafeArea()
            
            if !started {
                selectionView
            } else if showCompletion {
                completionView
            } else {
                scanView
            }
        }
        .onDisappear { timer?.invalidate() }
        .sheet(isPresented: $showJournalPrompt) {
            JournalEntryView(technique: "Body scan")
        }
    }
    
    private var selectionView: some View {
        VStack(spacing: 24) {
            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "xmark").font(.title3).foregroundStyle(.secondary)
                }
                Spacer()
            }.padding()
            
            Spacer()
            
            Image(systemName: "figure.mind.and.body")
                .font(.system(size: 60))
                .foregroundStyle(AppColors.deepTeal)
            
            Text("Body Scan")
                .font(.title.weight(.semibold))
                .foregroundStyle(AppColors.deepTeal)
            
            Text("Progressive muscle relaxation with haptic guidance")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
            
            VStack(spacing: 12) {
                Button {
                    isQuick = true
                    startScan()
                } label: {
                    Text("Quick (3 min) — 4 groups")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppColors.deepTeal)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                
                Button {
                    isQuick = false
                    startScan()
                } label: {
                    Text("Full (7 min) — 8 groups")
                        .font(.headline)
                        .foregroundStyle(AppColors.deepTeal)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppColors.deepTeal.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
        }
    }
    
    private var scanView: some View {
        VStack(spacing: 20) {
            HStack {
                Button { timer?.invalidate(); dismiss() } label: {
                    Image(systemName: "xmark").font(.title3).foregroundStyle(.secondary)
                }
                Spacer()
                Text("\(currentGroupIndex + 1)/\(groups.count)")
                    .font(.caption).foregroundStyle(.secondary)
            }.padding()
            
            Spacer()
            
            // Body outline indicator
            Image(systemName: groups[currentGroupIndex].icon)
                .font(.system(size: 60))
                .foregroundStyle(AppColors.deepTeal)
                .shadow(color: AppColors.deepTeal.opacity(0.5), radius: 20)
            
            Text(groups[currentGroupIndex].name.uppercased())
                .font(.title.weight(.bold))
                .foregroundStyle(AppColors.deepTeal)
            
            Text(phaseInstruction)
                .font(.title3)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 30)
            
            Text("\(countdown)")
                .font(.system(size: 64, weight: .light, design: .rounded))
                .foregroundStyle(AppColors.deepTeal)
            
            Spacer()
        }
    }
    
    private var completionView: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "sparkles")
                .font(.system(size: 60))
                .foregroundStyle(AppColors.deepTeal)
            Text("Your body is relaxed.")
                .font(.title2.weight(.medium))
                .foregroundStyle(AppColors.deepTeal)
            Text("Carry this feeling with you.")
                .font(.body).foregroundStyle(.secondary)
            Spacer()
            Button {
                showJournalPrompt = true
            } label: {
                Text("Log in Journal")
                    .font(.headline).foregroundStyle(.white)
                    .frame(maxWidth: .infinity).padding()
                    .background(AppColors.deepTeal)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }.padding(.horizontal, 40)
            Button("Done") { dismiss() }
                .font(.subheadline).foregroundStyle(.secondary)
                .padding(.bottom, 30)
        }
    }
    
    private var phaseInstruction: String {
        switch phase {
        case .tense: return "Tense your \(groups[currentGroupIndex].name.lowercased()).\nHold for \(countdown) seconds..."
        case .release: return "Release.\nFeel the tension melt away."
        case .pause: return "Rest..."
        }
    }
    
    private func startScan() {
        started = true
        currentGroupIndex = 0
        startPhase(.tense)
    }
    
    private func startPhase(_ p: ScanPhase) {
        phase = p
        switch p {
        case .tense: countdown = 5
        case .release: countdown = 5
        case .pause: countdown = 3
        }
        
        if p == .tense {
            HapticService.shared.playTap(intensity: 0.8)
        } else if p == .release {
            HapticService.shared.playTap(intensity: 0.3)
        }
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            Task { @MainActor in
                countdown -= 1
                if countdown > 0 && phase == .tense {
                    HapticService.shared.playTap(intensity: 0.4)
                }
                if countdown <= 0 {
                    timer?.invalidate()
                    advancePhase()
                }
            }
        }
    }
    
    private func advancePhase() {
        switch phase {
        case .tense: startPhase(.release)
        case .release: startPhase(.pause)
        case .pause:
            if currentGroupIndex < groups.count - 1 {
                currentGroupIndex += 1
                startPhase(.tense)
            } else {
                showCompletion = true
            }
        }
    }
}
