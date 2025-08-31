import SwiftUI
import UserNotifications

struct HabitNotification: Codable, Identifiable {
    var id = UUID()
    var habitName: String
    var time: String
    var message: String
    var isEnabled: Bool
    var days: [Int] // 1 = Sunday, 2 = Monday, etc.
}

struct NotificationsSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @AppStorage("dailyReminderEnabled") private var dailyReminderEnabled = false
    @AppStorage("reminderTime") private var reminderTimeString = "09:00"
    @AppStorage("habitNotifications") private var habitNotificationsData = Data()
    @State private var reminderTime = Date()
    @State private var showingPermissionAlert = false
    @State private var habitNotifications: [HabitNotification] = []
    @State private var showingAddNotification = false
    @State private var editingNotification: HabitNotification?
    
    var body: some View {
        NavigationView {
            ZStack {
                (colorScheme == .dark ? Color(UIColor.systemBackground) : Color.premiumGray6)
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
                                    .fill(colorScheme == .dark ? Color(UIColor.secondarySystemBackground) : Color.white)
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
                                        .fill(colorScheme == .dark ? Color(UIColor.secondarySystemBackground) : Color.white)
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
                                        .fill(colorScheme == .dark ? Color(UIColor.secondarySystemBackground) : Color.white)
                                )
                            }
                            .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                        
                        // Multiple habit notifications
                        habitNotificationsSection
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
                loadHabitNotifications()
            }
            .sheet(isPresented: $showingAddNotification) {
                AddHabitNotificationView(notifications: $habitNotifications, onSave: saveHabitNotifications)
            }
            .sheet(item: $editingNotification) { notification in
                EditHabitNotificationView(notification: notification, notifications: $habitNotifications, onSave: saveHabitNotifications)
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
        content.title = "Time to log your wins! 🔥"
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
    
    // MARK: - Habit Notifications Section
    @ViewBuilder
    private var habitNotificationsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("HABIT REMINDERS")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.premiumGray3)
                    .tracking(1)
                
                Spacer()
                
                Button {
                    showingAddNotification = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.premiumIndigo)
                }
            }
            
            if habitNotifications.isEmpty {
                Text("Add reminders for specific habits")
                    .font(.system(size: 14))
                    .foregroundColor(.premiumGray4)
                    .padding(.vertical, 8)
            } else {
                VStack(spacing: 12) {
                    ForEach(habitNotifications) { notification in
                        HabitNotificationRow(
                            notification: notification,
                            onToggle: { toggleHabitNotification(notification) },
                            onEdit: { editingNotification = notification },
                            onDelete: { deleteHabitNotification(notification) }
                        )
                    }
                }
            }
        }
    }
    
    private func loadHabitNotifications() {
        if let notifications = try? JSONDecoder().decode([HabitNotification].self, from: habitNotificationsData) {
            habitNotifications = notifications
        }
    }
    
    private func saveHabitNotifications() {
        if let data = try? JSONEncoder().encode(habitNotifications) {
            habitNotificationsData = data
        }
        scheduleHabitNotifications()
    }
    
    private func toggleHabitNotification(_ notification: HabitNotification) {
        if let index = habitNotifications.firstIndex(where: { $0.id == notification.id }) {
            habitNotifications[index].isEnabled.toggle()
            saveHabitNotifications()
        }
    }
    
    private func deleteHabitNotification(_ notification: HabitNotification) {
        habitNotifications.removeAll { $0.id == notification.id }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notification.id.uuidString])
        saveHabitNotifications()
    }
    
    private func scheduleHabitNotifications() {
        for notification in habitNotifications where notification.isEnabled {
            scheduleHabitNotification(notification)
        }
    }
    
    private func scheduleHabitNotification(_ notification: HabitNotification) {
        let content = UNMutableNotificationContent()
        content.title = "🔥 \(notification.habitName)"
        content.body = notification.message
        content.sound = .default
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        guard let date = formatter.date(from: notification.time) else { return }
        
        let components = Calendar.current.dateComponents([.hour, .minute], from: date)
        
        for day in notification.days {
            var dateComponents = DateComponents()
            dateComponents.hour = components.hour
            dateComponents.minute = components.minute
            dateComponents.weekday = day
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let request = UNNotificationRequest(
                identifier: "\(notification.id.uuidString)-\(day)",
                content: content,
                trigger: trigger
            )
            
            UNUserNotificationCenter.current().add(request)
        }
    }
}

// MARK: - Habit Notification Row
struct HabitNotificationRow: View {
    let notification: HabitNotification
    let onToggle: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(notification.habitName)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.premiumGray1)
                
                Text(notification.time + " • " + formatDays(notification.days))
                    .font(.system(size: 14))
                    .foregroundColor(.premiumGray3)
            }
            
            Spacer()
            
            Toggle("", isOn: .constant(notification.isEnabled))
                .tint(.premiumIndigo)
                .onTapGesture { onToggle() }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(colorScheme == .dark ? Color(UIColor.secondarySystemBackground) : Color.white)
        )
        .contextMenu {
            Button("Edit") { onEdit() }
            Button("Delete", role: .destructive) { onDelete() }
        }
    }
    
    private func formatDays(_ days: [Int]) -> String {
        let dayNames = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        if days.count == 7 {
            return "Every day"
        } else if days == [2, 3, 4, 5, 6] {
            return "Weekdays"
        } else if days == [1, 7] {
            return "Weekends"
        } else {
            return days.compactMap { day in
                guard day >= 1 && day <= 7 else { return nil }
                return dayNames[day - 1]
            }.joined(separator: ", ")
        }
    }
}

// MARK: - Add Habit Notification View
struct AddHabitNotificationView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @Binding var notifications: [HabitNotification]
    let onSave: () -> Void
    
    @State private var habitName = ""
    @State private var time = Date()
    @State private var message = ""
    @State private var selectedDays: Set<Int> = Set(1...7)
    
    private let encouragingMessages = [
        "Time to build momentum! 💪",
        "Your future self will thank you! 🌟",
        "Small steps, big wins! 🚀",
        "Keep the fire alive! 🔥",
        "You've got this! 💯",
        "Progress over perfection! ✨",
        "Every rep counts! 🎯",
        "Stay consistent, see results! 📈"
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                (colorScheme == .dark ? Color(UIColor.systemBackground) : Color.premiumGray6)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Mascot
                        MascotView(mood: .celebrating, size: 100)
                            .padding(.top)
                        
                        // Habit Name
                        VStack(alignment: .leading, spacing: 8) {
                            Text("HABIT NAME")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.premiumGray3)
                                .tracking(1)
                            
                            TextField("e.g., Morning Meditation", text: $habitName)
                                .font(.system(size: 16))
                                .foregroundColor(.primary)
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(UIColor.secondarySystemBackground))
                                )
                        }
                        
                        // Time Picker
                        VStack(alignment: .leading, spacing: 8) {
                            Text("REMINDER TIME")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.premiumGray3)
                                .tracking(1)
                            
                            DatePicker("", selection: $time, displayedComponents: .hourAndMinute)
                                .datePickerStyle(WheelDatePickerStyle())
                                .frame(height: 120)
                        }
                        
                        // Days Selection
                        VStack(alignment: .leading, spacing: 8) {
                            Text("REPEAT")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.premiumGray3)
                                .tracking(1)
                            
                            HStack(spacing: 8) {
                                ForEach([(1, "S"), (2, "M"), (3, "T"), (4, "W"), (5, "T"), (6, "F"), (7, "S")], id: \.0) { day, letter in
                                    Button {
                                        if selectedDays.contains(day) {
                                            selectedDays.remove(day)
                                        } else {
                                            selectedDays.insert(day)
                                        }
                                    } label: {
                                        Text(letter)
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(selectedDays.contains(day) ? .white : .premiumGray3)
                                            .frame(width: 40, height: 40)
                                            .background(
                                                Circle()
                                                    .fill(selectedDays.contains(day) ? Color.premiumIndigo : Color(UIColor.secondarySystemBackground))
                                            )
                                    }
                                }
                            }
                        }
                        
                        // Message
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("MESSAGE")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.premiumGray3)
                                    .tracking(1)
                                
                                Spacer()
                                
                                Button("Random") {
                                    message = encouragingMessages.randomElement() ?? ""
                                }
                                .font(.system(size: 12))
                                .foregroundColor(.premiumIndigo)
                            }
                            
                            TextField("Encouraging message...", text: $message)
                                .font(.system(size: 16))
                                .foregroundColor(.primary)
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(UIColor.secondarySystemBackground))
                                )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 32)
                }
            }
            .navigationTitle("Add Reminder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveNotification()
                    }
                    .disabled(habitName.isEmpty || selectedDays.isEmpty)
                }
            }
        }
    }
    
    private func saveNotification() {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        
        let notification = HabitNotification(
            habitName: habitName,
            time: formatter.string(from: time),
            message: message.isEmpty ? "Time to work on \(habitName)! 🔥" : message,
            isEnabled: true,
            days: Array(selectedDays).sorted()
        )
        
        notifications.append(notification)
        onSave()
        dismiss()
    }
}

// MARK: - Edit Habit Notification View
struct EditHabitNotificationView: View {
    let notification: HabitNotification
    @Binding var notifications: [HabitNotification]
    let onSave: () -> Void
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var habitName: String
    @State private var time: Date
    @State private var message: String
    @State private var selectedDays: Set<Int>
    
    init(notification: HabitNotification, notifications: Binding<[HabitNotification]>, onSave: @escaping () -> Void) {
        self.notification = notification
        self._notifications = notifications
        self.onSave = onSave
        
        _habitName = State(initialValue: notification.habitName)
        _message = State(initialValue: notification.message)
        _selectedDays = State(initialValue: Set(notification.days))
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        _time = State(initialValue: formatter.date(from: notification.time) ?? Date())
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                (colorScheme == .dark ? Color(UIColor.systemBackground) : Color.premiumGray6)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Mascot
                        MascotView(mood: .neutral, size: 100)
                            .padding(.top)
                        
                        // Habit Name
                        VStack(alignment: .leading, spacing: 8) {
                            Text("HABIT NAME")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.premiumGray3)
                                .tracking(1)
                            
                            TextField("Habit name", text: $habitName)
                                .font(.system(size: 16))
                                .foregroundColor(.primary)
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(UIColor.secondarySystemBackground))
                                )
                        }
                        
                        // Time Picker
                        VStack(alignment: .leading, spacing: 8) {
                            Text("REMINDER TIME")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.premiumGray3)
                                .tracking(1)
                            
                            DatePicker("", selection: $time, displayedComponents: .hourAndMinute)
                                .datePickerStyle(WheelDatePickerStyle())
                                .frame(height: 120)
                        }
                        
                        // Days Selection
                        VStack(alignment: .leading, spacing: 8) {
                            Text("REPEAT")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.premiumGray3)
                                .tracking(1)
                            
                            HStack(spacing: 8) {
                                ForEach([(1, "S"), (2, "M"), (3, "T"), (4, "W"), (5, "T"), (6, "F"), (7, "S")], id: \.0) { day, letter in
                                    Button {
                                        if selectedDays.contains(day) {
                                            selectedDays.remove(day)
                                        } else {
                                            selectedDays.insert(day)
                                        }
                                    } label: {
                                        Text(letter)
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(selectedDays.contains(day) ? .white : .premiumGray3)
                                            .frame(width: 40, height: 40)
                                            .background(
                                                Circle()
                                                    .fill(selectedDays.contains(day) ? Color.premiumIndigo : Color(UIColor.secondarySystemBackground))
                                            )
                                    }
                                }
                            }
                        }
                        
                        // Message
                        VStack(alignment: .leading, spacing: 8) {
                            Text("MESSAGE")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.premiumGray3)
                                .tracking(1)
                            
                            TextField("Message", text: $message)
                                .font(.system(size: 16))
                                .foregroundColor(.primary)
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(UIColor.secondarySystemBackground))
                                )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 32)
                }
            }
            .navigationTitle("Edit Reminder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        updateNotification()
                    }
                }
            }
        }
    }
    
    private func updateNotification() {
        if let index = notifications.firstIndex(where: { $0.id == notification.id }) {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            
            notifications[index] = HabitNotification(
                id: notification.id,
                habitName: habitName,
                time: formatter.string(from: time),
                message: message,
                isEnabled: notification.isEnabled,
                days: Array(selectedDays).sorted()
            )
            
            onSave()
            dismiss()
        }
    }
}