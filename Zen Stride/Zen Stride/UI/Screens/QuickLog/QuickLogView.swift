import SwiftUI

struct QuickLogView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var dataStore: ZenStrideDataStore
    let onComplete: (MicroWin) -> Void
    
    @State private var selectedHabit: QuickHabit?
    @State private var customValue = ""
    @State private var showingCustomInput = false
    // Always start in quick mode for minimal friction
    @State private var quickLogMode = true
    @State private var showCelebration = false
    @State private var currentCelebration: CelebrationData?
    
    // Convert user's habits to quick habits
    private var quickHabits: [QuickHabit] {
        // If user has habits, use those. Otherwise, show defaults
        if !dataStore.habits.isEmpty {
            return dataStore.habits.map { habit in
                QuickHabit(
                    name: habit.name,
                    icon: habit.icon,
                    color: habit.color,
                    quickValues: generateQuickValues(for: habit),
                    unit: habit.unit ?? "times"
                )
            }
        } else {
            // Default habits for new users
            return [
                QuickHabit(name: "Reading", icon: "book.fill", color: .premiumIndigo, 
                          quickValues: ["5 pages", "10 pages", "15 pages", "1 chapter"], unit: "pages"),
                QuickHabit(name: "Exercise", icon: "figure.run", color: .premiumTeal,
                          quickValues: ["10 min", "15 min", "20 min", "30 min"], unit: "minutes"),
                QuickHabit(name: "Water", icon: "drop.fill", color: .premiumBlue,
                          quickValues: ["1 glass", "2 glasses", "3 glasses", "1 bottle"], unit: "glasses"),
                QuickHabit(name: "Steps", icon: "figure.walk", color: .premiumAmber,
                          quickValues: ["1000", "2500", "5000", "10000"], unit: "steps")
            ]
        }
    }
    
    private func generateQuickValues(for habit: HabitModel) -> [String] {
        // Generate sensible quick values based on habit type
        switch habit.unit?.lowercased() {
        case "minutes", "min":
            return ["5", "10", "15", "30"]
        case "hours", "hr":
            return ["0.5", "1", "1.5", "2"]
        case "pages":
            return ["5", "10", "15", "20"]
        case "glasses", "cups":
            return ["1", "2", "3", "4"]
        case "steps":
            return ["1000", "2500", "5000", "10000"]
        default:
            return ["1", "2", "3", "5"]
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.premiumGray6
                    .ignoresSafeArea()
                
                VStack(spacing: .spacing24) {
                    // Header with close button
                    headerSection
                    
                    if quickLogMode {
                        // One-tap quick wins
                        quickWinsGrid
                            .transition(.opacity)
                    } else {
                        // Traditional two-step selection
                        habitSelectionGrid
                        
                        if let habit = selectedHabit {
                            valueSelectionSection(for: habit)
                                .transition(.asymmetric(
                                    insertion: .move(edge: .bottom).combined(with: .opacity),
                                    removal: .move(edge: .bottom).combined(with: .opacity)
                                ))
                        }
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, .spacing20)
                .padding(.top, .spacing20)
            }
            .overlay(
                // Celebration overlay
                Group {
                    if showCelebration, let celebration = currentCelebration {
                        EnhancedCelebrationView(
                            celebration: celebration,
                            isPresented: $showCelebration
                        )
                        .zIndex(100)
                    }
                }
            )
        }
    }
    
    // MARK: - Header
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: .spacing4) {
                Text(quickLogMode ? "QUICK WIN" : "LOG A WIN")
                    .font(.premiumCaption1)
                    .foregroundColor(.premiumGray3)
                    .tracking(1.2)
                
                Text(quickLogMode ? "Tap to log" : "What did you accomplish?")
                    .font(.premiumTitle3)
                    .foregroundColor(.premiumGray1)
            }
            
            Spacer()
            
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.premiumGray5)
            }
        }
    }
    
    // MARK: - Quick Wins Grid (One-tap)
    private var quickWinsGrid: some View {
        VStack(spacing: .spacing16) {
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: .spacing16) {
                // Most common quick wins for one-tap logging
                QuickWinButton(
                    title: "10 pages",
                    icon: "book.fill",
                    color: .premiumIndigo,
                    onTap: {
                        logQuickWin("Reading", "10", "pages", "book.fill", .premiumIndigo)
                    }
                )
                
                QuickWinButton(
                    title: "15 min exercise",
                    icon: "figure.run",
                    color: .premiumTeal,
                    onTap: {
                        logQuickWin("Exercise", "15", "min", "figure.run", .premiumTeal)
                    }
                )
                
                QuickWinButton(
                    title: "2 glasses water",
                    icon: "drop.fill",
                    color: .premiumBlue,
                    onTap: {
                        logQuickWin("Water", "2", "glasses", "drop.fill", .premiumBlue)
                    }
                )
                
                QuickWinButton(
                    title: "10 min meditation",
                    icon: "brain.head.profile",
                    color: .premiumMint,
                    onTap: {
                        logQuickWin("Meditation", "10", "min", "brain.head.profile", .premiumMint)
                    }
                )
                
                QuickWinButton(
                    title: "500 words",
                    icon: "pencil",
                    color: .premiumCoral,
                    onTap: {
                        logQuickWin("Writing", "500", "words", "pencil", .premiumCoral)
                    }
                )
                
                QuickWinButton(
                    title: "5000 steps",
                    icon: "figure.walk",
                    color: .premiumAmber,
                    onTap: {
                        logQuickWin("Steps", "5000", "steps", "figure.walk", .premiumAmber)
                    }
                )
            }
            
            Button {
                withAnimation(.premiumSpring) {
                    quickLogMode = false
                }
            } label: {
                HStack(spacing: .spacing8) {
                    Text("More options")
                        .font(.premiumCallout)
                        .foregroundColor(.premiumGray3)
                    Image(systemName: "ellipsis.circle")
                        .font(.system(size: 16))
                        .foregroundColor(.premiumGray3)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, .spacing12)
                .background(
                    RoundedRectangle(cornerRadius: .radiusM)
                        .fill(Color.premiumGray6.opacity(0.5))
                )
            }
        }
    }
    
    // MARK: - Habit Grid
    private var habitSelectionGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: .spacing16) {
            ForEach(quickHabits) { habit in
                QuickHabitButton(
                    habit: habit,
                    isSelected: selectedHabit?.id == habit.id,
                    onTap: {
                        withAnimation(.premiumSpring) {
                            if selectedHabit?.id == habit.id {
                                selectedHabit = nil
                            } else {
                                selectedHabit = habit
                                hapticFeedback(.light)
                            }
                        }
                    }
                )
            }
        }
    }
    
    // MARK: - Value Selection
    private func valueSelectionSection(for habit: QuickHabit) -> some View {
        VStack(alignment: .leading, spacing: .spacing16) {
            Text("HOW MUCH?")
                .font(.premiumCaption1)
                .foregroundColor(.premiumGray3)
                .tracking(1.2)
            
            // Quick value buttons
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: .spacing12) {
                    ForEach(habit.quickValues, id: \.self) { value in
                        QuickValueButton(
                            value: value,
                            color: habit.color,
                            onTap: {
                                logWin(habit: habit, value: value)
                            }
                        )
                    }
                    
                    // Custom input button
                    Button {
                        showingCustomInput = true
                    } label: {
                        Text("Custom")
                            .font(.premiumCallout)
                            .foregroundColor(.premiumGray2)
                            .padding(.horizontal, .spacing20)
                            .padding(.vertical, .spacing12)
                            .background(
                                RoundedRectangle(cornerRadius: .radiusM)
                                    .stroke(Color.premiumGray5, lineWidth: 2)
                            )
                    }
                }
            }
        }
        .sheet(isPresented: $showingCustomInput) {
            CustomValueInput(
                habit: habit,
                onComplete: { value in
                    logWin(habit: habit, value: "\(value) \(habit.unit)")
                }
            )
        }
    }
    
    // MARK: - Quick Win Helper with Celebration
    private func logQuickWin(_ name: String, _ value: String, _ unit: String, _ icon: String, _ color: Color) {
        // Get contextual celebration
        let celebration = ContextualCelebration.getCelebration(for: name, value: value)
        currentCelebration = celebration
        showCelebration = true
        
        let win = MicroWin(
            habitName: name,
            value: value,
            unit: unit,
            icon: icon,
            color: color,
            timestamp: Date()
        )
        
        // Delay completion to show celebration
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            onComplete(win)
            dismiss()
        }
    }
    
    // MARK: - Log Win with Celebration
    private func logWin(habit: QuickHabit, value: String) {
        // Parse the value to extract number
        let components = value.split(separator: " ")
        let numericValue = String(components.first ?? "")
        let unit = components.count > 1 ? String(components.last ?? "") : habit.unit
        
        // Get contextual celebration
        let celebration = ContextualCelebration.getCelebration(for: habit.name, value: numericValue)
        currentCelebration = celebration
        showCelebration = true
        
        let win = MicroWin(
            habitName: habit.name,
            value: numericValue,
            unit: unit,
            icon: habit.icon,
            color: habit.color,
            timestamp: Date()
        )
        
        // Delay completion to show celebration
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            onComplete(win)
            dismiss()
        }
    }
    
    private func hapticFeedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        #if canImport(UIKit)
        let impact = UIImpactFeedbackGenerator(style: style)
        impact.impactOccurred()
        #endif
    }
}

// MARK: - Quick Habit Model
struct QuickHabit: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let color: Color
    let quickValues: [String]
    let unit: String
}

// MARK: - Quick Habit Button
struct QuickHabitButton: View {
    let habit: QuickHabit
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: .spacing8) {
                ZStack {
                    Circle()
                        .fill(isSelected ? habit.color : habit.color.opacity(0.15))
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: habit.icon)
                        .font(.system(size: 24))
                        .foregroundColor(isSelected ? .white : habit.color)
                }
                
                Text(habit.name)
                    .font(.premiumCaption1)
                    .foregroundColor(isSelected ? .premiumGray1 : .premiumGray2)
            }
            .scaleEffect(isSelected ? 1.05 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Quick Value Button
struct QuickValueButton: View {
    let value: String
    let color: Color
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            Text(value)
                .font(.premiumHeadline)
                .foregroundColor(.white)
                .padding(.horizontal, .spacing20)
                .padding(.vertical, .spacing12)
                .background(
                    RoundedRectangle(cornerRadius: .radiusM)
                        .fill(color)
                )
                .premiumShadowS()
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Custom Value Input
// MARK: - Quick Win Button (One-tap)
struct QuickWinButton: View {
    let title: String
    let icon: String
    let color: Color
    let onTap: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            withAnimation(.premiumQuick) {
                isPressed = true
            }
            onTap()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.premiumQuick) {
                    isPressed = false
                }
            }
        }) {
            VStack(spacing: .spacing12) {
                ZStack {
                    RoundedRectangle(cornerRadius: .radiusL)
                        .fill(color.opacity(0.1))
                    
                    Image(systemName: icon)
                        .font(.system(size: 28))
                        .foregroundColor(color)
                }
                .frame(height: 80)
                
                Text(title)
                    .font(.premiumCallout)
                    .foregroundColor(.premiumGray1)
                    .multilineTextAlignment(.center)
            }
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Custom Value Input
struct CustomValueInput: View {
    let habit: QuickHabit
    let onComplete: (String) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var value = ""
    @FocusState private var isFocused: Bool
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.premiumGray6
                    .ignoresSafeArea()
                
                VStack(spacing: .spacing32) {
                    // Icon and title
                    VStack(spacing: .spacing16) {
                        ZStack {
                            Circle()
                                .fill(habit.color.opacity(0.15))
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: habit.icon)
                                .font(.system(size: 36))
                                .foregroundColor(habit.color)
                        }
                        
                        Text(habit.name)
                            .font(.premiumTitle2)
                            .foregroundColor(.premiumGray1)
                    }
                    
                    // Input field
                    VStack(alignment: .leading, spacing: .spacing8) {
                        Text("Enter amount")
                            .font(.premiumCallout)
                            .foregroundColor(.premiumGray2)
                        
                        HStack {
                            TextField("0", text: $value)
                                .font(.system(size: 48, weight: .semibold, design: .rounded))
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.center)
                                .focused($isFocused)
                            
                            Text(habit.unit)
                                .font(.premiumTitle3)
                                .foregroundColor(.premiumGray3)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: .radiusL)
                                .fill(Color.white)
                        )
                    }
                    
                    // Quick adjust buttons
                    HStack(spacing: .spacing16) {
                        ForEach(["-5", "-1", "+1", "+5"], id: \.self) { adjustment in
                            Button {
                                adjustValue(by: adjustment)
                            } label: {
                                Text(adjustment)
                                    .font(.premiumCallout)
                                    .foregroundColor(.premiumIndigo)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, .spacing8)
                                    .background(
                                        RoundedRectangle(cornerRadius: .radiusS)
                                            .fill(Color.premiumIndigo.opacity(0.1))
                                    )
                            }
                        }
                    }
                    
                    Spacer()
                    
                    // Save button
                    Button {
                        if !value.isEmpty {
                            onComplete(value)
                            dismiss()
                        }
                    } label: {
                        Text("Log This Win")
                            .font(.premiumHeadline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, .spacing16)
                            .background(
                                RoundedRectangle(cornerRadius: .radiusM)
                                    .fill(habit.color)
                            )
                            .premiumShadowM()
                    }
                    .disabled(value.isEmpty)
                    .opacity(value.isEmpty ? 0.5 : 1.0)
                }
                .padding(.spacing24)
            }
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
            isFocused = true
        }
    }
    
    private func adjustValue(by adjustment: String) {
        let currentValue = Int(value) ?? 0
        let adjustmentValue = Int(adjustment) ?? 0
        let newValue = max(0, currentValue + adjustmentValue)
        value = "\(newValue)"
    }
}