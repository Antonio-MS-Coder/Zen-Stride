import SwiftUI
import UserNotifications

struct NotificationsSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("dailyReminderEnabled") private var dailyReminderEnabled = false
    @AppStorage("reminderTime") private var reminderTimeString = "09:00"
    @State private var reminderTime = Date()
    @State private var showingPermissionAlert = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.premiumGray6
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Daily reminder toggle
                        VStack(alignment: .leading, spacing: 16) {
                            Text("DAILY REMINDER")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.premiumGray3)
                                .tracking(1)
                            
                            VStack(spacing: 0) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Daily Reminder")
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(.premiumGray1)
                                        
                                        Text("Get reminded to log your wins")
                                            .font(.system(size: 14))
                                            .foregroundColor(.premiumGray3)
                                    }
                                    
                                    Spacer()
                                    
                                    Toggle("", isOn: $dailyReminderEnabled)
                                        .tint(.premiumIndigo)
                                        .onChange(of: dailyReminderEnabled) { _, newValue in
                                            if newValue {
                                                requestNotificationPermission()
                                            } else {
                                                cancelNotifications()
                                            }
                                        }
                                }
                                .padding(16)
                            }
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white)
                            )
                        }
                        
                        // Time picker
                        if dailyReminderEnabled {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("REMINDER TIME")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.premiumGray3)
                                    .tracking(1)
                                
                                VStack(spacing: 0) {
                                    DatePicker(
                                        "Reminder Time",
                                        selection: $reminderTime,
                                        displayedComponents: .hourAndMinute
                                    )
                                    .datePickerStyle(WheelDatePickerStyle())
                                    .labelsHidden()
                                    .frame(height: 150)
                                    .onChange(of: reminderTime) { _, newValue in
                                        let formatter = DateFormatter()
                                        formatter.dateFormat = "HH:mm"
                                        reminderTimeString = formatter.string(from: newValue)
                                        scheduleNotification()
                                    }
                                }
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.white)
                                )
                            }
                            .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                        
                        // Notification preview
                        if dailyReminderEnabled {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("PREVIEW")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.premiumGray3)
                                    .tracking(1)
                                
                                HStack(spacing: 12) {
                                    Image(systemName: "bell.badge.fill")
                                        .font(.system(size: 24))
                                        .foregroundColor(.premiumIndigo)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Time to log your wins!")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(.premiumGray1)
                                        
                                        Text("Your habits are waiting for you 💪")
                                            .font(.system(size: 13))
                                            .foregroundColor(.premiumGray3)
                                    }
                                    
                                    Spacer()
                                }
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.white)
                                )
                            }
                            .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 32)
                }
            }
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                loadReminderTime()
            }
            .alert("Notification Permission", isPresented: $showingPermissionAlert) {
                Button("Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                Button("Cancel", role: .cancel) {
                    dailyReminderEnabled = false
                }
            } message: {
                Text("Please enable notifications in Settings to receive daily reminders.")
            }
        }
    }
    
    private func loadReminderTime() {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        if let date = formatter.date(from: reminderTimeString) {
            reminderTime = date
        }
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            DispatchQueue.main.async {
                if granted {
                    scheduleNotification()
                } else {
                    showingPermissionAlert = true
                    dailyReminderEnabled = false
                }
            }
        }
    }
    
    private func scheduleNotification() {
        cancelNotifications()
        
        let content = UNMutableNotificationContent()
        content.title = "Time to log your wins!"
        content.body = "Your habits are waiting for you 💪"
        content.sound = .default
        
        let components = Calendar.current.dateComponents([.hour, .minute], from: reminderTime)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        let request = UNNotificationRequest(identifier: "dailyReminder", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    private func cancelNotifications() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["dailyReminder"])
    }
}