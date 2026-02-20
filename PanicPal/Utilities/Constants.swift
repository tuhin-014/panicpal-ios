import SwiftUI

enum AppColors {
    static let deepTeal = Color(hex: "0D7377")
    static let softLavender = Color(hex: "E8D5F5")
    static let safetyWhite = Color(hex: "FAFAFA")
    static let warmCoral = Color(hex: "FF6B6B")
    static let calmNavy = Color(hex: "1A1A2E")
    
    static let tealGradient = LinearGradient(
        colors: [deepTeal, deepTeal.opacity(0.7)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let lavenderGradient = LinearGradient(
        colors: [softLavender, softLavender.opacity(0.7)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = ((int >> 24) & 0xFF, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

enum ReassuranceMessages {
    static let all: [String] = [
        "This will pass. It always does.",
        "You've survived every panic attack so far — 100% success rate.",
        "Your body is not in danger. This is adrenaline, not a heart attack.",
        "This feeling is temporary. It peaks in 10 minutes, then fades.",
        "You are safe right now, right here.",
        "Thousands of people are feeling this exact thing right now. You're not alone.",
        "Your brain is sending a false alarm. You can override it.",
        "In 10 minutes, this will be a memory.",
        "You are stronger than this moment.",
        "Breathe. You've got this.",
        "Your heart is strong. It's doing its job.",
        "Panic attacks are uncomfortable, never dangerous.",
        "You don't have to fight this. Just let it pass through you.",
        "Your body is trying to protect you. Thank it, then let go.",
        "This is just adrenaline. It has an expiration time.",
        "You've been here before. You know how it ends — you're fine.",
        "Right now, name one thing you're grateful for.",
        "Put your hand on your chest. Feel your heartbeat. You're alive and safe.",
        "This panic attack has a timer. It physically cannot last forever.",
        "You are not going crazy. This is a well-understood biological response.",
        "The worst that can happen is discomfort. You can handle discomfort.",
        "Float through it. Don't fight. Just float.",
        "Your body will calm itself. It's designed to.",
        "Think of the last time this happened. You survived. You'll survive this too.",
        "After this passes, you'll feel relief. That relief is coming."
    ]
}

enum TriggerTags {
    static let all = ["Work", "Social", "Health worry", "Caffeine", "Poor sleep", "Driving", "Public place", "Night/bedtime", "News/media", "Unknown", "Custom"]
}

enum TechniqueOptions {
    static let all = ["Breathing", "Grounding", "Cold exposure", "Reassurance cards", "Body scan", "Calling someone", "Situation guide", "Other"]
}

enum DurationOptions {
    static let minutes = [5, 10, 15, 20, 30, 60]
}

enum SessionDurationOptions {
    static let seconds = [180, 300, 600]
    static func label(for sec: Int) -> String {
        "\(sec / 60) min"
    }
}

enum CompanionMessages {
    static func message(daysSinceLastAttack: Int?, sessionCount: Int) -> String {
        let messages: [String] = {
            var m = [
                "Rough day? I'm right here.",
                "Remember: you've survived 100% of your worst days.",
                "Just checking in. How are you today?",
                "Fun fact: slow exhales activate your vagus nerve. Science is cool.",
                "You're doing great. One breath at a time."
            ]
            if let days = daysSinceLastAttack, days > 0 {
                m.append("Hey, you haven't logged an attack in \(days) day\(days == 1 ? "" : "s"). That's progress.")
            }
            if sessionCount > 0 {
                m.append("You've used PanicPal \(sessionCount) time\(sessionCount == 1 ? "" : "s"). You're building a toolkit.")
            }
            return m
        }()
        return messages.randomElement() ?? "You've got this."
    }
}
