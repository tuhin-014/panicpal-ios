import CoreHaptics
import UIKit

@MainActor
class HapticService {
    static let shared = HapticService()
    private var engine: CHHapticEngine?
    private var player: CHHapticAdvancedPatternPlayer?
    
    private init() {}
    
    func prepareEngine() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        do {
            engine = try CHHapticEngine()
            engine?.stoppedHandler = { [weak self] reason in
                Task { @MainActor in
                    try? self?.engine?.start()
                }
            }
            engine?.resetHandler = { [weak self] in
                Task { @MainActor in
                    try? self?.engine?.start()
                }
            }
            try engine?.start()
        } catch {
            print("Haptic engine error: \(error)")
        }
    }
    
    func stopEngine() {
        try? player?.cancel()
        player = nil
        engine?.stop()
    }
    
    func playInhaleHaptic(duration: Double, intensity: Float) {
        guard let engine else { return }
        do {
            let event = CHHapticEvent(
                eventType: .hapticContinuous,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity * 0.6),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.3)
                ],
                relativeTime: 0,
                duration: duration
            )
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let p = try engine.makeAdvancedPlayer(with: pattern)
            self.player = p
            try p.start(atTime: CHHapticTimeImmediate)
        } catch {
            print("Inhale haptic error: \(error)")
        }
    }
    
    func playExhaleHaptic(duration: Double, intensity: Float) {
        guard let engine else { return }
        do {
            let tapCount = Int(duration * 2)
            let interval = duration / Double(tapCount)
            var events: [CHHapticEvent] = []
            for i in 0..<tapCount {
                let event = CHHapticEvent(
                    eventType: .hapticTransient,
                    parameters: [
                        CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity * 0.5),
                        CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.2)
                    ],
                    relativeTime: Double(i) * interval
                )
                events.append(event)
            }
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let p = try engine.makeAdvancedPlayer(with: pattern)
            self.player = p
            try p.start(atTime: CHHapticTimeImmediate)
        } catch {
            print("Exhale haptic error: \(error)")
        }
    }
    
    func playTap(intensity: Float = 0.5) {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred(intensity: CGFloat(intensity))
    }
    
    func playDoubleTap() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    func playCountdownPulse(intensity: Float) {
        guard let engine else { return }
        do {
            let event = CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity * 0.4),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.3)
                ],
                relativeTime: 0
            )
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let p = try engine.makePlayer(with: pattern)
            try p.start(atTime: CHHapticTimeImmediate)
        } catch {}
    }
    
    func stopCurrentHaptic() {
        try? player?.cancel()
        player = nil
    }
}
