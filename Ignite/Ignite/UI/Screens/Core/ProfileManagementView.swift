import SwiftUI

struct ProfileManagementView: View {
    @EnvironmentObject var dataStore: IgniteDataStore
    @Environment(\.dismiss) private var dismiss
    @State private var showingAddHabit = false
    @State private var editingHabit: HabitModel?
    @State private var showingSettings = false
    
    // Settings states
    @State private var showingNotifications = false
    @State private var showingTheme = false
    @State private var showingHelp = false
    @State private var showingExport = false
    @State private var showingResetAlert = false
    @AppStorage("userName") private var userName = "Friend"
    @AppStorage("dailyReminderEnabled") private var dailyReminderEnabled = false
    @AppStorage("reminderTime") private var reminderTimeString = "09:00"
    @AppStorage("appTheme") private var appTheme = "system"
    
    var body: some View {
        NavigationView {
            ZStack {
                ThemeManager.shared.backgroundColor
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        // Profile header
                        profileHeaderSection
                        
                        // Habits management
                        habitsManagementSection
                        
                        // Settings
                        settingsSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 32)
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingAddHabit) {
                AddHabitView()
                    .environmentObject(dataStore)
            }
            .sheet(item: $editingHabit) { habit in
                EditHabitView(habit: habit)
                    .environmentObject(dataStore)
            }
            .sheet(isPresented: $showingNotifications) {
                NotificationsSettingsView()
            }
            .sheet(isPresented: $showingExport) {
                ExportDataView()
                    .environmentObject(dataStore)
            }
            .sheet(isPresented: $showingTheme) {
                ThemeSettingsView()
            }
            .sheet(isPresented: $showingHelp) {
                HelpSupportView()
            }
            .alert("Reset All Data?", isPresented: $showingResetAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    withAnimation {
                        dataStore.reset()
                    }
                }
            } message: {
                Text("This will delete all your habits and logged wins. This action cannot be undone.")
            }
        }
    }
    
    // MARK: - Profile Header
    private var profileHeaderSection: some View {
        VStack(spacing: 16) {
            // Avatar
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.adaptivePremiumIndigo, Color.adaptivePremiumTeal],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                
                Text(userName.prefix(1).uppercased())
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            
            // Name
            VStack(spacing: 4) {
                Text("Hello, \(userName)")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(ThemeManager.shared.primaryText)
                
                Text("\(dataStore.habits.count) active habits")
                    .font(.system(size: 16))
                    .foregroundColor(ThemeManager.shared.secondaryText)
            }
        }
    }
    
    // MARK: - Habits Management
    private var habitsManagementSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("MY HABITS")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(ThemeManager.shared.secondaryText)
                    .tracking(1)
                
                Spacer()
                
                Button {
                    showingAddHabit = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "plus")
                        Text("Add")
                    }
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color.adaptivePremiumIndigo)
                }
            }
            
            if dataStore.habits.isEmpty {
                emptyHabitsView
            } else {
                VStack(spacing: 12) {
                    ForEach(dataStore.habits) { habit in
                        HabitManagementCard(
                            habit: habit,
                            onEdit: {
                                editingHabit = habit
                            },
                            onDelete: {
                                deleteHabit(habit)
                            }
                        )
                    }
                }
            }
        }
    }
    
    // MARK: - Empty Habits View
    private var emptyHabitsView: some View {
        VStack(spacing: 16) {
            MascotView(mood: .neutral, size: 100)
            
            Text("No habits yet")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(ThemeManager.shared.primaryText)
            
            Button {
                showingAddHabit = true
            } label: {
                Text("Create First Habit")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        Capsule()
                            .fill(Color.adaptivePremiumIndigo)
                    )
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(ThemeManager.shared.cardBackground)
        )
    }
    
    // MARK: - Settings Section
    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("SETTINGS")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(ThemeManager.shared.secondaryText)
                .tracking(1)
            
            VStack(spacing: 0) {
                SettingsRow(
                    icon: "bell",
                    title: "Reminders",
                    subtitle: dailyReminderEnabled ? "On at \(reminderTimeString)" : "Off",
                    action: {
                        showingNotifications = true
                    }
                )
                
                Divider()
                    .padding(.leading, 56)
                
                SettingsRow(
                    icon: "square.and.arrow.up",
                    title: "Export Data",
                    subtitle: "CSV format",
                    action: {
                        showingExport = true
                    }
                )
                
                Divider()
                    .padding(.leading, 56)
                
                SettingsRow(
                    icon: "moon",
                    title: "Theme",
                    subtitle: appTheme.capitalized,
                    action: {
                        showingTheme = true
                    }
                )
                
                Divider()
                    .padding(.leading, 56)
                
                SettingsRow(
                    icon: "questionmark.circle",
                    title: "Help & Support",
                    action: {
                        showingHelp = true
                    }
                )
                
                Divider()
                    .padding(.leading, 56)
                
                SettingsRow(
                    icon: "arrow.counterclockwise",
                    title: "Reset Data",
                    subtitle: "Clear all progress",
                    isDestructive: true,
                    action: {
                        showingResetAlert = true
                    }
                )
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(ThemeManager.shared.cardBackground)
            )
        }
    }
    
    // MARK: - Helpers
    private func deleteHabit(_ habit: HabitModel) {
        withAnimation {
            dataStore.removeHabit(habit)
        }
    }
}

// MARK: - Habit Management Card
struct HabitManagementCard: View {
    let habit: HabitModel
    let onEdit: () -> Void
    let onDelete: () -> Void
    @State private var showingDeleteAlert = false
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(habit.color.opacity(0.1))
                    .frame(width: 48, height: 48)
                
                HabitIconView(
                    icon: habit.icon,
                    size: 22,
                    color: habit.color,
                    isComplete: true
                )
            }
            
            // Name
            VStack(alignment: .leading, spacing: 4) {
                Text(habit.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(ThemeManager.shared.primaryText)
                
                // Show tracking type info
                if habit.trackingType == .count, let target = habit.targetValue {
                    Text("\(Int(target)) \(habit.unit ?? "") daily")
                        .font(.system(size: 14))
                        .foregroundColor(ThemeManager.shared.secondaryText)
                } else if habit.trackingType == .goal, let target = habit.targetValue {
                    Text("Goal: \(Int(target)) \(habit.unit ?? "")")
                        .font(.system(size: 14))
                        .foregroundColor(ThemeManager.shared.secondaryText)
                } else if habit.trackingType == .check {
                    Text("Daily check")
                        .font(.system(size: 14))
                        .foregroundColor(ThemeManager.shared.secondaryText)
                }
            }
            
            Spacer()
            
            // Actions
            HStack(spacing: 16) {
                Button {
                    onEdit()
                } label: {
                    Image(systemName: "pencil")
                        .font(.system(size: 18))
                        .foregroundColor(ThemeManager.shared.secondaryText)
                }
                
                Button {
                    showingDeleteAlert = true
                } label: {
                    Image(systemName: "trash")
                        .font(.system(size: 18))
                        .foregroundColor(.red.opacity(0.6))
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(ThemeManager.shared.cardBackground)
        )
        .alert("Delete Habit?", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                onDelete()
            }
        } message: {
            Text("This will delete '\(habit.name)' but keep your logged wins.")
        }
    }
}

// MARK: - Settings Row
struct SettingsRow: View {
    let icon: String
    let title: String
    var subtitle: String? = nil
    var isDestructive: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(isDestructive ? .red.opacity(0.6) : ThemeManager.shared.secondaryText)
                    .frame(width: 24, height: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 16))
                        .foregroundColor(isDestructive ? .red : ThemeManager.shared.primaryText)
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.system(size: 13))
                            .foregroundColor(isDestructive ? .red.opacity(0.6) : ThemeManager.shared.secondaryText)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(ThemeManager.shared.tertiaryText)
            }
            .padding(16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}


