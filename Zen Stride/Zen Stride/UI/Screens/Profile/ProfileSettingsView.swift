import SwiftUI

struct ProfileSettingsView: View {
    @EnvironmentObject var dataStore: ZenStrideDataStore
    @State private var userName = "Friend"
    @State private var dailyGoal = 5
    @State private var reminderEnabled = true
    @State private var reminderTime = Date()
    @State private var selectedTheme = 0
    @State private var showingEditHabits = false
    @State private var profileScale = 0.9
    @State private var statsAppeared = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color.premiumGray6
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: .spacing28) {
                        // Header
                        profileHeader
                        
                        // Stats Overview
                        statsOverview
                        
                        // Quick Settings
                        settingsSection
                        
                        // Habit Customization
                        habitsSection
                        
                        // Mindset & Motivation
                        motivationSection
                    }
                    .padding(.horizontal, .spacing20)
                    .padding(.top, .spacing24)
                    .padding(.bottom, 100)
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    // MARK: - Profile Header
    private var profileHeader: some View {
        VStack(spacing: .spacing16) {
            // Profile Avatar
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.premiumIndigo, Color.premiumTeal],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                
                Text(userName.prefix(1).uppercased())
                    .font(.system(size: 36, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
            }
            .scaleEffect(profileScale)
            .onAppear {
                withAnimation(.premiumBounce.delay(0.1)) {
                    profileScale = 1.0
                }
            }
            
            // Greeting
            VStack(spacing: .spacing4) {
                Text("Hello, \(userName)")
                    .font(.premiumTitle2)
                    .foregroundColor(.premiumGray1)
                
                Text("\(dataStore.streakDays) day streak 🔥")
                    .font(.premiumCallout)
                    .foregroundColor(.premiumCoral)
            }
        }
    }
    
    // MARK: - Stats Overview
    private var statsOverview: some View {
        VStack(alignment: .leading, spacing: .spacing16) {
            Text("YOUR JOURNEY")
                .font(.premiumCaption1)
                .foregroundColor(.premiumGray3)
                .tracking(1.2)
            
            HStack(spacing: .spacing12) {
                StatBlock(
                    value: "\(dataStore.allWins.count)",
                    label: "Total Wins",
                    icon: "star.fill",
                    color: .premiumAmber
                )
                
                StatBlock(
                    value: "\(dataStore.streakDays)",
                    label: "Day Streak",
                    icon: "flame.fill",
                    color: .premiumCoral
                )
                
                StatBlock(
                    value: "\(Int(dataStore.getMonthlyTrend() * 100))%",
                    label: "Improvement",
                    icon: "arrow.up.forward",
                    color: .premiumMint
                )
            }
            .onAppear {
                withAnimation(.premiumSpring.delay(0.2)) {
                    statsAppeared = true
                }
            }
            .opacity(statsAppeared ? 1 : 0)
            .offset(y: statsAppeared ? 0 : 20)
        }
    }
    
    // MARK: - Settings Section
    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: .spacing16) {
            Text("PREFERENCES")
                .font(.premiumCaption1)
                .foregroundColor(.premiumGray3)
                .tracking(1.2)
            
            settingsCard
        }
    }
    
    private var settingsCard: some View {
        VStack(spacing: 0) {
            dailyGoalRow
            
            Divider()
                .padding(.horizontal, .spacing16)
            
            reminderRow
            
            if reminderEnabled {
                Divider()
                    .padding(.horizontal, .spacing16)
                
                reminderTimeRow
            }
        }
        .background(
            RoundedRectangle(cornerRadius: .radiusL)
                .fill(Color.white)
        )
        .premiumShadowXS()
    }
    
    private var dailyGoalRow: some View {
        SettingRow(
            icon: "target",
            title: "Daily Goal",
            value: "\(dailyGoal) wins"
        ) {
            HStack {
                ForEach([3, 5, 7, 10], id: \.self) { goal in
                    dailyGoalButton(for: goal)
                }
            }
        }
    }
    
    private func dailyGoalButton(for goal: Int) -> some View {
        Button {
            withAnimation(.premiumSmooth) {
                dailyGoal = goal
                hapticFeedback(.light)
            }
        } label: {
            Text("\(goal)")
                .font(.premiumCallout)
                .foregroundColor(dailyGoal == goal ? .white : .premiumGray2)
                .frame(width: 40, height: 32)
                .background(
                    RoundedRectangle(cornerRadius: .radiusS)
                        .fill(dailyGoal == goal ? Color.premiumIndigo : Color.premiumGray5.opacity(0.3))
                )
        }
    }
    
    private var reminderRow: some View {
        SettingRow(
            icon: "bell.fill",
            title: "Daily Reminder",
            value: reminderEnabled ? "On" : "Off"
        ) {
            Toggle("", isOn: $reminderEnabled)
                .labelsHidden()
                .onChange(of: reminderEnabled) {
                    hapticFeedback(.light)
                }
        }
    }
    
    private var reminderTimeRow: some View {
        SettingRow(
            icon: "clock.fill",
            title: "Reminder Time",
            value: timeString(from: reminderTime)
        ) {
            DatePicker("", selection: $reminderTime, displayedComponents: .hourAndMinute)
                .labelsHidden()
        }
    }
    
    // MARK: - Habits Section
    private var habitsSection: some View {
        VStack(alignment: .leading, spacing: .spacing16) {
            HStack {
                Text("YOUR HABITS")
                    .font(.premiumCaption1)
                    .foregroundColor(.premiumGray3)
                    .tracking(1.2)
                
                Spacer()
                
                Button {
                    showingEditHabits = true
                } label: {
                    Text("Edit")
                        .font(.premiumCallout)
                        .foregroundColor(.premiumIndigo)
                }
            }
            
            // Quick habit toggles
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: .spacing12) {
                ForEach(defaultHabits, id: \.name) { habit in
                    HabitToggle(habit: habit)
                }
            }
        }
    }
    
    // MARK: - Motivation Section
    private var motivationSection: some View {
        VStack(alignment: .leading, spacing: .spacing16) {
            Text("DAILY MOTIVATION")
                .font(.premiumCaption1)
                .foregroundColor(.premiumGray3)
                .tracking(1.2)
            
            VStack(alignment: .leading, spacing: .spacing12) {
                Text("\"Small daily improvements add up to staggering results\"")
                    .font(.premiumHeadline)
                    .foregroundColor(.premiumGray1)
                    .italic()
                
                Text("— James Clear")
                    .font(.premiumCaption1)
                    .foregroundColor(.premiumGray3)
            }
            .padding(.spacing20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: .radiusL)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.premiumIndigo.opacity(0.05),
                                Color.premiumTeal.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: .radiusL)
                    .stroke(Color.premiumIndigo.opacity(0.1), lineWidth: 1)
            )
        }
    }
    
    // MARK: - Helpers
    private func timeString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private let defaultHabits = [
        (name: "Reading", icon: "book.fill", color: Color.premiumIndigo),
        (name: "Exercise", icon: "figure.run", color: Color.premiumTeal),
        (name: "Water", icon: "drop.fill", color: Color.premiumBlue),
        (name: "Meditation", icon: "brain.head.profile", color: Color.premiumMint),
        (name: "Writing", icon: "pencil", color: Color.premiumCoral),
        (name: "Steps", icon: "figure.walk", color: Color.premiumAmber)
    ]
}

// MARK: - Stat Block
struct StatBlock: View {
    let value: String
    let label: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: .spacing8) {
            HStack(spacing: .spacing4) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(color)
                
                Text(value)
                    .font(.premiumTitle3)
                    .foregroundColor(.premiumGray1)
            }
            
            Text(label)
                .font(.premiumCaption2)
                .foregroundColor(.premiumGray3)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, .spacing12)
        .background(
            RoundedRectangle(cornerRadius: .radiusM)
                .fill(Color.white)
        )
        .premiumShadowXS()
    }
}

// MARK: - Setting Row
struct SettingRow<Content: View>: View {
    let icon: String
    let title: String
    let value: String
    let content: () -> Content
    
    var body: some View {
        HStack(spacing: .spacing16) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(.premiumIndigo)
                .frame(width: 24)
            
            Text(title)
                .font(.premiumCallout)
                .foregroundColor(.premiumGray1)
            
            Spacer()
            
            content()
        }
        .padding(.spacing16)
    }
}

// MARK: - Habit Toggle
struct HabitToggle: View {
    let habit: (name: String, icon: String, color: Color)
    @State private var isEnabled = true
    @State private var isPressed = false
    
    var body: some View {
        Button {
            withAnimation(.premiumBounce) {
                isEnabled.toggle()
            }
            hapticFeedback(.light)
            
            withAnimation(.premiumQuick) {
                isPressed = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.premiumQuick) {
                    isPressed = false
                }
            }
        } label: {
            VStack(spacing: .spacing8) {
                ZStack {
                    Circle()
                        .fill(isEnabled ? habit.color.opacity(0.15) : Color.premiumGray5.opacity(0.3))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: habit.icon)
                        .font(.system(size: 20))
                        .foregroundColor(isEnabled ? habit.color : .premiumGray4)
                }
                
                Text(habit.name)
                    .font(.premiumCaption2)
                    .foregroundColor(isEnabled ? .premiumGray2 : .premiumGray4)
            }
            .scaleEffect(isPressed ? 0.9 : (isEnabled ? 1.0 : 0.95))
            .rotation3DEffect(
                .degrees(isPressed ? 5 : 0),
                axis: (x: 1, y: 0, z: 0)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Haptic Helper
private func hapticFeedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
    #if canImport(UIKit)
    let impact = UIImpactFeedbackGenerator(style: style)
    impact.impactOccurred()
    #endif
}