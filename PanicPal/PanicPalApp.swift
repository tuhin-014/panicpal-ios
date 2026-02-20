import SwiftUI
import SwiftData

@main
struct PanicPalApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(for: [
            PanicEntry.self,
            EmergencyContact.self,
            FavoriteReassurance.self,
            BreathingSession.self,
            DailyCheckIn.self,
            UserSettings.self,
            LessonProgress.self
        ])
    }
}

struct RootView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var settingsResults: [UserSettings]
    @State private var onboardingCompleted = false
    @State private var showSOSBreathing = false
    
    private var settings: UserSettings? { settingsResults.first }
    
    var body: some View {
        Group {
            if !onboardingCompleted && settings?.onboardingCompleted != true {
                OnboardingView(isCompleted: $onboardingCompleted)
            } else {
                ShakeDetectingView {
                    if settings?.shakeSOSEnabled != false {
                        showSOSBreathing = true
                        HapticService.shared.playDoubleTap()
                    }
                } content: {
                    HomeView()
                        .fullScreenCover(isPresented: $showSOSBreathing) {
                            BreathingView(
                                initialPattern: settings?.defaultPattern ?? .fourSevenEight,
                                sessionDuration: Double(settings?.sessionDurationSec ?? 300),
                                hapticEnabled: settings?.hapticEnabled ?? true,
                                hapticIntensity: settings?.hapticIntensity ?? .medium
                            )
                        }
                }
            }
        }
        .onAppear {
            if settings?.onboardingCompleted == true {
                onboardingCompleted = true
            }
            ensureSettings()
        }
        .preferredColorScheme(colorScheme)
    }
    
    private var colorScheme: ColorScheme? {
        switch settings?.theme ?? .system {
        case .light: return .light
        case .dark: return .dark
        case .system: return nil
        }
    }
    
    private func ensureSettings() {
        if settingsResults.isEmpty {
            let s = UserSettings()
            modelContext.insert(s)
            try? modelContext.save()
        }
    }
}

// MARK: - Shake Detection via UIKit bridge
struct ShakeDetectingView<Content: View>: UIViewControllerRepresentable {
    let onShake: () -> Void
    @ViewBuilder let content: () -> Content
    
    func makeUIViewController(context: Context) -> ShakeHostingController<Content> {
        let controller = ShakeHostingController(rootView: content(), onShake: onShake)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: ShakeHostingController<Content>, context: Context) {
        uiViewController.rootView = content()
    }
}

class ShakeHostingController<Content: View>: UIHostingController<Content> {
    let onShake: () -> Void
    
    init(rootView: Content, onShake: @escaping () -> Void) {
        self.onShake = onShake
        super.init(rootView: rootView)
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            onShake()
        }
        super.motionEnded(motion, with: event)
    }
    
    override var canBecomeFirstResponder: Bool { true }
}
