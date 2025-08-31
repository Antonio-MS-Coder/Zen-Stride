import SwiftUI

struct LogWinsView: View {
    @EnvironmentObject var dataStore: ZenStrideDataStore
    @Binding var showingQuickLog: Bool
    @State private var todaysWins: [MicroWin] = []
    @State private var showingProfile = false
    @State private var showingProgressFeedback = false
    @State private var lastLoggedHabit: HabitModel?
    
    // Default quick habits for new users with mascot icons and vibrant colors
    private var defaultHabits: [HabitModel] {
        [
            HabitModel(name: "Water", icon: "mascot:neutral", unit: "glasses", 
                      trackingType: .count, targetValue: 8, targetPeriod: .daily,
                      colorHex: "#007BFF"), // Vibrant blue
            HabitModel(name: "Exercise", icon: "mascot:running", unit: "minutes",
                      trackingType: .count, targetValue: 30, targetPeriod: .daily,
                      colorHex: "#00C7BE"), // Vibrant teal
            HabitModel(name: "Reading", icon: "mascot:reading", unit: "pages",
                      trackingType: .count, targetValue: 20, targetPeriod: .daily,
                      colorHex: "#5856D6"), // Vibrant indigo
            HabitModel(name: "Meditation", icon: "mascot:meditating", unit: "minutes",
                      trackingType: .count, targetValue: 10, targetPeriod: .daily,
                      colorHex: "#9333EA") // Vibrant purple
        ]
    }
    
    // Show user habits sorted by most frequently used
    private var displayHabits: [HabitModel] {
        if dataStore.habits.isEmpty {
            return defaultHabits
        }
        
        // Sort habits by usage count (most used first)
        let sortedHabits = dataStore.habits.sorted { habit1, habit2 in
            let habit1Count = dataStore.wins.filter { $0.habitName == habit1.name }.count
            let habit2Count = dataStore.wins.filter { $0.habitName == habit2.name }.count
            return habit1Count > habit2Count
        }
        
        // Return top 4 most used habits
        return Array(sortedHabits.prefix(4))
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Clean background
                LinearGradient(
                    colors: [Color.premiumGray6, Color.white],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        // Welcome header
                        headerSection
                        
                        // Quick action buttons - always show
                        quickActionsSection
                        
                        // Today's wins
                        if !todaysWins.isEmpty {
                            todaysWinsSection
                        }
                        
                        // Motivation state when no wins yet
                        if dataStore.wins.isEmpty {
                            motivationView
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 60)
                    .padding(.bottom, 100)
                }
                
                // Floating log button
                floatingActionButton
                
                // Progress feedback overlay
                if showingProgressFeedback, let habit = lastLoggedHabit {
                    progressFeedbackOverlay(for: habit)
                }
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            updateTodaysWins()
        }
        .onChange(of: dataStore.wins) {
            updateTodaysWins()
        }
        .sheet(isPresented: $showingProfile) {
            ProfileManagementView()
                .environmentObject(dataStore)
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(getTimeBasedGreeting())
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(.premiumGray1)
            
            Text("What did you accomplish?")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.premiumGray3)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Quick Actions
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("QUICK LOG")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.premiumGray3)
                .tracking(1)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(displayHabits) { habit in
                    QuickActionCard(
                        habit: habit,
                        wins: dataStore.wins.filter { $0.habitName == habit.name }
                    ) {
                        logQuickWin(for: habit)
                    }
                }
            }
        }
    }
    
    // MARK: - Today's Wins
    private var todaysWinsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("TODAY'S WINS")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.premiumGray3)
                    .tracking(1)
                
                Spacer()
                
                Text("\(todaysWins.count)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.premiumIndigo)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(
                        Capsule()
                            .fill(Color.premiumIndigo.opacity(0.1))
                    )
            }
            
            VStack(spacing: 8) {
                ForEach(todaysWins.reversed()) { win in
                    WinCard(win: win)
                }
            }
        }
    }
    
    // MARK: - Motivation View
    private var motivationView: some View {
        VStack(spacing: 24) {
            MascotView(mood: .neutral, size: 120)
            
            VStack(spacing: 8) {
                Text("Ready to start?")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.premiumGray2)
                
                Text("Tap any habit above to log your first win!")
                    .font(.system(size: 16))
                    .foregroundColor(.premiumGray3)
                    .multilineTextAlignment(.center)
            }
            
            Text("Every journey begins with a single step")
                .font(.system(size: 14))
                .foregroundColor(.premiumGray4)
                .italic()
        }
        .padding(.top, 40)
    }
    
    // MARK: - Progress Feedback Overlay
    private func progressFeedbackOverlay(for habit: HabitModel) -> some View {
        VStack {
            // Simple success notification
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(habit.color)
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: "checkmark")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Added!")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.premiumGray1)
                    
                    // Show the actual logged amount
                    let recentWin = dataStore.wins.last { $0.habitName == habit.name }
                    let displayText = if let win = recentWin, habit.trackingType == .count {
                        "\(win.value) \(win.unit)"
                    } else {
                        habit.name
                    }
                    
                    Text(displayText)
                        .font(.system(size: 14))
                        .foregroundColor(.premiumGray3)
                }
                
                Spacer()
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
            )
            .padding(.horizontal, 20)
            .padding(.top, 60)
            .transition(.asymmetric(
                insertion: .move(edge: .top).combined(with: .opacity),
                removal: .scale.combined(with: .opacity)
            ))
            .scaleEffect(showingProgressFeedback ? 1 : 0.95)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: showingProgressFeedback)
            
            Spacer()
        }
    }
    
    // MARK: - Floating Action Button
    private var floatingActionButton: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button {
                    showingQuickLog = true
                } label: {
                    ZStack {
                        Circle()
                            .fill(Color.premiumIndigo)
                            .frame(width: 60, height: 60)
                            .shadow(color: .premiumIndigo.opacity(0.3), radius: 8, x: 0, y: 4)
                        
                        Image(systemName: "plus")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .padding(.trailing, 20)
                .padding(.bottom, 90)
            }
        }
    }
    
    // MARK: - Helpers
    private func updateTodaysWins() {
        let calendar = Calendar.current
        let today = Date()
        todaysWins = dataStore.wins.filter { win in
            calendar.isDate(win.timestamp, inSameDayAs: today)
        }
    }
    
    private func getTimeBasedGreeting() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        case 17..<22: return "Good evening"
        default: return "Good night"
        }
    }
    
    private func logQuickWin(for habit: HabitModel) {
        // Ensure the habit exists in the data store
        if !dataStore.habits.contains(where: { $0.id == habit.id }) {
            dataStore.addHabit(habit)
        }
        
        // Use smart increment value based on habit type and unit
        let incrementValue: String = {
            switch habit.trackingType {
            case .check:
                return "1"
            case .count:
                let smartIncrement = habit.quickIncrementValue
                // Format to remove unnecessary decimal places
                return smartIncrement.truncatingRemainder(dividingBy: 1) == 0 ? 
                    String(Int(smartIncrement)) : String(smartIncrement)
            case .goal:
                return "1"
            }
        }()
        
        let win = MicroWin(
            habitName: habit.name,
            value: incrementValue,
            unit: habit.unit ?? "time",
            icon: habit.icon,
            color: habit.color,
            timestamp: Date()
        )
        dataStore.addWin(win)
        
        // Show simple completion feedback
        withAnimation(.spring()) {
            lastLoggedHabit = habit
            showingProgressFeedback = true
        }
        
        // Hide feedback after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation(.easeOut) {
                showingProgressFeedback = false
            }
        }
    }
}

// MARK: - Quick Action Card
struct QuickActionCard: View {
    let habit: HabitModel
    let wins: [MicroWin]
    let action: () -> Void
    @State private var isPressed = false
    @State private var showingCustomInput = false
    @EnvironmentObject var dataStore: ZenStrideDataStore
    
    // Calculate today's progress based on tracking type
    private var todayProgress: (current: Double, isComplete: Bool) {
        let calendar = Calendar.current
        let today = Date()
        let todayWins = wins.filter { calendar.isDate($0.timestamp, inSameDayAs: today) }
        
        switch habit.trackingType {
        case .check:
            return (todayWins.isEmpty ? 0 : 1, !todayWins.isEmpty)
        case .count:
            let sum = todayWins.reduce(0) { $0 + (Double($1.value) ?? 1) }
            let target = habit.targetValue ?? 1
            return (sum, sum >= target)
        case .goal:
            // For goals, show total progress not just today
            let total = wins.reduce(0) { $0 + (Double($1.value) ?? 0) }
            let target = habit.targetValue ?? 100
            return (total, total >= target)
        }
    }
    
    var body: some View {
        Button(action: {
            isPressed = true
            
            switch habit.trackingType {
            case .check:
                action()
            case .count:
                // For count habits, show options if they might want different amounts
                if habit.quickActionOptions.count > 1 && habit.quickIncrementValue > 1 {
                    showingCustomInput = true
                } else {
                    action()  // Use smart increment
                }
            case .goal:
                showingCustomInput = true  // Goals always need specific input
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isPressed = false
            }
        }) {
            VStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(todayProgress.isComplete ? habit.color.opacity(0.15) : Color.premiumGray6)
                        .frame(height: 80)
                    
                    VStack(spacing: 4) {
                        // Icon with completion indicator
                        ZStack {
                            if habit.trackingType == .check {
                                // Checkbox style for CHECK type
                                Circle()
                                    .stroke(todayProgress.isComplete ? habit.color : Color.premiumGray5, 
                                           style: todayProgress.isComplete ? StrokeStyle(lineWidth: 2) : StrokeStyle(lineWidth: 2, dash: [5]))
                                    .frame(width: 44, height: 44)
                                
                                HabitIconView(
                                    icon: habit.icon,
                                    size: 22,
                                    color: habit.color,
                                    isComplete: todayProgress.isComplete
                                )
                                
                                if todayProgress.isComplete {
                                    VStack {
                                        HStack {
                                            Spacer()
                                            Circle()
                                                .fill(habit.color)
                                                .frame(width: 16, height: 16)
                                                .overlay(
                                                    Image(systemName: "checkmark")
                                                        .font(.system(size: 10, weight: .bold))
                                                        .foregroundColor(.white)
                                                )
                                                .offset(x: 2, y: -2)
                                        }
                                        Spacer()
                                    }
                                }
                            } else {
                                // Progress style for COUNT and GOAL types
                                ZStack {
                                    Circle()
                                        .stroke(Color.premiumGray5.opacity(0.3), lineWidth: 3)
                                        .frame(width: 44, height: 44)
                                    
                                    Circle()
                                        .trim(from: 0, to: min(todayProgress.current / (habit.targetValue ?? 1), 1.0))
                                        .stroke(habit.color, lineWidth: 3)
                                        .frame(width: 44, height: 44)
                                        .rotationEffect(.degrees(-90))
                                    
                                    HabitIconView(
                                        icon: habit.icon,
                                        size: 20,
                                        color: habit.color,
                                        isComplete: todayProgress.isComplete
                                    )
                                }
                            }
                        }
                        
                        // Progress text based on type
                        if habit.trackingType == .count {
                            Text("\(Int(todayProgress.current))/\(Int(habit.targetValue ?? 0))")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(todayProgress.isComplete ? habit.color : .premiumGray3)
                        } else if habit.trackingType == .goal {
                            Text("\(Int((todayProgress.current / (habit.targetValue ?? 1)) * 100))%")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(habit.color)
                        }
                    }
                }
                
                Text(habit.name)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(todayProgress.isComplete ? .premiumGray1 : .premiumGray3)
                    .lineLimit(1)
            }
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showingCustomInput) {
            QuickInputView(habit: habit) { value in
                // Log the custom value
                let win = MicroWin(
                    habitName: habit.name,
                    value: String(value),
                    unit: habit.unit ?? "",
                    icon: habit.icon,
                    color: habit.color,
                    timestamp: Date()
                )
                dataStore.addWin(win)
            }
        }
    }
}

// MARK: - Win Card
struct WinCard: View {
    let win: MicroWin
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(win.color.opacity(0.1))
                    .frame(width: 44, height: 44)
                
                HabitIconView(
                    icon: win.icon,
                    size: 20,
                    color: win.color,
                    isComplete: false
                )
            }
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(win.habitName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.premiumGray1)
                
                HStack(spacing: 4) {
                    Text(win.value)
                        .font(.system(size: 14))
                        .foregroundColor(.premiumGray2)
                    
                    Text(win.unit)
                        .font(.system(size: 14))
                        .foregroundColor(.premiumGray3)
                    
                    Text("•")
                        .foregroundColor(.premiumGray4)
                    
                    Text(timeAgo(from: win.timestamp))
                        .font(.system(size: 14))
                        .foregroundColor(.premiumGray3)
                }
            }
            
            Spacer()
            
            // Celebration sparkle
            Image(systemName: "sparkle")
                .font(.system(size: 14))
                .foregroundColor(.premiumAmber)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
    }
    
    private func timeAgo(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - Quick Input View
struct QuickInputView: View {
    let habit: HabitModel
    let onComplete: (Double) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var inputValue = ""
    @FocusState private var isFocused: Bool
    
    var body: some View {
        NavigationView {
            VStack(spacing: 32) {
                // Header
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(habit.color.opacity(0.15))
                            .frame(width: 80, height: 80)
                        
                        HabitIconView(
                            icon: habit.icon,
                            size: 36,
                            color: habit.color,
                            isComplete: true
                        )
                    }
                    
                    Text(habit.name)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.premiumGray1)
                    
                    if habit.trackingType == .goal {
                        Text("Current: \(getCurrentProgress())")
                            .font(.system(size: 14))
                            .foregroundColor(.premiumGray3)
                    }
                }
                
                // Input field
                VStack(alignment: .leading, spacing: 8) {
                    Text(habit.trackingType == .goal ? "Add progress" : "How many?")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.premiumGray2)
                    
                    HStack {
                        TextField("0", text: $inputValue)
                            .font(.system(size: 48, weight: .semibold, design: .rounded))
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.center)
                            .focused($isFocused)
                        
                        if let unit = habit.unit {
                            Text(unit)
                                .font(.system(size: 20))
                                .foregroundColor(.premiumGray3)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white)
                            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                    )
                }
                
                // Smart quick buttons based on habit unit and target
                if habit.trackingType == .count {
                    HStack(spacing: 12) {
                        ForEach(Array(habit.quickActionOptions.prefix(4)), id: \.self) { value in
                            Button {
                                inputValue = value.truncatingRemainder(dividingBy: 1) == 0 ? 
                                    "\(Int(value))" : "\(value)"
                            } label: {
                                let displayValue = value.truncatingRemainder(dividingBy: 1) == 0 ? 
                                    "\(Int(value))" : "\(value)"
                                Text(displayValue)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(habit.color)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(habit.color.opacity(0.1))
                                    )
                            }
                        }
                    }
                }
                
                Spacer()
                
                // Log button
                Button {
                    if let value = Double(inputValue), value > 0 {
                        onComplete(value)
                        dismiss()
                    }
                } label: {
                    Text("Log")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(habit.color)
                        )
                }
                .disabled(inputValue.isEmpty || Double(inputValue) == nil || Double(inputValue) == 0)
                .opacity(inputValue.isEmpty || Double(inputValue) == nil || Double(inputValue) == 0 ? 0.5 : 1)
            }
            .padding(24)
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
    
    private func getCurrentProgress() -> String {
        // This would calculate from existing wins - simplified for now
        return "0 / \(Int(habit.targetValue ?? 0)) \(habit.unit ?? "")"
    }
}

// MARK: - Habit Model Extension
extension HabitModel {
    var color: Color {
        // Use custom color if available
        if let hex = colorHex {
            return Color(hex: hex) ?? defaultColor
        }
        return defaultColor
    }
    
    private var defaultColor: Color {
        // Use vibrant colors for default habits
        switch icon {
        case "book.fill": return Color(red: 0.35, green: 0.34, blue: 0.84) // Vibrant indigo
        case "figure.run": return Color(red: 0.0, green: 0.78, blue: 0.75) // Vibrant teal
        case "drop.fill": return Color(red: 0.0, green: 0.48, blue: 1.0) // Vibrant blue
        case "brain.head.profile": return Color(red: 0.0, green: 0.78, blue: 0.65) // Vibrant mint
        case "pencil": return Color(red: 1.0, green: 0.42, blue: 0.42) // Vibrant coral
        case "figure.walk": return Color(red: 1.0, green: 0.8, blue: 0.0) // Vibrant amber
        case "scale.3d": return Color(red: 1.0, green: 0.42, blue: 0.42) // Vibrant coral
        case "dollarsign.circle": return Color(red: 0.0, green: 0.78, blue: 0.75) // Vibrant teal
        case "mascot:neutral": return Color(red: 0.0, green: 0.48, blue: 1.0) // Vibrant blue for water
        case "mascot:running": return Color(red: 0.0, green: 0.78, blue: 0.75) // Vibrant teal for exercise
        case "mascot:reading": return Color(red: 0.35, green: 0.34, blue: 0.84) // Vibrant indigo for reading
        case "mascot:meditating": return Color(red: 0.58, green: 0.0, blue: 0.83) // Vibrant purple for meditation
        default: return Color(red: 0.35, green: 0.34, blue: 0.84) // Default vibrant indigo
        }
    }
}

// MARK: - Color Extensions
extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }
        
        self.init(
            red: Double((rgb & 0xFF0000) >> 16) / 255.0,
            green: Double((rgb & 0x00FF00) >> 8) / 255.0,
            blue: Double(rgb & 0x0000FF) / 255.0
        )
    }
    
    func toHex() -> String {
        guard let components = UIColor(self).cgColor.components else { return "" }
        
        let r = Int(components[0] * 255.0)
        let g = Int(components[1] * 255.0)
        let b = Int(components[2] * 255.0)
        
        return String(format: "#%02X%02X%02X", r, g, b)
    }
}