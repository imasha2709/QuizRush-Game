import SwiftUI

struct SettingsView: View {

    
    @AppStorage("isDarkMode") private var isDarkMode = false

    
    @State private var dailyReminderEnabled = false
    @State private var dailyReminderTime = Date()
    
    @State private var mailReminderEnabled = false
    @State private var mailReminderTime = Date()
    
    @State private var timerReminderEnabled = false
    @State private var timerReminderTime = Date()
    
    @State private var showResetAlert = false

    var body: some View {
        NavigationStack {
            Form {
              
                themeSection
                
                notificationSection
                statisticsSection
                aboutSection
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    ShareLink(
                        item: shareString,
                        subject: Text("App Preferences Summary"),
                        preview: SharePreview(
                            "My Game Hub Settings",
                            image: Image(systemName: "gearshape.fill")
                        )
                    ) {
                        Label("Share Settings", systemImage: "square.and.arrow.up")
                    }
                }
            }
        }
    }
    
    // MARK: - Subviews
    
    // NEW: Theme Toggle Section View
    private var themeSection: some View {
        Section("Appearance") {
            Toggle(isOn: $isDarkMode) {
                Label {
                    Text("Dark Mode")
                } icon: {
                    Image(systemName: isDarkMode ? "moon.stars.fill" : "sun.max.fill")
                        .foregroundColor(isDarkMode ? .purple : .orange)
                }
            }
        }
    }
    
    private var shareString: String {
        """
        ⚙️ Game Hub Settings Configuration:
        
        • Theme Mode: \(isDarkMode ? "Dark Theme" : "Light Theme")
        • Daily Reminder: \(dailyReminderEnabled ? "Enabled" : "Disabled")
        • Mail Reminder: \(mailReminderEnabled ? "Enabled" : "Disabled")
        • Timer Reminder: \(timerReminderEnabled ? "Enabled" : "Disabled")
        
        Shared directly from my iPhone! 🚀
        """
    }
    
    private var notificationSection: some View {
        Section("Notifications") {
            Group {
                Toggle("🎮 Daily Game Reminder", isOn: $dailyReminderEnabled)
                    .onChange(of: dailyReminderEnabled) { _, enabled in
                        if enabled {
                            NotificationService.shared.requestPermission()
                            NotificationService.shared.scheduleDailyReminder(at: dailyReminderTime)
                        } else {
                            NotificationService.shared.cancelReminder(identifier: "dailyReminder")
                        }
                    }

                if dailyReminderEnabled {
                    DatePicker("Game Time", selection: $dailyReminderTime, displayedComponents: .hourAndMinute)
                        .onChange(of: dailyReminderTime) { _, newValue in
                            NotificationService.shared.scheduleDailyReminder(at: newValue)
                        }
                }
            }
            
            Group {
                Toggle("📬 Mail Reminder", isOn: $mailReminderEnabled)
                    .onChange(of: mailReminderEnabled) { _, enabled in
                        if enabled {
                            NotificationService.shared.requestPermission()
                            NotificationService.shared.scheduleMailReminder(at: mailReminderTime)
                        } else {
                            NotificationService.shared.cancelReminder(identifier: "mailReminder")
                        }
                    }

                if mailReminderEnabled {
                    DatePicker("Mail Check Time", selection: $mailReminderTime, displayedComponents: .hourAndMinute)
                        .onChange(of: mailReminderTime) { _, newValue in
                            NotificationService.shared.scheduleMailReminder(at: newValue)
                        }
                }
            }
            
            Group {
                Toggle("⏰ Timer Reminder", isOn: $timerReminderEnabled)
                    .onChange(of: timerReminderEnabled) { _, enabled in
                        if enabled {
                            NotificationService.shared.requestPermission()
                            NotificationService.shared.scheduleTimerReminder(at: timerReminderTime)
                        } else {
                            NotificationService.shared.cancelReminder(identifier: "timerReminder")
                        }
                    }

                if timerReminderEnabled {
                    DatePicker("Timer Target", selection: $timerReminderTime, displayedComponents: .hourAndMinute)
                        .onChange(of: timerReminderTime) { _, newValue in
                            NotificationService.shared.scheduleTimerReminder(at: newValue)
                        }
                }
            }
        }
    }

    private var statisticsSection: some View {
        Section("Statistics") {
            Button(role: .destructive) {
                showResetAlert = true
            } label: {
                Label("Reset All Statistics", systemImage: "trash")
            }
        }
        .alert("Reset Statistics?", isPresented: $showResetAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Reset", role: .destructive) {
                GameSessionManager.shared.clearHistory()
            }
        } message: {
            Text("This will permanently delete all saved game history.")
        }
    }

    private var aboutSection: some View {
        Section("About") {
            HStack {
                Text("Application")
                Spacer()
                Text("Mini Game Hub").foregroundStyle(.secondary)
            }

            HStack {
                Text("Developer")
                Spacer()
                Text("Imasha Chandramali").foregroundStyle(.secondary)
            }

            HStack {
                Text("Version")
                Spacer()
                Text("1.0").foregroundStyle(.secondary)
            }

            HStack {
                Text("Platform")
                Spacer()
                Text("SwiftUI").foregroundStyle(.secondary)
            }
        }
    }
}
