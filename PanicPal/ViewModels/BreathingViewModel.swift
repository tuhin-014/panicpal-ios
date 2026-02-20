import SwiftUI
import SwiftData
import Combine

@MainActor
@Observable
class BreathingViewModel {
    var currentPattern: BreathingPattern = .fourSevenEight
    var isActive = false
    var currentPhaseIndex = 0
    var phaseTimeRemaining: Double = 0
    var totalTimeRemaining: Double = 300
    var sessionDuration: Double = 300
    var circleScale: CGFloat = 0.5
    var phaseName: String = ""
    var showCompletion = false
    var hapticEnabled = true
    var hapticIntensity: HapticLevel = .medium
    
    private var timer: Timer?
    private var phaseTimer: Timer?
    
    var phases: [BreathingPattern.Phase] {
        currentPattern.phases
    }
    
    func start(pattern: BreathingPattern, duration: Double, haptic: Bool, intensity: HapticLevel) {
        currentPattern = pattern
        sessionDuration = duration
        totalTimeRemaining = duration
        hapticEnabled = haptic
        hapticIntensity = intensity
        isActive = true
        showCompletion = false
        
        if hapticEnabled {
            HapticService.shared.prepareEngine()
        }
        
        startPhase(index: 0)
        startSessionTimer()
    }
    
    func stop() {
        isActive = false
        timer?.invalidate()
        timer = nil
        phaseTimer?.invalidate()
        phaseTimer = nil
        HapticService.shared.stopCurrentHaptic()
        HapticService.shared.stopEngine()
    }
    
    func complete() {
        stop()
        showCompletion = true
    }
    
    func switchPattern(direction: Int) {
        let patterns = BreathingPattern.allCases
        guard let idx = patterns.firstIndex(of: currentPattern) else { return }
        let newIdx = (idx + direction + patterns.count) % patterns.count
        currentPattern = patterns[newIdx]
        phaseTimer?.invalidate()
        startPhase(index: 0)
    }
    
    private func startSessionTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self, self.isActive else { return }
                self.totalTimeRemaining -= 0.1
                if self.totalTimeRemaining <= 0 {
                    self.complete()
                }
            }
        }
    }
    
    private func startPhase(index: Int) {
        let phaseIdx = index % phases.count
        currentPhaseIndex = phaseIdx
        let phase = phases[phaseIdx]
        phaseName = phase.name
        phaseTimeRemaining = phase.duration
        
        // Animate circle
        let targetScale: CGFloat = phase.isInhale ? 1.0 : (phase.isHold ? circleScale : 0.5)
        withAnimation(.easeInOut(duration: phase.duration)) {
            circleScale = targetScale
        }
        
        // Haptics
        if hapticEnabled {
            HapticService.shared.stopCurrentHaptic()
            if phase.isInhale {
                HapticService.shared.playInhaleHaptic(duration: phase.duration, intensity: hapticIntensity.intensity)
            } else if phase.isExhale {
                HapticService.shared.playExhaleHaptic(duration: phase.duration, intensity: hapticIntensity.intensity)
            }
        }
        
        // Phase countdown
        phaseTimer?.invalidate()
        phaseTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self, self.isActive else { return }
                self.phaseTimeRemaining -= 0.1
                if self.phaseTimeRemaining <= 0 {
                    self.phaseTimer?.invalidate()
                    self.startPhase(index: index + 1)
                }
            }
        }
    }
}
