import SwiftUI

struct ProgressOverviewView: View {
    @EnvironmentObject var dataStore: IgniteDataStore
    @State private var selectedHabit: HabitModel?
    @Environment(\.horizontalSizeClass) private var sizeClass
    
    var body: some View {
        ZStack {
            ThemeManager.shared.backgroundColor
                .ignoresSafeArea()
            
            if dataStore.habits.isEmpty {
                emptyStateView
            } else {
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        headerSection
                        
                        // Overview stats
                        overviewStatsSection
                        
                        // Habit progress cards
                        habitProgressSection
                    }
                    .padding(.horizontal, horizontalPadding)
                    .padding(.top, 60)
                    .padding(.bottom, 100)
                    .frame(maxWidth: maxContentWidth)
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .sheet(item: $selectedHabit) { habit in
            HabitDetailView(habit: habit, wins: dataStore.wins)
                .environmentObject(dataStore)
        }
    }
    
    // MARK: - Responsive Layout
    private var horizontalPadding: CGFloat {
        sizeClass == .regular ? 40 : 20
    }
    
    private var maxContentWidth: CGFloat {
        sizeClass == .regular ? 800 : .infinity
    }
    
    // MARK: - Header
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Your Progress")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(ThemeManager.shared.primaryText)
            
            Text("Tap any habit to see details")
                .font(.system(size: 16))
                .foregroundColor(ThemeManager.shared.secondaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Overview Stats
    private var overviewStatsSection: some View {
        HStack(spacing: 16) {
            StatCard(
                value: "\(totalWinsToday)",
                label: "Today",
                color: .premiumIndigo
            )
            
            StatCard(
                value: "\(currentStreak)",
                label: "Day Streak",
                color: .premiumTeal
            )
            
            StatCard(
                value: "\(totalWins)",
                label: "Total Wins",
                color: .premiumMint
            )
        }
    }
    
    // MARK: - Habit Progress
    private var habitProgressSection: some View {
        Group {
            if sizeClass == .regular {
                // iPad: Grid layout
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 16),
                    GridItem(.flexible(), spacing: 16)
                ], spacing: 16) {
                    ForEach(dataStore.habits) { habit in
                        HabitProgressCard(
                            habit: habit,
                            wins: winsForHabit(habit),
                            onTap: {
                                selectedHabit = habit
                            }
                        )
                    }
                }
            } else {
                // iPhone: Vertical stack
                VStack(spacing: 16) {
                    ForEach(dataStore.habits) { habit in
                        HabitProgressCard(
                            habit: habit,
                            wins: winsForHabit(habit),
                            onTap: {
                                selectedHabit = habit
                            }
                        )
                    }
                }
            }
        }
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 48))
                .foregroundColor(ThemeManager.shared.tertiaryText)
            
            VStack(spacing: 8) {
                Text("No habits yet")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(ThemeManager.shared.primaryText)
                
                Text("Create habits in your profile to track progress")
                    .font(.system(size: 16))
                    .foregroundColor(ThemeManager.shared.secondaryText)
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    // MARK: - Computed Properties
    private var totalWinsToday: Int {
        let calendar = Calendar.current
        let today = Date()
        return dataStore.wins.filter { calendar.isDate($0.timestamp, inSameDayAs: today) }.count
    }
    
    private var currentStreak: Int {
        calculateStreak()
    }
    
    private var totalWins: Int {
        dataStore.wins.count
    }
    
    private func winsForHabit(_ habit: HabitModel) -> [MicroWin] {
        dataStore.wins.filter { $0.habitName == habit.name }
    }
    
    private func calculateStreak() -> Int {
        guard !dataStore.wins.isEmpty else { return 0 }
        
        let calendar = Calendar.current
        let sortedDates = dataStore.wins.map { calendar.startOfDay(for: $0.timestamp) }
            .sorted(by: >)
        
        guard let mostRecent = sortedDates.first,
              calendar.isDateInToday(mostRecent) || calendar.isDateInYesterday(mostRecent) else {
            return 0
        }
        
        var streak = 0
        var currentDate = calendar.isDateInToday(mostRecent) ? mostRecent : calendar.startOfDay(for: Date())
        
        while sortedDates.contains(currentDate) {
            streak += 1
            currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate)!
        }
        
        return streak
    }
}

// MARK: - Stat Card
struct StatCard: View {
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(color)
            
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(ThemeManager.shared.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(ThemeManager.shared.cardBackground)
                .shadow(color: ThemeManager.shared.shadowColor, radius: 4, x: 0, y: 2)
        )
    }
}

// MARK: - Habit Progress Card
struct HabitProgressCard: View {
    let habit: HabitModel
    let wins: [MicroWin]
    let onTap: () -> Void
    
    private var progressInfo: (value: Double, label: String, progress: Double) {
        let calendar = Calendar.current
        let today = Date()
        
        switch habit.trackingType {
        case .check:
            // For CHECK: Show completion rate for the week
            let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date())!
            let recentWins = wins.filter { $0.timestamp > weekAgo }
            let daysWithWins = Set(recentWins.map { calendar.startOfDay(for: $0.timestamp) }).count
            let progress = Double(daysWithWins) / 7.0
            return (Double(daysWithWins), "\(daysWithWins)/7 days", progress)
            
        case .count:
            // For COUNT: Show progress toward target
            if habit.targetPeriod == .daily {
                // Daily target - show today's progress
                let todayWins = wins.filter { calendar.isDate($0.timestamp, inSameDayAs: today) }
                let sum = todayWins.reduce(0) { $0 + (Double($1.value) ?? 0) }
                let target = habit.targetValue ?? 1
                let progress = sum / target
                return (sum, "\(Int(sum))/\(Int(target)) today", min(progress, 1.0))
            } else {
                // Weekly target - show week's progress
                let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date())!
                let weekWins = wins.filter { $0.timestamp > weekAgo }
                let sum = weekWins.reduce(0) { $0 + (Double($1.value) ?? 0) }
                let target = habit.targetValue ?? 1
                let progress = sum / target
                return (sum, "\(Int(sum))/\(Int(target)) this week", min(progress, 1.0))
            }
            
        case .goal:
            // For GOAL: Show total progress toward final goal
            let total = wins.reduce(0) { $0 + (Double($1.value) ?? 0) }
            let target = habit.targetValue ?? 100
            let progress = total / target
            let percentage = Int(progress * 100)
            return (total, "\(percentage)% of goal", min(progress, 1.0))
        }
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 16) {
                HStack {
                    // Icon and name
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(habit.color.opacity(0.1))
                                .frame(width: 40, height: 40)
                            
                            HabitIconView(
                                icon: habit.icon,
                                size: 24,
                                color: habit.color,
                                isComplete: false
                            )
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(habit.name)
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(ThemeManager.shared.primaryText)
                            
                            Text(progressInfo.label)
                                .font(.system(size: 14))
                                .foregroundColor(ThemeManager.shared.secondaryText)
                        }
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14))
                        .foregroundColor(ThemeManager.shared.tertiaryText)
                }
                
                // Progress bar
                VStack(alignment: .leading, spacing: 8) {
                    Text(habit.trackingType == .goal ? "Overall Progress" : 
                         habit.targetPeriod == .weekly ? "Weekly Progress" : "Today's Progress")
                        .font(.system(size: 12))
                        .foregroundColor(ThemeManager.shared.secondaryText)
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(ThemeManager.shared.secondaryBackground)
                            
                            RoundedRectangle(cornerRadius: 8)
                                .fill(
                                    LinearGradient(
                                        colors: [habit.color.opacity(0.6), habit.color],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geometry.size.width * progressInfo.progress)
                                .animation(.spring(), value: progressInfo.progress)
                        }
                    }
                    .frame(height: 8)
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(ThemeManager.shared.cardBackground)
                    .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Habit Detail View
struct HabitDetailView: View {
    let habit: HabitModel
    let wins: [MicroWin]
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var dataStore: IgniteDataStore
    @State private var editingWin: MicroWin?
    @State private var showingDeleteAlert = false
    @State private var winToDelete: MicroWin?
    
    private var habitWins: [MicroWin] {
        wins.filter { $0.habitName == habit.name }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                ThemeManager.shared.backgroundColor
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        // Visual progress circle
                        progressCircleSection
                        
                        // Stats grid
                        statsGridSection
                        
                        // Activity calendar
                        activityCalendarSection
                        
                        // Recent wins
                        recentWinsSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 32)
                }
            }
            .navigationTitle(habit.name)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    // MARK: - Progress Circle
    private var progressCircleSection: some View {
        let progress = calculateProgress()
        
        return ZStack {
            Circle()
                .stroke(ThemeManager.shared.dividerColor, lineWidth: 20)
                .frame(width: 200, height: 200)
            
            Circle()
                .trim(from: 0, to: progress.value)
                .stroke(
                    LinearGradient(
                        colors: [habit.color.opacity(0.6), habit.color],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 20, lineCap: .round)
                )
                .frame(width: 200, height: 200)
                .rotationEffect(.degrees(-90))
                .animation(.spring(), value: progress.value)
            
            VStack(spacing: 8) {
                if habit.trackingType == .goal {
                    Text("\(Int(progress.value * 100))%")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(ThemeManager.shared.primaryText)
                    
                    Text("\(Int(progress.current)) / \(Int(habit.targetValue ?? 0)) \(habit.unit ?? "")")
                        .font(.system(size: 16))
                        .foregroundColor(ThemeManager.shared.secondaryText)
                } else if habit.trackingType == .count {
                    Text("\(Int(progress.current))")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(ThemeManager.shared.primaryText)
                    
                    Text("of \(Int(habit.targetValue ?? 0)) \(progress.label)")
                        .font(.system(size: 16))
                        .foregroundColor(ThemeManager.shared.secondaryText)
                } else {
                    Text("\(Int(progress.value * 100))%")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(ThemeManager.shared.primaryText)
                    
                    Text(progress.label)
                        .font(.system(size: 16))
                        .foregroundColor(ThemeManager.shared.secondaryText)
                }
            }
        }
    }
    
    private func calculateProgress() -> (value: Double, current: Double, label: String) {
        let calendar = Calendar.current
        
        switch habit.trackingType {
        case .check:
            // Weekly completion rate
            let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date())!
            let recentWins = habitWins.filter { $0.timestamp > weekAgo }
            let daysWithWins = Set(recentWins.map { calendar.startOfDay(for: $0.timestamp) }).count
            return (Double(daysWithWins) / 7.0, Double(daysWithWins), "This week")
            
        case .count:
            if habit.targetPeriod == .daily {
                // Today's progress
                let today = Date()
                let todayWins = habitWins.filter { calendar.isDate($0.timestamp, inSameDayAs: today) }
                let sum = todayWins.reduce(0) { $0 + (Double($1.value) ?? 0) }
                let target = habit.targetValue ?? 1
                return (sum / target, sum, "today")
            } else {
                // Weekly progress
                let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date())!
                let weekWins = habitWins.filter { $0.timestamp > weekAgo }
                let sum = weekWins.reduce(0) { $0 + (Double($1.value) ?? 0) }
                let target = habit.targetValue ?? 1
                return (sum / target, sum, "this week")
            }
            
        case .goal:
            // Total progress toward goal
            let total = habitWins.reduce(0) { $0 + (Double($1.value) ?? 0) }
            let target = habit.targetValue ?? 100
            return (total / target, total, "total")
        }
    }
    
    // MARK: - Stats Grid
    private var statsGridSection: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            if habit.trackingType == .check {
                StatBox(label: "Total Days", value: "\(uniqueDays)")
                StatBox(label: "This Month", value: "\(monthlyDays) days")
                StatBox(label: "Best Streak", value: "\(bestStreak) days")
                StatBox(label: "Completion Rate", value: "\(Int(completionRate * 100))%")
            } else if habit.trackingType == .count {
                StatBox(label: "Total \(habit.unit ?? "items")", value: "\(Int(totalValue))")
                StatBox(label: "This Month", value: "\(Int(monthlyValue))")
                StatBox(label: "Daily Average", value: String(format: "%.1f", dailyAverage))
                StatBox(label: "Best Day", value: "\(Int(bestDay))")
            } else { // goal
                StatBox(label: "Progress", value: "\(Int((totalValue / (habit.targetValue ?? 100)) * 100))%")
                StatBox(label: "Completed", value: "\(Int(totalValue)) \(habit.unit ?? "")")
                StatBox(label: "Remaining", value: "\(Int((habit.targetValue ?? 100) - totalValue))")
                StatBox(label: "Daily Rate", value: String(format: "%.1f", dailyAverage))
            }
        }
    }
    
    // MARK: - Activity Calendar
    private var activityCalendarSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("ACTIVITY")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(ThemeManager.shared.secondaryText)
                .tracking(1)
            
            // Simple activity grid for last 30 days
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 7), spacing: 4) {
                ForEach(0..<30, id: \.self) { dayOffset in
                    let date = Calendar.current.date(byAdding: .day, value: -dayOffset, to: Date())!
                    let hasWin = dayHasWin(date)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(hasWin ? habit.color : ThemeManager.shared.secondaryBackground)
                        .frame(height: 40)
                        .overlay(
                            Text("\(Calendar.current.component(.day, from: date))")
                                .font(.system(size: 12))
                                .foregroundColor(hasWin ? .white : ThemeManager.shared.tertiaryText)
                        )
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(ThemeManager.shared.cardBackground)
        )
    }
    
    // MARK: - Recent Wins
    private var recentWinsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("RECENT WINS")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(ThemeManager.shared.secondaryText)
                    .tracking(1)
                
                Spacer()
                
                Text("Swipe to edit")
                    .font(.system(size: 11))
                    .foregroundColor(ThemeManager.shared.tertiaryText)
            }
            
            VStack(spacing: 8) {
                ForEach(habitWins.prefix(10).reversed()) { win in
                    HStack {
                        Circle()
                            .fill(habit.color)
                            .frame(width: 8, height: 8)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("\(win.value) \(win.unit)")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(ThemeManager.shared.primaryText)
                            
                            Text(formatDate(win.timestamp))
                                .font(.system(size: 12))
                                .foregroundColor(ThemeManager.shared.secondaryText)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12))
                            .foregroundColor(ThemeManager.shared.tertiaryText)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(ThemeManager.shared.secondaryBackground.opacity(0.5))
                    )
                    .contextMenu {
                        Button {
                            editingWin = win
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }
                        
                        Button(role: .destructive) {
                            winToDelete = win
                            showingDeleteAlert = true
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            winToDelete = win
                            showingDeleteAlert = true
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        
                        Button {
                            editingWin = win
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }
                        .tint(.blue)
                    }
                }
            }
        }
        .sheet(item: $editingWin) { win in
            EditWinView(win: win, habit: habit, dataStore: dataStore)
        }
        .alert("Delete Win?", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                if let win = winToDelete {
                    dataStore.deleteWin(win)
                }
            }
        } message: {
            Text("This action cannot be undone.")
        }
    }
    
    // MARK: - Computed Properties
    private var totalValue: Double {
        habitWins.reduce(0) { $0 + (Double($1.value) ?? 0) }
    }
    
    private var monthlyValue: Double {
        let calendar = Calendar.current
        let monthAgo = calendar.date(byAdding: .month, value: -1, to: Date())!
        return habitWins.filter { $0.timestamp > monthAgo }
            .reduce(0) { $0 + (Double($1.value) ?? 0) }
    }
    
    private var uniqueDays: Int {
        let calendar = Calendar.current
        return Set(habitWins.map { calendar.startOfDay(for: $0.timestamp) }).count
    }
    
    private var monthlyDays: Int {
        let calendar = Calendar.current
        let monthAgo = calendar.date(byAdding: .month, value: -1, to: Date())!
        let monthWins = habitWins.filter { $0.timestamp > monthAgo }
        return Set(monthWins.map { calendar.startOfDay(for: $0.timestamp) }).count
    }
    
    private var dailyAverage: Double {
        guard uniqueDays > 0 else { return 0 }
        return totalValue / Double(uniqueDays)
    }
    
    private var bestDay: Double {
        let calendar = Calendar.current
        let groupedByDay = Dictionary(grouping: habitWins) { win in
            calendar.startOfDay(for: win.timestamp)
        }
        return groupedByDay.values.map { wins in
            wins.reduce(0) { $0 + (Double($1.value) ?? 0) }
        }.max() ?? 0
    }
    
    private var completionRate: Double {
        let calendar = Calendar.current
        guard let firstWin = habitWins.first else { return 0 }
        let daysSinceFirst = calendar.dateComponents([.day], from: firstWin.timestamp, to: Date()).day ?? 1
        return Double(uniqueDays) / Double(max(daysSinceFirst, 1))
    }
    
    private var bestStreak: Int {
        let calendar = Calendar.current
        let sortedDates = habitWins.map { calendar.startOfDay(for: $0.timestamp) }
            .sorted()
            .removingDuplicates()
        
        guard !sortedDates.isEmpty else { return 0 }
        
        var maxStreak = 1
        var currentStreak = 1
        
        for i in 1..<sortedDates.count {
            if calendar.dateComponents([.day], from: sortedDates[i-1], to: sortedDates[i]).day == 1 {
                currentStreak += 1
                maxStreak = max(maxStreak, currentStreak)
            } else {
                currentStreak = 1
            }
        }
        
        return maxStreak
    }
    
    private func dayHasWin(_ date: Date) -> Bool {
        let calendar = Calendar.current
        return habitWins.contains { win in
            calendar.isDate(win.timestamp, inSameDayAs: date)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Stat Box
struct StatBox: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(ThemeManager.shared.primaryText)
            
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(ThemeManager.shared.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(ThemeManager.shared.secondaryBackground.opacity(0.5))
        )
    }
}

// MARK: - Edit Win View
struct EditWinView: View {
    let win: MicroWin
    let habit: HabitModel
    let dataStore: IgniteDataStore
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var value: String
    @State private var selectedDate: Date
    @State private var selectedTime: Date
    
    init(win: MicroWin, habit: HabitModel, dataStore: IgniteDataStore) {
        self.win = win
        self.habit = habit
        self.dataStore = dataStore
        _value = State(initialValue: win.value)
        _selectedDate = State(initialValue: win.timestamp)
        _selectedTime = State(initialValue: win.timestamp)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                (colorScheme == .dark ? Color(UIColor.systemBackground) : ThemeManager.shared.backgroundColor)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Icon
                        ZStack {
                            Circle()
                                .fill(habit.color.opacity(0.1))
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: habit.icon)
                                .font(.system(size: 40))
                                .foregroundColor(habit.color)
                        }
                        .padding(.top)
                        
                        // Value input
                        if habit.trackingType != .check {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("VALUE")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(ThemeManager.shared.secondaryText)
                                    .tracking(1)
                                
                                HStack {
                                    TextField("Value", text: $value)
                                        .keyboardType(.decimalPad)
                                        .font(.system(size: 18))
                                        .foregroundColor(.primary)
                                    
                                    Text(habit.unit ?? "")
                                        .font(.system(size: 16))
                                        .foregroundColor(ThemeManager.shared.secondaryText)
                                }
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(UIColor.secondarySystemBackground))
                                )
                            }
                        }
                        
                        // Date picker
                        VStack(alignment: .leading, spacing: 8) {
                            Text("DATE")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(ThemeManager.shared.secondaryText)
                                .tracking(1)
                            
                            DatePicker("", selection: $selectedDate, displayedComponents: .date)
                                .datePickerStyle(GraphicalDatePickerStyle())
                                .padding(8)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(UIColor.secondarySystemBackground))
                                )
                        }
                        
                        // Time picker
                        VStack(alignment: .leading, spacing: 8) {
                            Text("TIME")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(ThemeManager.shared.secondaryText)
                                .tracking(1)
                            
                            DatePicker("", selection: $selectedTime, displayedComponents: .hourAndMinute)
                                .datePickerStyle(WheelDatePickerStyle())
                                .frame(height: 120)
                                .padding(8)
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
            .navigationTitle("Edit Win")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveChanges()
                    }
                    .disabled(value.isEmpty && habit.trackingType != .check)
                }
            }
        }
    }
    
    private func saveChanges() {
        // Combine date and time
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: selectedDate)
        let timeComponents = calendar.dateComponents([.hour, .minute], from: selectedTime)
        
        var newComponents = DateComponents()
        newComponents.year = dateComponents.year
        newComponents.month = dateComponents.month
        newComponents.day = dateComponents.day
        newComponents.hour = timeComponents.hour
        newComponents.minute = timeComponents.minute
        
        let newTimestamp = calendar.date(from: newComponents) ?? Date()
        
        // Create updated win
        let updatedWin = MicroWin(
            id: win.id,
            habitName: win.habitName,
            value: value,
            unit: win.unit,
            icon: win.icon,
            color: win.color,
            timestamp: newTimestamp
        )
        
        dataStore.updateWin(updatedWin)
        dismiss()
    }
}