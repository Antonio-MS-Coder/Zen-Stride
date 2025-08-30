import SwiftUI

struct ProfileManagementView: View {
    @Binding var habits: [Habit]
    @Environment(\.dismiss) private var dismiss
    @State private var showingAddHabit = false
    @State private var editingHabit: Habit?
    @State private var userName = "Friend"
    @State private var showingSettings = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.premiumGray6
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
                AddHabitView(habits: $habits)
            }
            .sheet(item: $editingHabit) { habit in
                EditHabitView(habit: habit, habits: $habits)
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
                            colors: [.premiumIndigo, .premiumTeal],
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
                    .foregroundColor(.premiumGray1)
                
                Text("\(habits.count) active habits")
                    .font(.system(size: 16))
                    .foregroundColor(.premiumGray3)
            }
        }
    }
    
    // MARK: - Habits Management
    private var habitsManagementSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("MY HABITS")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.premiumGray3)
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
                    .foregroundColor(.premiumIndigo)
                }
            }
            
            if habits.isEmpty {
                emptyHabitsView
            } else {
                VStack(spacing: 12) {
                    ForEach(habits) { habit in
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
            Image(systemName: "star.circle")
                .font(.system(size: 48))
                .foregroundColor(.premiumGray4)
            
            Text("No habits yet")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.premiumGray2)
            
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
                            .fill(Color.premiumIndigo)
                    )
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
        )
    }
    
    // MARK: - Settings Section
    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("SETTINGS")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.premiumGray3)
                .tracking(1)
            
            VStack(spacing: 0) {
                SettingsRow(
                    icon: "bell",
                    title: "Reminders",
                    action: {
                        // Handle reminders
                    }
                )
                
                Divider()
                    .padding(.leading, 56)
                
                SettingsRow(
                    icon: "moon",
                    title: "Theme",
                    action: {
                        // Handle theme
                    }
                )
                
                Divider()
                    .padding(.leading, 56)
                
                SettingsRow(
                    icon: "questionmark.circle",
                    title: "Help",
                    action: {
                        // Handle help
                    }
                )
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
            )
        }
    }
    
    // MARK: - Helpers
    private func deleteHabit(_ habit: Habit) {
        withAnimation {
            habits.removeAll { $0.id == habit.id }
        }
    }
}

// MARK: - Habit Management Card
struct HabitManagementCard: View {
    let habit: Habit
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
                
                Image(systemName: habit.icon)
                    .font(.system(size: 22))
                    .foregroundColor(habit.color)
            }
            
            // Name
            VStack(alignment: .leading, spacing: 4) {
                Text(habit.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.premiumGray1)
                
                if let frequency = habit.frequency {
                    Text(frequency)
                        .font(.system(size: 14))
                        .foregroundColor(.premiumGray3)
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
                        .foregroundColor(.premiumGray3)
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
                .fill(Color.white)
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
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(.premiumGray3)
                    .frame(width: 24, height: 24)
                
                Text(title)
                    .font(.system(size: 16))
                    .foregroundColor(.premiumGray1)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.premiumGray4)
            }
            .padding(16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Add Habit View
struct AddHabitView: View {
    @Binding var habits: [Habit]
    @Environment(\.dismiss) private var dismiss
    @State private var habitName = ""
    @State private var selectedIcon = "star.fill"
    @State private var selectedFrequency = "Daily"
    @State private var unit = "times"
    
    let icons = ["star.fill", "book.fill", "figure.run", "drop.fill", 
                 "brain.head.profile", "pencil", "figure.walk", "heart.fill",
                 "leaf.fill", "moon.fill", "sun.max.fill", "bolt.fill"]
    
    let frequencies = ["Daily", "Weekly", "As needed"]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.premiumGray6
                    .ignoresSafeArea()
                
                VStack(spacing: 32) {
                    // Name input
                    VStack(alignment: .leading, spacing: 8) {
                        Text("HABIT NAME")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.premiumGray3)
                            .tracking(1)
                        
                        TextField("Enter habit name", text: $habitName)
                            .font(.system(size: 18))
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white)
                            )
                    }
                    
                    // Icon selection
                    VStack(alignment: .leading, spacing: 8) {
                        Text("ICON")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.premiumGray3)
                            .tracking(1)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
                            ForEach(icons, id: \.self) { icon in
                                Button {
                                    selectedIcon = icon
                                } label: {
                                    ZStack {
                                        Circle()
                                            .fill(selectedIcon == icon ? Color.premiumIndigo.opacity(0.1) : Color.white)
                                            .overlay(
                                                Circle()
                                                    .stroke(selectedIcon == icon ? Color.premiumIndigo : Color.clear, lineWidth: 2)
                                            )
                                        
                                        Image(systemName: icon)
                                            .font(.system(size: 20))
                                            .foregroundColor(selectedIcon == icon ? .premiumIndigo : .premiumGray3)
                                    }
                                    .frame(width: 48, height: 48)
                                }
                            }
                        }
                    }
                    
                    // Frequency
                    VStack(alignment: .leading, spacing: 8) {
                        Text("FREQUENCY")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.premiumGray3)
                            .tracking(1)
                        
                        HStack(spacing: 12) {
                            ForEach(frequencies, id: \.self) { frequency in
                                Button {
                                    selectedFrequency = frequency
                                } label: {
                                    Text(frequency)
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(selectedFrequency == frequency ? .white : .premiumGray2)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 10)
                                        .background(
                                            Capsule()
                                                .fill(selectedFrequency == frequency ? Color.premiumIndigo : Color.white)
                                        )
                                }
                            }
                        }
                    }
                    
                    Spacer()
                    
                    // Save button
                    Button {
                        saveHabit()
                    } label: {
                        Text("Create Habit")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.premiumIndigo)
                            )
                    }
                    .disabled(habitName.isEmpty)
                    .opacity(habitName.isEmpty ? 0.5 : 1.0)
                }
                .padding(20)
            }
            .navigationTitle("New Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func saveHabit() {
        let newHabit = Habit(
            name: habitName,
            icon: selectedIcon,
            frequency: selectedFrequency,
            unit: unit,
            isActive: true
        )
        habits.append(newHabit)
        dismiss()
    }
}

// MARK: - Edit Habit View
struct EditHabitView: View {
    let habit: Habit
    @Binding var habits: [Habit]
    @Environment(\.dismiss) private var dismiss
    @State private var habitName: String
    @State private var selectedIcon: String
    @State private var selectedFrequency: String
    
    init(habit: Habit, habits: Binding<[Habit]>) {
        self.habit = habit
        self._habits = habits
        self._habitName = State(initialValue: habit.name)
        self._selectedIcon = State(initialValue: habit.icon)
        self._selectedFrequency = State(initialValue: habit.frequency ?? "Daily")
    }
    
    var body: some View {
        AddHabitView(habits: $habits) // Reuse the add view for editing
            .navigationTitle("Edit Habit")
            .onAppear {
                // Pre-fill the fields
            }
    }
}