import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var contacts: [EmergencyContact]
    
    @State private var settings: UserSettings?
    @State private var showDeleteConfirm = false
    @State private var deleteText = ""
    @State private var showAddContact = false
    @State private var newContactName = ""
    @State private var newContactPhone = ""
    @State private var csvExport = ""
    @State private var showExport = false
    
    var body: some View {
        NavigationStack {
            Form {
                if let s = settings {
                    breathingSection(s)
                    hapticSection(s)
                    shakeSection(s)
                    companionSection(s)
                    checkInSection(s)
                    appearanceSection(s)
                    contactsSection
                    dataSection
                    aboutSection
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                    }
                }
            }
            .onAppear { loadSettings() }
            .sheet(isPresented: $showAddContact) { addContactSheet }
            .alert("Delete All Data", isPresented: $showDeleteConfirm) {
                TextField("Type DELETE to confirm", text: $deleteText)
                Button("Cancel", role: .cancel) { deleteText = "" }
                Button("Delete", role: .destructive) {
                    if deleteText == "DELETE" { clearAllData() }
                    deleteText = ""
                }
            } message: {
                Text("This cannot be undone. Type DELETE to confirm.")
            }
        }
    }
    
    private func breathingSection(_ s: UserSettings) -> some View {
        Section("Breathing") {
            Picker("Default Pattern", selection: Binding(
                get: { s.defaultPattern },
                set: { s.defaultPattern = $0; save() }
            )) {
                ForEach(BreathingPattern.allCases, id: \.self) { p in
                    Text(p.displayName).tag(p)
                }
            }
            
            Picker("Session Duration", selection: Binding(
                get: { s.sessionDurationSec },
                set: { s.sessionDurationSec = $0; save() }
            )) {
                ForEach(SessionDurationOptions.seconds, id: \.self) { sec in
                    Text(SessionDurationOptions.label(for: sec)).tag(sec)
                }
            }
            
            Toggle("Auto-Start on Launch", isOn: Binding(
                get: { s.autoStartBreathing },
                set: { s.autoStartBreathing = $0; save() }
            ))
        }
    }
    
    private func hapticSection(_ s: UserSettings) -> some View {
        Section("Haptics") {
            Toggle("Enable Haptic Breathing", isOn: Binding(
                get: { s.hapticEnabled },
                set: { s.hapticEnabled = $0; save() }
            ))
            
            if s.hapticEnabled {
                Picker("Intensity", selection: Binding(
                    get: { s.hapticIntensity },
                    set: { s.hapticIntensity = $0; save() }
                )) {
                    ForEach(HapticLevel.allCases, id: \.self) { l in
                        Text(l.displayName).tag(l)
                    }
                }
                .pickerStyle(.segmented)
            }
            
            Toggle("Sound During Breathing", isOn: Binding(
                get: { s.soundEnabled },
                set: { s.soundEnabled = $0; save() }
            ))
        }
    }
    
    private func shakeSection(_ s: UserSettings) -> some View {
        Section("Shake to SOS") {
            Toggle("Enable Shake to SOS", isOn: Binding(
                get: { s.shakeSOSEnabled },
                set: { s.shakeSOSEnabled = $0; save() }
            ))
            
            if s.shakeSOSEnabled {
                Picker("Sensitivity", selection: Binding(
                    get: { s.shakeSensitivity },
                    set: { s.shakeSensitivity = $0; save() }
                )) {
                    ForEach(ShakeSensitivity.allCases, id: \.self) { l in
                        Text(l.displayName).tag(l)
                    }
                }
                .pickerStyle(.segmented)
            }
        }
    }
    
    private func companionSection(_ s: UserSettings) -> some View {
        Section("Companion") {
            Toggle("Show Pal Mascot", isOn: Binding(
                get: { s.companionEnabled },
                set: { s.companionEnabled = $0; save() }
            ))
        }
    }
    
    private func checkInSection(_ s: UserSettings) -> some View {
        Section("Daily Check-In") {
            Toggle("Enable Reminder", isOn: Binding(
                get: { s.dailyCheckInEnabled },
                set: { newVal in
                    s.dailyCheckInEnabled = newVal
                    if newVal {
                        NotificationService.shared.requestPermission()
                        let time = s.dailyCheckInTime ?? Calendar.current.date(from: DateComponents(hour: 20)) ?? Date()
                        s.dailyCheckInTime = time
                        NotificationService.shared.scheduleDailyCheckIn(at: time)
                    } else {
                        NotificationService.shared.cancelDailyCheckIn()
                    }
                    save()
                }
            ))
            
            if s.dailyCheckInEnabled {
                DatePicker("Reminder Time", selection: Binding(
                    get: { s.dailyCheckInTime ?? Date() },
                    set: { s.dailyCheckInTime = $0; NotificationService.shared.scheduleDailyCheckIn(at: $0); save() }
                ), displayedComponents: .hourAndMinute)
            }
        }
    }
    
    private func appearanceSection(_ s: UserSettings) -> some View {
        Section("Appearance") {
            Picker("Theme", selection: Binding(
                get: { s.theme },
                set: { s.theme = $0; save() }
            )) {
                ForEach(AppTheme.allCases, id: \.self) { t in
                    Text(t.displayName).tag(t)
                }
            }
            .pickerStyle(.segmented)
        }
    }
    
    private var contactsSection: some View {
        Section("Emergency Contacts") {
            ForEach(contacts.sorted(by: { $0.sortOrder < $1.sortOrder })) { contact in
                HStack {
                    VStack(alignment: .leading) {
                        Text(contact.name).font(.headline)
                        Text(contact.phoneNumber).font(.subheadline).foregroundStyle(.secondary)
                    }
                    Spacer()
                }
            }
            .onDelete { indexSet in
                let sorted = contacts.sorted(by: { $0.sortOrder < $1.sortOrder })
                for index in indexSet {
                    modelContext.delete(sorted[index])
                }
                try? modelContext.save()
            }
            
            if contacts.count < 3 {
                Button("Add Contact") { showAddContact = true }
            }
        }
    }
    
    private var dataSection: some View {
        Section("Data Management") {
            ShareLink(item: SettingsViewModel().exportJournalCSV(context: modelContext)) {
                Label("Export Journal as CSV", systemImage: "square.and.arrow.up")
            }
            
            Button("Clear All Data", role: .destructive) {
                showDeleteConfirm = true
            }
        }
    }
    
    private var aboutSection: some View {
        Section("About") {
            HStack {
                Text("Version")
                Spacer()
                Text("1.0.0").foregroundStyle(.secondary)
            }
            Link("Privacy Policy", destination: URL(string: "https://tuhin-014.github.io/app-policies/panicpal/privacy-policy.html")!)
            HStack {
                Text("Contact")
                Spacer()
                Text("tuhin014@gmail.com").foregroundStyle(.secondary)
            }
        }
    }
    
    private var addContactSheet: some View {
        NavigationStack {
            Form {
                TextField("Name", text: $newContactName)
                TextField("Phone Number", text: $newContactPhone)
                    .keyboardType(.phonePad)
            }
            .navigationTitle("Add Contact")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { showAddContact = false; newContactName = ""; newContactPhone = "" }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        let contact = EmergencyContact(name: newContactName, phoneNumber: newContactPhone, sortOrder: contacts.count)
                        modelContext.insert(contact)
                        try? modelContext.save()
                        showAddContact = false
                        newContactName = ""
                        newContactPhone = ""
                    }
                    .disabled(newContactName.isEmpty || newContactPhone.isEmpty)
                }
            }
        }
    }
    
    private func loadSettings() {
        let descriptor = FetchDescriptor<UserSettings>()
        let results = (try? modelContext.fetch(descriptor)) ?? []
        if let s = results.first {
            settings = s
        } else {
            let s = UserSettings()
            modelContext.insert(s)
            try? modelContext.save()
            settings = s
        }
    }
    
    private func save() {
        try? modelContext.save()
    }
    
    private func clearAllData() {
        try? modelContext.delete(model: PanicEntry.self)
        try? modelContext.delete(model: BreathingSession.self)
        try? modelContext.delete(model: DailyCheckIn.self)
        try? modelContext.delete(model: FavoriteReassurance.self)
        try? modelContext.delete(model: LessonProgress.self)
        try? modelContext.save()
    }
}
