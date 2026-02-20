import SwiftUI

struct ColdExposureView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedDuration: Int = 30
    @State private var isRunning = false
    @State private var timeRemaining: Double = 30
    @State private var showCompletion = false
    @State private var timer: Timer?
    @State private var showInfo = true
    
    private let durations = [15, 30, 60]
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.blue.opacity(0.15), AppColors.softLavender.opacity(0.2)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            if showInfo {
                infoCard
            } else if showCompletion {
                completionView
            } else {
                timerView
            }
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    private var infoCard: some View {
        VStack(spacing: 24) {
            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            .padding()
            
            Spacer()
            
            Image(systemName: "snowflake")
                .font(.system(size: 60))
                .foregroundStyle(AppColors.deepTeal)
            
            Text("Cold Exposure")
                .font(.title.weight(.semibold))
                .foregroundStyle(AppColors.deepTeal)
            
            Text("Hold ice, cold water, or splash cold water on your face. This triggers your dive reflex and physically slows your heart rate.")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 30)
            
            Text("Mammalian dive reflex — vagal nerve activation\n(Porges, 2011; Kox et al., 2014)")
                .font(.caption)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
            
            Spacer()
            
            // Duration picker
            HStack(spacing: 16) {
                ForEach(durations, id: \.self) { d in
                    Button {
                        selectedDuration = d
                    } label: {
                        Text("\(d)s")
                            .font(.headline)
                            .foregroundStyle(selectedDuration == d ? .white : AppColors.deepTeal)
                            .frame(width: 70, height: 44)
                            .background(selectedDuration == d ? AppColors.deepTeal : AppColors.deepTeal.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
            
            Button {
                timeRemaining = Double(selectedDuration)
                showInfo = false
                startTimer()
            } label: {
                Text("Start")
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
    }
    
    private var timerView: some View {
        VStack(spacing: 30) {
            Spacer()
            
            ZStack {
                Circle()
                    .stroke(AppColors.deepTeal.opacity(0.2), lineWidth: 8)
                    .frame(width: 200, height: 200)
                
                Circle()
                    .trim(from: 0, to: timeRemaining / Double(selectedDuration))
                    .stroke(AppColors.deepTeal, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .frame(width: 200, height: 200)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 0.1), value: timeRemaining)
                
                VStack {
                    Image(systemName: "snowflake")
                        .font(.title)
                        .foregroundStyle(AppColors.deepTeal)
                    Text("\(Int(ceil(timeRemaining)))s")
                        .font(.system(size: 48, weight: .light, design: .rounded))
                        .foregroundStyle(AppColors.deepTeal)
                }
            }
            
            Text("Keep holding...")
                .font(.title3)
                .foregroundStyle(.secondary)
            
            Spacer()
            
            Button("Stop") {
                timer?.invalidate()
                dismiss()
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .padding(.bottom, 30)
        }
    }
    
    private var completionView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(AppColors.deepTeal)
            
            Text("Your body is calming down.")
                .font(.title2.weight(.medium))
                .foregroundStyle(AppColors.deepTeal)
            
            Text("The dive reflex is working.")
                .font(.body)
                .foregroundStyle(.secondary)
            
            Spacer()
            
            Button("Done") { dismiss() }
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(AppColors.deepTeal)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal, 40)
                .padding(.bottom, 30)
        }
    }
    
    private func startTimer() {
        isRunning = true
        var pulseCounter: Double = 0
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            Task { @MainActor in
                timeRemaining -= 0.1
                pulseCounter += 0.1
                if pulseCounter >= 5.0 {
                    pulseCounter = 0
                    HapticService.shared.playTap()
                }
                if timeRemaining <= 0 {
                    timer?.invalidate()
                    isRunning = false
                    showCompletion = true
                }
            }
        }
    }
}
