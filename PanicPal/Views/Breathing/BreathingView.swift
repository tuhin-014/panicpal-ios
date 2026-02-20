import SwiftUI
import SwiftData

struct BreathingView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = BreathingViewModel()
    @State private var showJournalPrompt = false
    @State private var dragOffset: CGFloat = 0
    
    var initialPattern: BreathingPattern = .fourSevenEight
    var sessionDuration: Double = 300
    var hapticEnabled: Bool = true
    var hapticIntensity: HapticLevel = .medium
    
    var body: some View {
        ZStack {
            backgroundGradient
                .ignoresSafeArea()
            
            if viewModel.showCompletion {
                completionView
            } else {
                breathingContent
            }
        }
        .onAppear {
            viewModel.start(
                pattern: initialPattern,
                duration: sessionDuration,
                haptic: hapticEnabled,
                intensity: hapticIntensity
            )
        }
        .onDisappear {
            viewModel.stop()
        }
        .sheet(isPresented: $showJournalPrompt) {
            JournalEntryView(technique: "Breathing")
        }
    }
    
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [AppColors.deepTeal.opacity(0.3), AppColors.softLavender.opacity(0.3)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var breathingContent: some View {
        VStack(spacing: 20) {
            // Pattern name
            Text(viewModel.currentPattern.displayName)
                .font(.title2.weight(.medium))
                .foregroundStyle(AppColors.deepTeal)
                .padding(.top, 40)
            
            Text(viewModel.currentPattern.description)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Spacer()
            
            // Breathing circle
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [AppColors.deepTeal.opacity(0.6), AppColors.softLavender.opacity(0.4)],
                            center: .center,
                            startRadius: 20,
                            endRadius: 120
                        )
                    )
                    .frame(width: 220, height: 220)
                    .scaleEffect(viewModel.circleScale)
                
                VStack(spacing: 8) {
                    Text(viewModel.phaseName)
                        .font(.title.weight(.semibold))
                        .foregroundStyle(.white)
                    
                    Text("\(Int(ceil(viewModel.phaseTimeRemaining)))s")
                        .font(.system(size: 48, weight: .light, design: .rounded))
                        .foregroundStyle(.white.opacity(0.9))
                }
            }
            .gesture(
                DragGesture(minimumDistance: 50)
                    .onEnded { value in
                        if value.translation.width < -50 {
                            viewModel.switchPattern(direction: 1)
                        } else if value.translation.width > 50 {
                            viewModel.switchPattern(direction: -1)
                        }
                    }
            )
            
            Spacer()
            
            // Session timer
            Text(formatTime(viewModel.totalTimeRemaining))
                .font(.caption)
                .foregroundStyle(.secondary)
            
            // End session button
            Button("End Session") {
                viewModel.complete()
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .padding(.bottom, 30)
        }
    }
    
    private var completionView: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(AppColors.deepTeal)
            
            Text("Great job. You did it.")
                .font(.title.weight(.medium))
                .foregroundStyle(AppColors.deepTeal)
            
            Spacer()
            
            Button {
                logSession()
                showJournalPrompt = true
            } label: {
                Text("Log in Journal")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppColors.deepTeal)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .padding(.horizontal, 40)
            
            Button("Done") {
                logSession()
                dismiss()
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .padding(.bottom, 30)
        }
    }
    
    private func logSession() {
        let session = BreathingSession(
            pattern: viewModel.currentPattern,
            durationSeconds: Int(viewModel.sessionDuration - viewModel.totalTimeRemaining),
            completed: viewModel.totalTimeRemaining <= 0
        )
        modelContext.insert(session)
        try? modelContext.save()
    }
    
    private func formatTime(_ seconds: Double) -> String {
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%d:%02d", mins, secs)
    }
}
