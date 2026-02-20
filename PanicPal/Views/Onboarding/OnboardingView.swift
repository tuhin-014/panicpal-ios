import SwiftUI
import SwiftData

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var isCompleted: Bool
    
    @State private var currentPage = 0
    @State private var selectedPattern: BreathingPattern = .fourSevenEight
    @State private var contactName = ""
    @State private var contactPhone = ""
    @State private var hapticEnabled = true
    
    var body: some View {
        TabView(selection: $currentPage) {
            welcomePage.tag(0)
            disclaimerPage.tag(1)
            setupPage.tag(2)
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .ignoresSafeArea()
    }
    
    private var welcomePage: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "heart.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(AppColors.deepTeal)
            
            Text("PanicPal")
                .font(.largeTitle.weight(.bold))
                .foregroundStyle(AppColors.deepTeal)
            
            Text("is here when you need it most")
                .font(.title3)
                .foregroundStyle(.secondary)
            
            Spacer()
            
            Button("Next") {
                withAnimation { currentPage = 1 }
            }
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(AppColors.deepTeal)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal, 40)
            
            Button("Skip") { completeOnboarding() }
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(.bottom, 40)
        }
    }
    
    private var disclaimerPage: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "info.circle.fill")
                .font(.system(size: 50))
                .foregroundStyle(AppColors.deepTeal)
            
            Text("Important")
                .font(.title.weight(.semibold))
                .foregroundStyle(AppColors.deepTeal)
            
            Text("PanicPal provides breathing exercises, grounding techniques, and educational content for general wellness. It is not a medical device and does not diagnose, treat, or cure any condition. If you are experiencing a medical emergency, call 911. Always consult a healthcare professional for mental health concerns.")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 30)
            
            Spacer()
            
            Button("Next") {
                withAnimation { currentPage = 2 }
            }
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(AppColors.deepTeal)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal, 40)
            
            Button("Skip") { completeOnboarding() }
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(.bottom, 40)
        }
    }
    
    private var setupPage: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Text("Quick Setup")
                .font(.title.weight(.semibold))
                .foregroundStyle(AppColors.deepTeal)
            
            Text("All optional — you can change these later")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Default Breathing Pattern")
                    .font(.headline)
                Picker("Pattern", selection: $selectedPattern) {
                    ForEach(BreathingPattern.allCases, id: \.self) { pattern in
                        Text(pattern.displayName).tag(pattern)
                    }
                }
                .pickerStyle(.segmented)
            }
            .padding(.horizontal, 30)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Emergency Contact (optional)")
                    .font(.headline)
                TextField("Name", text: $contactName)
                    .textFieldStyle(.roundedBorder)
                TextField("Phone Number", text: $contactPhone)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.phonePad)
            }
            .padding(.horizontal, 30)
            
            Toggle("Enable Haptic Breathing", isOn: $hapticEnabled)
                .padding(.horizontal, 30)
                .tint(AppColors.deepTeal)
            
            Spacer()
            
            Button("I Understand — Get Started") {
                completeOnboarding()
            }
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(AppColors.deepTeal)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
        }
    }
    
    private func completeOnboarding() {
        let descriptor = FetchDescriptor<UserSettings>()
        let results = (try? modelContext.fetch(descriptor)) ?? []
        let settings = results.first ?? UserSettings()
        if results.isEmpty { modelContext.insert(settings) }
        
        settings.defaultPattern = selectedPattern
        settings.hapticEnabled = hapticEnabled
        settings.onboardingCompleted = true
        
        if !contactName.isEmpty && !contactPhone.isEmpty {
            let contact = EmergencyContact(name: contactName, phoneNumber: contactPhone, sortOrder: 0)
            modelContext.insert(contact)
        }
        
        try? modelContext.save()
        isCompleted = true
    }
}
