import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \PanicEntry.timestamp, order: .reverse) private var entries: [PanicEntry]
    @Query private var sessions: [BreathingSession]
    @Query private var settingsResults: [UserSettings]
    
    @State private var showBreathing = false
    @State private var showGrounding = false
    @State private var showColdExposure = false
    @State private var showReassurance = false
    @State private var showBodyScan = false
    @State private var showSituations = false
    @State private var showEducation = false
    @State private var showEmergency = false
    @State private var showJournal = false
    @State private var showSettings = false
    @State private var showCheckIn = false
    
    private var settings: UserSettings? { settingsResults.first }
    
    private var daysSinceLastAttack: Int? {
        guard let last = entries.first else { return nil }
        return Calendar.current.dateComponents([.day], from: last.timestamp, to: Date()).day
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Top bar
                HStack {
                    Text("PanicPal")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(AppColors.deepTeal)
                    
                    Spacer()
                    
                    Button { showJournal = true } label: {
                        Image(systemName: "book.closed")
                            .font(.title3)
                            .foregroundStyle(AppColors.deepTeal)
                    }
                    
                    Button { showSettings = true } label: {
                        Image(systemName: "gearshape")
                            .font(.title3)
                            .foregroundStyle(AppColors.deepTeal)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
                
                // Companion
                if settings?.companionEnabled != false {
                    CompanionView(message: CompanionMessages.message(
                        daysSinceLastAttack: daysSinceLastAttack,
                        sessionCount: sessions.count
                    ))
                    .padding(.horizontal)
                }
                
                // Main 4 buttons — big touch targets
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                    ToolButton(icon: "lungs.fill", label: "Breathe", color: AppColors.deepTeal) {
                        showBreathing = true
                    }
                    ToolButton(icon: "hand.raised.fill", label: "Ground", color: AppColors.deepTeal) {
                        showGrounding = true
                    }
                    ToolButton(icon: "snowflake", label: "Cool Down", color: AppColors.deepTeal) {
                        showColdExposure = true
                    }
                    ToolButton(icon: "quote.bubble.fill", label: "Reassure", color: AppColors.deepTeal) {
                        showReassurance = true
                    }
                }
                .padding(.horizontal)
                
                // Secondary tools
                VStack(spacing: 10) {
                    SecondaryToolButton(icon: "figure.mind.and.body", label: "Body Scan") {
                        showBodyScan = true
                    }
                    SecondaryToolButton(icon: "book.fill", label: "Situations") {
                        showSituations = true
                    }
                    SecondaryToolButton(icon: "graduationcap.fill", label: "Learn") {
                        showEducation = true
                    }
                }
                .padding(.horizontal)
                
                // Emergency bar
                HStack(spacing: 12) {
                    Button {
                        showEmergency = true
                    } label: {
                        HStack {
                            Image(systemName: "phone.fill")
                            Text("Emergency")
                                .fontWeight(.medium)
                        }
                        .font(.subheadline)
                        .foregroundStyle(AppColors.deepTeal)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(AppColors.deepTeal.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                    Button {
                        if let url = URL(string: "tel://911") {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                            Text("Call 911")
                                .fontWeight(.bold)
                        }
                        .font(.subheadline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(AppColors.warmCoral)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
        }
        .background(AppColors.safetyWhite)
        .fullScreenCover(isPresented: $showBreathing) {
            BreathingView(
                initialPattern: settings?.defaultPattern ?? .fourSevenEight,
                sessionDuration: Double(settings?.sessionDurationSec ?? 300),
                hapticEnabled: settings?.hapticEnabled ?? true,
                hapticIntensity: settings?.hapticIntensity ?? .medium
            )
        }
        .fullScreenCover(isPresented: $showGrounding) { GroundingView() }
        .fullScreenCover(isPresented: $showColdExposure) { ColdExposureView() }
        .fullScreenCover(isPresented: $showReassurance) { ReassuranceView() }
        .fullScreenCover(isPresented: $showBodyScan) { BodyScanView() }
        .fullScreenCover(isPresented: $showSituations) { SituationGuidesView() }
        .fullScreenCover(isPresented: $showEducation) { EducationView() }
        .fullScreenCover(isPresented: $showEmergency) { EmergencyView() }
        .sheet(isPresented: $showJournal) { JournalListView() }
        .sheet(isPresented: $showSettings) { SettingsView() }
        .sheet(isPresented: $showCheckIn) { DailyCheckInView() }
    }
}

struct ToolButton: View {
    let icon: String
    let label: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 32))
                    .foregroundStyle(color)
                Text(label)
                    .font(.headline)
                    .foregroundStyle(color)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 110)
            .background(color.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
}

struct SecondaryToolButton: View {
    let icon: String
    let label: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(AppColors.deepTeal)
                    .frame(width: 30)
                Text(label)
                    .font(.body.weight(.medium))
                    .foregroundStyle(.primary)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: .black.opacity(0.04), radius: 4)
        }
    }
}
