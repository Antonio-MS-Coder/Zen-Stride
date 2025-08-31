import SwiftUI

struct EditHabitView: View {
    @EnvironmentObject var dataStore: IgniteDataStore
    @Environment(\.dismiss) private var dismiss
    let habit: HabitModel
    
    // Editable properties
    @State private var habitName: String
    @State private var selectedIcon: String
    @State private var selectedColor: Color
    @State private var trackingType: TrackingType
    @State private var targetValue: String
    @State private var targetPeriod: TargetPeriod
    @State private var unit: String
    @State private var isActive: Bool
    
    // UI State
    @State private var showingIconPicker = false
    
    // Available icons
    private let availableIcons = [
        "star.fill", "heart.fill", "book.fill", "figure.run",
        "drop.fill", "brain.head.profile", "pencil", "figure.walk",
        "moon.fill", "sun.max.fill", "leaf.fill", "flame.fill",
        "dollarsign.circle", "scale.3d", "pills.fill", "cup.and.saucer.fill"
    ]
    
    // Available colors
    private let availableColors: [Color] = [
        .premiumIndigo, .premiumTeal, .premiumBlue, .premiumMint,
        .premiumCoral, .premiumAmber, .purple, .pink
    ]
    
    init(habit: HabitModel) {
        self.habit = habit
        _habitName = State(initialValue: habit.name)
        _selectedIcon = State(initialValue: habit.icon)
        _selectedColor = State(initialValue: habit.color)
        _trackingType = State(initialValue: habit.trackingType)
        _targetValue = State(initialValue: habit.targetValue != nil ? String(Int(habit.targetValue!)) : "")
        _targetPeriod = State(initialValue: habit.targetPeriod)
        _unit = State(initialValue: habit.unit ?? "")
        _isActive = State(initialValue: habit.isActive)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 32) {
                    // Icon and name section
                    habitBasicInfoSection
                    
                    // Color picker
                    colorPickerSection
                    
                    // Tracking type selector
                    trackingTypeSection
                    
                    // Target configuration (if needed)
                    if trackingType != .check {
                        targetConfigurationSection
                    }
                    
                    // Active toggle
                    activeToggleSection
                    
                    // Save button
                    saveButton
                }
                .padding(24)
            }
            .background(Color.premiumGray6)
            .navigationTitle("Edit Habit")
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
    
    // MARK: - Basic Info Section
    private var habitBasicInfoSection: some View {
        VStack(spacing: 20) {
            // Icon selector
            Button {
                showingIconPicker.toggle()
            } label: {
                ZStack {
                    Circle()
                        .fill(selectedColor.opacity(0.15))
                        .frame(width: 100, height: 100)
                    
                    Image(systemName: selectedIcon)
                        .font(.system(size: 44))
                        .foregroundColor(selectedColor)
                }
            }
            
            // Name input
            VStack(alignment: .leading, spacing: 8) {
                Text("Habit Name")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.premiumGray2)
                
                TextField("e.g., Morning Yoga", text: $habitName)
                    .font(.system(size: 18))
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white)
                    )
            }
        }
        .sheet(isPresented: $showingIconPicker) {
            IconPickerView(selectedIcon: $selectedIcon, icons: availableIcons)
        }
    }
    
    // MARK: - Color Picker Section
    private var colorPickerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Color")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.premiumGray2)
            
            HStack(spacing: 12) {
                ForEach(availableColors, id: \.self) { color in
                    Button {
                        selectedColor = color
                    } label: {
                        Circle()
                            .fill(color)
                            .frame(width: 36, height: 36)
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: 3)
                                    .opacity(selectedColor == color ? 1 : 0)
                            )
                            .overlay(
                                Circle()
                                    .stroke(color, lineWidth: 2)
                                    .scaleEffect(selectedColor == color ? 1.3 : 1)
                            )
                    }
                    .animation(.spring(response: 0.3), value: selectedColor)
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
            )
        }
    }
    
    // MARK: - Tracking Type Section
    private var trackingTypeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tracking Type")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.premiumGray2)
            
            VStack(spacing: 8) {
                TrackingTypeOption(
                    type: .check,
                    title: "Daily Check",
                    description: "Mark as done once per day",
                    icon: "checkmark.circle",
                    isSelected: trackingType == .check,
                    action: { trackingType = .check }
                )
                
                TrackingTypeOption(
                    type: .count,
                    title: "Count",
                    description: "Track multiple times (e.g., 8 glasses of water)",
                    icon: "number.circle",
                    isSelected: trackingType == .count,
                    action: { trackingType = .count }
                )
                
                TrackingTypeOption(
                    type: .goal,
                    title: "Long-term Goal",
                    description: "Work toward a total target (e.g., lose 10kg)",
                    icon: "target",
                    isSelected: trackingType == .goal,
                    action: { trackingType = .goal }
                )
            }
        }
    }
    
    // MARK: - Target Configuration Section
    private var targetConfigurationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text(trackingType == .count ? "Daily Target" : "Total Goal")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.premiumGray2)
                
                HStack {
                    TextField("0", text: $targetValue)
                        .keyboardType(.numberPad)
                        .font(.system(size: 18))
                    
                    Divider()
                        .frame(height: 20)
                    
                    TextField("unit", text: $unit)
                        .font(.system(size: 18))
                        .frame(width: 100)
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white)
                )
            }
            
            if trackingType == .count {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Period")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.premiumGray2)
                    
                    HStack(spacing: 8) {
                        PeriodButton(title: "Daily", period: .daily, selected: $targetPeriod)
                        PeriodButton(title: "Weekly", period: .weekly, selected: $targetPeriod)
                    }
                }
            }
        }
    }
    
    // MARK: - Active Toggle
    private var activeToggleSection: some View {
        HStack {
            Text("Active")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.premiumGray1)
            
            Spacer()
            
            Toggle("", isOn: $isActive)
                .labelsHidden()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
        )
    }
    
    // MARK: - Save Button
    private var saveButton: some View {
        Button {
            saveChanges()
        } label: {
            Text("Save Changes")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(selectedColor)
                )
        }
        .disabled(habitName.isEmpty)
        .opacity(habitName.isEmpty ? 0.5 : 1)
    }
    
    // MARK: - Save Changes Function
    private func saveChanges() {
        let targetVal = Double(targetValue)
        
        var updatedHabit = habit
        updatedHabit.icon = selectedIcon
        updatedHabit.unit = unit.isEmpty ? nil : unit
        updatedHabit.isActive = isActive
        updatedHabit.trackingType = trackingType
        updatedHabit.targetValue = targetVal
        updatedHabit.targetPeriod = targetPeriod
        updatedHabit.colorHex = selectedColor.toHex()
        
        // Create new habit with updated values (since name is immutable)
        if habitName != habit.name {
            dataStore.removeHabit(habit)
            let newHabit = HabitModel(
                id: habit.id,
                name: habitName,
                icon: selectedIcon,
                unit: unit.isEmpty ? nil : unit,
                isActive: isActive,
                trackingType: trackingType,
                targetValue: targetVal,
                targetPeriod: targetPeriod,
                colorHex: selectedColor.toHex()
            )
            dataStore.addHabit(newHabit)
        } else {
            dataStore.updateHabit(updatedHabit)
        }
        
        dismiss()
    }
}