import SwiftUI

struct ProgressOverviewView: View {
    @Binding var habits: [Habit]
    @Binding var wins: [MicroWin]
    @State private var selectedHabit: Habit?
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.premiumGray6
                    .ignoresSafeArea()
                
                if habits.isEmpty {
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
                        .padding(.horizontal, 20)
                        .padding(.top, 60)
                        .padding(.bottom, 100)
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(item: $selectedHabit) { habit in
                HabitDetailView(habit: habit, wins: wins)
            }
        }
    }
    
    // MARK: - Header
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Your Progress")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(.premiumGray1)
            
            Text("Tap any habit to see details")
                .font(.system(size: 16))
                .foregroundColor(.premiumGray3)
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
        VStack(spacing: 16) {
            ForEach(habits) { habit in
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
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 48))
                .foregroundColor(.premiumGray4)
            
            VStack(spacing: 8) {
                Text("No habits yet")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.premiumGray2)
                
                Text("Create habits in your profile to track progress")
                    .font(.system(size: 16))
                    .foregroundColor(.premiumGray3)
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    // MARK: - Computed Properties
    private var totalWinsToday: Int {
        let calendar = Calendar.current
        let today = Date()
        return wins.filter { calendar.isDate($0.timestamp, inSameDayAs: today) }.count
    }
    
    private var currentStreak: Int {
        calculateStreak()
    }
    
    private var totalWins: Int {
        wins.count
    }
    
    private func winsForHabit(_ habit: Habit) -> [MicroWin] {
        wins.filter { $0.habitName == habit.name }
    }
    
    private func calculateStreak() -> Int {
        guard !wins.isEmpty else { return 0 }
        
        let calendar = Calendar.current
        let sortedDates = wins.map { calendar.startOfDay(for: $0.timestamp) }
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
                .foregroundColor(.premiumGray3)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
    }
}

// MARK: - Habit Progress Card
struct HabitProgressCard: View {
    let habit: Habit
    let wins: [MicroWin]
    let onTap: () -> Void
    
    private var weeklyProgress: Double {
        let calendar = Calendar.current
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date())!
        let recentWins = wins.filter { $0.timestamp > weekAgo }
        return min(Double(recentWins.count) / 7.0, 1.0)
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 16) {
                HStack {
                    // Icon and name
                    HStack(spacing: 12) {
                        Image(systemName: habit.icon)
                            .font(.system(size: 24))
                            .foregroundColor(habit.color)
                            .frame(width: 40, height: 40)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(habit.name)
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.premiumGray1)
                            
                            Text("\(wins.count) total wins")
                                .font(.system(size: 14))
                                .foregroundColor(.premiumGray3)
                        }
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14))
                        .foregroundColor(.premiumGray4)
                }
                
                // Weekly progress bar
                VStack(alignment: .leading, spacing: 8) {
                    Text("This week")
                        .font(.system(size: 12))
                        .foregroundColor(.premiumGray3)
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.premiumGray6)
                            
                            RoundedRectangle(cornerRadius: 8)
                                .fill(
                                    LinearGradient(
                                        colors: [habit.color.opacity(0.6), habit.color],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geometry.size.width * weeklyProgress)
                                .animation(.spring(), value: weeklyProgress)
                        }
                    }
                    .frame(height: 8)
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Habit Detail View
struct HabitDetailView: View {
    let habit: Habit
    let wins: [MicroWin]
    @Environment(\.dismiss) private var dismiss
    
    private var habitWins: [MicroWin] {
        wins.filter { $0.habitName == habit.name }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.premiumGray6
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
        ZStack {
            Circle()
                .stroke(Color.premiumGray5, lineWidth: 20)
                .frame(width: 200, height: 200)
            
            Circle()
                .trim(from: 0, to: weeklyCompletion)
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
                .animation(.spring(), value: weeklyCompletion)
            
            VStack(spacing: 8) {
                Text("\(Int(weeklyCompletion * 100))%")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(.premiumGray1)
                
                Text("This week")
                    .font(.system(size: 16))
                    .foregroundColor(.premiumGray3)
            }
        }
    }
    
    // MARK: - Stats Grid
    private var statsGridSection: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            StatBox(label: "Total Wins", value: "\(habitWins.count)")
            StatBox(label: "This Month", value: "\(monthlyWins)")
            StatBox(label: "Best Streak", value: "\(bestStreak) days")
            StatBox(label: "Average/Week", value: String(format: "%.1f", weeklyAverage))
        }
    }
    
    // MARK: - Activity Calendar
    private var activityCalendarSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("ACTIVITY")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.premiumGray3)
                .tracking(1)
            
            // Simple activity grid for last 30 days
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 7), spacing: 4) {
                ForEach(0..<30, id: \.self) { dayOffset in
                    let date = Calendar.current.date(byAdding: .day, value: -dayOffset, to: Date())!
                    let hasWin = dayHasWin(date)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(hasWin ? habit.color : Color.premiumGray6)
                        .frame(height: 40)
                        .overlay(
                            Text("\(Calendar.current.component(.day, from: date))")
                                .font(.system(size: 12))
                                .foregroundColor(hasWin ? .white : .premiumGray4)
                        )
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
        )
    }
    
    // MARK: - Recent Wins
    private var recentWinsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("RECENT WINS")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.premiumGray3)
                .tracking(1)
            
            VStack(spacing: 8) {
                ForEach(habitWins.prefix(5).reversed()) { win in
                    HStack {
                        Circle()
                            .fill(habit.color)
                            .frame(width: 8, height: 8)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("\(win.value) \(win.unit)")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.premiumGray1)
                            
                            Text(formatDate(win.timestamp))
                                .font(.system(size: 12))
                                .foregroundColor(.premiumGray3)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.premiumGray6.opacity(0.5))
                    )
                }
            }
        }
    }
    
    // MARK: - Computed Properties
    private var weeklyCompletion: Double {
        let calendar = Calendar.current
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date())!
        let recentWins = habitWins.filter { $0.timestamp > weekAgo }
        return min(Double(recentWins.count) / 7.0, 1.0)
    }
    
    private var monthlyWins: Int {
        let calendar = Calendar.current
        let monthAgo = calendar.date(byAdding: .month, value: -1, to: Date())!
        return habitWins.filter { $0.timestamp > monthAgo }.count
    }
    
    private var bestStreak: Int {
        // Simplified streak calculation
        return 7 // You can implement more complex logic here
    }
    
    private var weeklyAverage: Double {
        guard !habitWins.isEmpty else { return 0 }
        let weeks = Double(habitWins.count) / 7.0
        return Double(habitWins.count) / max(weeks, 1)
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
                .foregroundColor(.premiumGray1)
            
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.premiumGray3)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.premiumGray6.opacity(0.5))
        )
    }
}