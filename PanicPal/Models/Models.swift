import Foundation
import SwiftData

// MARK: - Enums (raw String values for SwiftData compatibility)

enum BreathingPattern: String, CaseIterable, Codable {
    case fourSevenEight = "fourSevenEight"
    case boxBreathing = "boxBreathing"
    case physiologicalSigh = "physiologicalSigh"
    case simpleCalm = "simpleCalm"
    
    var displayName: String {
        switch self {
        case .fourSevenEight: return "4-7-8 Breathing"
        case .boxBreathing: return "Box Breathing"
        case .physiologicalSigh: return "Physiological Sigh"
        case .simpleCalm: return "Simple Calm"
        }
    }
    
    var description: String {
        switch self {
        case .fourSevenEight: return "Inhale 4s, Hold 7s, Exhale 8s"
        case .boxBreathing: return "Inhale 4s, Hold 4s, Exhale 4s, Hold 4s"
        case .physiologicalSigh: return "Double inhale, Long exhale"
        case .simpleCalm: return "Inhale 4s, Exhale 6s"
        }
    }
    
    struct Phase {
        let name: String
        let duration: Double
        let isInhale: Bool
        let isHold: Bool
        let isExhale: Bool
    }
    
    var phases: [Phase] {
        switch self {
        case .fourSevenEight:
            return [
                Phase(name: "Inhale", duration: 4, isInhale: true, isHold: false, isExhale: false),
                Phase(name: "Hold", duration: 7, isInhale: false, isHold: true, isExhale: false),
                Phase(name: "Exhale", duration: 8, isInhale: false, isHold: false, isExhale: true)
            ]
        case .boxBreathing:
            return [
                Phase(name: "Inhale", duration: 4, isInhale: true, isHold: false, isExhale: false),
                Phase(name: "Hold", duration: 4, isInhale: false, isHold: true, isExhale: false),
                Phase(name: "Exhale", duration: 4, isInhale: false, isHold: false, isExhale: true),
                Phase(name: "Hold", duration: 4, isInhale: false, isHold: true, isExhale: false)
            ]
        case .physiologicalSigh:
            return [
                Phase(name: "Inhale", duration: 2, isInhale: true, isHold: false, isExhale: false),
                Phase(name: "Inhale", duration: 2, isInhale: true, isHold: false, isExhale: false),
                Phase(name: "Exhale", duration: 6, isInhale: false, isHold: false, isExhale: true)
            ]
        case .simpleCalm:
            return [
                Phase(name: "Inhale", duration: 4, isInhale: true, isHold: false, isExhale: false),
                Phase(name: "Exhale", duration: 6, isInhale: false, isHold: false, isExhale: true)
            ]
        }
    }
    
    var totalCycleDuration: Double {
        phases.reduce(0) { $0 + $1.duration }
    }
}

enum AppTheme: String, CaseIterable, Codable {
    case light, dark, system
    var displayName: String { rawValue.capitalized }
}

enum HapticLevel: String, CaseIterable, Codable {
    case light, medium, strong
    var displayName: String { rawValue.capitalized }
    var intensity: Float {
        switch self {
        case .light: return 0.4
        case .medium: return 0.7
        case .strong: return 1.0
        }
    }
}

enum ShakeSensitivity: String, CaseIterable, Codable {
    case low, medium, high
    var displayName: String { rawValue.capitalized }
    var threshold: Double {
        switch self {
        case .low: return 3.0
        case .medium: return 2.0
        case .high: return 1.5
        }
    }
}

// MARK: - SwiftData Models

@Model
final class PanicEntry {
    var id: UUID
    var timestamp: Date
    var intensity: Int
    var durationMinutes: Int
    var triggerTagsRaw: String // comma-separated
    var techniquesUsedRaw: String // comma-separated
    var notes: String?
    var createdAt: Date
    
    var triggerTags: [String] {
        get { triggerTagsRaw.isEmpty ? [] : triggerTagsRaw.components(separatedBy: ",") }
        set { triggerTagsRaw = newValue.joined(separator: ",") }
    }
    
    var techniquesUsed: [String] {
        get { techniquesUsedRaw.isEmpty ? [] : techniquesUsedRaw.components(separatedBy: ",") }
        set { techniquesUsedRaw = newValue.joined(separator: ",") }
    }
    
    init(intensity: Int = 5, durationMinutes: Int = 10, triggerTags: [String] = [], techniquesUsed: [String] = [], notes: String? = nil) {
        self.id = UUID()
        self.timestamp = Date()
        self.intensity = intensity
        self.durationMinutes = durationMinutes
        self.triggerTagsRaw = triggerTags.joined(separator: ",")
        self.techniquesUsedRaw = techniquesUsed.joined(separator: ",")
        self.notes = notes
        self.createdAt = Date()
    }
}

@Model
final class EmergencyContact {
    var id: UUID
    var name: String
    var phoneNumber: String
    var sortOrder: Int
    
    init(name: String = "", phoneNumber: String = "", sortOrder: Int = 0) {
        self.id = UUID()
        self.name = name
        self.phoneNumber = phoneNumber
        self.sortOrder = sortOrder
    }
}

@Model
final class FavoriteReassurance {
    var id: UUID
    var messageIndex: Int
    var favoritedAt: Date
    
    init(messageIndex: Int) {
        self.id = UUID()
        self.messageIndex = messageIndex
        self.favoritedAt = Date()
    }
}

@Model
final class BreathingSession {
    var id: UUID
    var patternRaw: String
    var durationSeconds: Int
    var completed: Bool
    var completedAt: Date
    
    var pattern: BreathingPattern {
        get { BreathingPattern(rawValue: patternRaw) ?? .fourSevenEight }
        set { patternRaw = newValue.rawValue }
    }
    
    init(pattern: BreathingPattern = .fourSevenEight, durationSeconds: Int = 0, completed: Bool = false) {
        self.id = UUID()
        self.patternRaw = pattern.rawValue
        self.durationSeconds = durationSeconds
        self.completed = completed
        self.completedAt = Date()
    }
}

@Model
final class DailyCheckIn {
    var id: UUID
    var date: Date
    var anxietyLevel: Int
    var note: String?
    var createdAt: Date
    
    init(anxietyLevel: Int = 3, note: String? = nil) {
        self.id = UUID()
        self.date = Calendar.current.startOfDay(for: Date())
        self.anxietyLevel = anxietyLevel
        self.note = note
        self.createdAt = Date()
    }
}

@Model
final class UserSettings {
    var id: UUID
    var defaultPatternRaw: String
    var sessionDurationSec: Int
    var hapticEnabled: Bool
    var hapticIntensityRaw: String
    var soundEnabled: Bool
    var shakeSOSEnabled: Bool
    var shakeSensitivityRaw: String
    var companionEnabled: Bool
    var dailyCheckInEnabled: Bool
    var dailyCheckInTime: Date?
    var themeRaw: String
    var onboardingCompleted: Bool
    var autoStartBreathing: Bool
    
    var defaultPattern: BreathingPattern {
        get { BreathingPattern(rawValue: defaultPatternRaw) ?? .fourSevenEight }
        set { defaultPatternRaw = newValue.rawValue }
    }
    
    var hapticIntensity: HapticLevel {
        get { HapticLevel(rawValue: hapticIntensityRaw) ?? .medium }
        set { hapticIntensityRaw = newValue.rawValue }
    }
    
    var shakeSensitivity: ShakeSensitivity {
        get { ShakeSensitivity(rawValue: shakeSensitivityRaw) ?? .medium }
        set { shakeSensitivityRaw = newValue.rawValue }
    }
    
    var theme: AppTheme {
        get { AppTheme(rawValue: themeRaw) ?? .system }
        set { themeRaw = newValue.rawValue }
    }
    
    init() {
        self.id = UUID()
        self.defaultPatternRaw = BreathingPattern.fourSevenEight.rawValue
        self.sessionDurationSec = 300
        self.hapticEnabled = true
        self.hapticIntensityRaw = HapticLevel.medium.rawValue
        self.soundEnabled = false
        self.shakeSOSEnabled = true
        self.shakeSensitivityRaw = ShakeSensitivity.medium.rawValue
        self.companionEnabled = true
        self.dailyCheckInEnabled = false
        self.dailyCheckInTime = nil
        self.themeRaw = AppTheme.system.rawValue
        self.onboardingCompleted = false
        self.autoStartBreathing = false
    }
}

@Model
final class LessonProgress {
    var id: UUID
    var lessonIndex: Int
    var read: Bool
    var readAt: Date?
    
    init(lessonIndex: Int, read: Bool = false) {
        self.id = UUID()
        self.lessonIndex = lessonIndex
        self.read = read
        self.readAt = nil
    }
}
