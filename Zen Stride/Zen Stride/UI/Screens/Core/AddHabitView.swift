import SwiftUI

struct AddHabitView: View {
    @EnvironmentObject var dataStore: ZenStrideDataStore
    @Environment(\.dismiss) private var dismiss
    
    // Basic info
    @State private var habitName = ""
    @State private var selectedIcon = "star.fill"
    @State private var selectedColor = Color.premiumIndigo
    
    // Tracking configuration
    @State private var trackingType: TrackingType = .check
    @State private var targetValue = ""
    @State private var targetPeriod: TargetPeriod = .daily
    @State private var unit = ""
    
    // UI State
    @State private var showingIconPicker = false
    @FocusState private var isNameFocused: Bool
    
    // Available icons
    private let availableIcons = [
        // Mascot icons (will be shown first)
        "mascot:neutral", "mascot:celebrating", "mascot:meditating", 
        "mascot:reading", "mascot:running", "mascot:sleeping",
        "mascot:waving", "mascot:thinking", "mascot:heart", "mascot:trophy",
        // SF Symbols
        "star.fill", "heart.fill", "book.fill", "figure.run",
        "drop.fill", "brain.head.profile", "pencil", "figure.walk",
        "moon.fill", "sun.max.fill", "leaf.fill", "flame.fill",
        "dollarsign.circle", "scale.3d", "pills.fill", "cup.and.saucer.fill"
    ]
    
    // Map mascot codes to their image names
    private let mascotMap: [String: String] = [
        "mascot:neutral": "Zen_Stride_Neutral",
        "mascot:celebrating": "Zen_Stride_Celebrating",
        "mascot:meditating": "Zen_Stride_Meditation",
        "mascot:reading": "Zen_Stride_Leyendo",
        "mascot:running": "Zen_Stride_Running",
        "mascot:sleeping": "Zen_Stride_Sleep",
        "mascot:waving": "Zen_Stride_Waving",
        "mascot:thinking": "Zen_Stride_Thinking",
        "mascot:heart": "Zen_Stride_Heart",
        "mascot:trophy": "Zen_Stride_Trophy"
    ]
    
    // Available colors
    private let availableColors: [Color] = [
        .premiumIndigo, .premiumTeal, .premiumBlue, .premiumMint,
        .premiumCoral, .premiumAmber, .purple, .pink
    ]
    
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
                    
                    // Create button
                    createButton
                }
                .padding(24)
            }
            .background(Color.premiumGray6)
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
        .onAppear {
            isNameFocused = true
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
                    
                    if selectedIcon.hasPrefix("mascot:") {
                        if let mascotImage = mascotMap[selectedIcon] {
                            Image(mascotImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 70, height: 70)
                        }
                    } else {
                        Image(systemName: selectedIcon)
                            .font(.system(size: 44))
                            .foregroundColor(selectedColor)
                    }
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
                    .focused($isNameFocused)
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
                // Check option
                TrackingTypeOption(
                    type: .check,
                    title: "Daily Check",
                    description: "Mark as done once per day",
                    icon: "checkmark.circle",
                    isSelected: trackingType == .check,
                    action: { trackingType = .check }
                )
                
                // Count option
                TrackingTypeOption(
                    type: .count,
                    title: "Count",
                    description: "Track multiple times (e.g., 8 glasses of water)",
                    icon: "number.circle",
                    isSelected: trackingType == .count,
                    action: { trackingType = .count }
                )
                
                // Goal option
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
            // Target value
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
            
            // Period selector for count type
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
    
    // MARK: - Create Button
    private var createButton: some View {
        Button {
            createHabit()
        } label: {
            Text("Create Habit")
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
    
    // MARK: - Create Habit Function
    private func createHabit() {
        let targetVal = Double(targetValue)
        
        let newHabit = HabitModel(
            name: habitName,
            icon: selectedIcon,
            unit: unit.isEmpty ? nil : unit,
            trackingType: trackingType,
            targetValue: targetVal,
            targetPeriod: targetPeriod,
            colorHex: selectedColor.toHex()
        )
        
        dataStore.addHabit(newHabit)
        dismiss()
    }
}

// MARK: - Tracking Type Option
struct TrackingTypeOption: View {
    let type: TrackingType
    let title: String
    let description: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? .premiumIndigo : .premiumGray3)
                    .frame(width: 32)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.premiumGray1)
                    
                    Text(description)
                        .font(.system(size: 13))
                        .foregroundColor(.premiumGray3)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.premiumIndigo)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color.premiumIndigo : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Period Button
struct PeriodButton: View {
    let title: String
    let period: TargetPeriod
    @Binding var selected: TargetPeriod
    
    var body: some View {
        Button {
            selected = period
        } label: {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(selected == period ? .white : .premiumGray2)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(selected == period ? Color.premiumIndigo : Color.premiumGray6)
                )
        }
    }
}

// MARK: - Icon Picker View
struct IconPickerView: View {
    @Binding var selectedIcon: String
    let icons: [String]
    @Environment(\.dismiss) private var dismiss
    
    // Map mascot codes to their image names
    private let mascotMap: [String: String] = [
        "mascot:neutral": "Zen_Stride_Neutral",
        "mascot:celebrating": "Zen_Stride_Celebrating",
        "mascot:meditating": "Zen_Stride_Meditation",
        "mascot:reading": "Zen_Stride_Leyendo",
        "mascot:running": "Zen_Stride_Running",
        "mascot:sleeping": "Zen_Stride_Sleep",
        "mascot:waving": "Zen_Stride_Waving",
        "mascot:thinking": "Zen_Stride_Thinking",
        "mascot:heart": "Zen_Stride_Heart",
        "mascot:trophy": "Zen_Stride_Trophy"
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Mascot section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("MASCOT ICONS")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.premiumGray3)
                            .tracking(1)
                            .padding(.horizontal)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 20) {
                            ForEach(icons.filter { $0.hasPrefix("mascot:") }, id: \.self) { icon in
                                Button {
                                    selectedIcon = icon
                                    dismiss()
                                } label: {
                                    ZStack {
                                        Circle()
                                            .fill(selectedIcon == icon ? Color.premiumIndigo.opacity(0.2) : Color.premiumGray6)
                                            .frame(width: 60, height: 60)
                                        
                                        if let mascotImage = mascotMap[icon] {
                                            Image(mascotImage)
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 45, height: 45)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Regular icons section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("SYMBOL ICONS")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.premiumGray3)
                            .tracking(1)
                            .padding(.horizontal)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 20) {
                            ForEach(icons.filter { !$0.hasPrefix("mascot:") }, id: \.self) { icon in
                                Button {
                                    selectedIcon = icon
                                    dismiss()
                                } label: {
                                    ZStack {
                                        Circle()
                                            .fill(selectedIcon == icon ? Color.premiumIndigo.opacity(0.2) : Color.premiumGray6)
                                            .frame(width: 60, height: 60)
                                        
                                        Image(systemName: icon)
                                            .font(.system(size: 28))
                                            .foregroundColor(.premiumIndigo)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Choose Icon")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}