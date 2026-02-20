import SwiftUI

struct GroundingView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var currentStep = 0
    @State private var showCompletion = false
    @State private var showJournalPrompt = false
    
    private let steps = [
        (count: 5, sense: "SEE", emoji: "👁️"),
        (count: 4, sense: "TOUCH", emoji: "✋"),
        (count: 3, sense: "HEAR", emoji: "👂"),
        (count: 2, sense: "SMELL", emoji: "👃"),
        (count: 1, sense: "TASTE", emoji: "👅")
    ]
    
    var body: some View {
        ZStack {
            AppColors.softLavender.opacity(0.3)
                .ignoresSafeArea()
            
            if showCompletion {
                completionView
            } else {
                stepView
            }
        }
        .sheet(isPresented: $showJournalPrompt) {
            JournalEntryView(technique: "Grounding")
        }
    }
    
    private var stepView: some View {
        VStack(spacing: 0) {
            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text("\(currentStep + 1) of 5")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
            
            Spacer()
            
            Text(steps[currentStep].emoji)
                .font(.system(size: 60))
                .padding(.bottom, 20)
            
            Text("Name \(steps[currentStep].count) thing\(steps[currentStep].count == 1 ? "" : "s") you can \(steps[currentStep].sense)")
                .font(.system(size: 32, weight: .medium))
                .multilineTextAlignment(.center)
                .foregroundStyle(AppColors.deepTeal)
                .padding(.horizontal, 30)
            
            Spacer()
            
            Text("Tap anywhere to continue")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(.bottom, 40)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            HapticService.shared.playTap()
            if currentStep < steps.count - 1 {
                withAnimation(.easeInOut(duration: 0.3)) {
                    currentStep += 1
                }
            } else {
                withAnimation {
                    showCompletion = true
                }
            }
        }
    }
    
    private var completionView: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: "leaf.fill")
                .font(.system(size: 60))
                .foregroundStyle(AppColors.deepTeal)
            
            VStack(spacing: 12) {
                Text("You're grounded.")
                    .font(.title.weight(.medium))
                Text("You're here.")
                    .font(.title2)
                Text("You're safe.")
                    .font(.title2)
            }
            .foregroundStyle(AppColors.deepTeal)
            
            Spacer()
            
            Button {
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
            
            Button("Done") { dismiss() }
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(.bottom, 30)
        }
    }
}
