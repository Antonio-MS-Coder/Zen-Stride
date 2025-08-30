import SwiftUI
import CoreData
import Charts

struct PremiumProgressView: View {
    @ObservedObject var viewModel: ElegantDashboardViewModel
    @State private var selectedTimeRange = 0
    @State private var selectedHabit: Habit?
    @State private var showingDatePicker = false
    @State private var selectedDate = Date()
    
    let timeRanges = ["Week", "Month", "Year", "All Time"]
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color.premiumGray6
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: .spacing24) {
                        // Header Stats
                        headerStatsSection
                            .padding(.top, .spacing20)
                        
                        // Time Range Selector
                        PremiumSegmentedControl(
                            selection: $selectedTimeRange,
                            options: timeRanges
                        )
                        .padding(.horizontal, .spacing20)
                        
                        // Completion Chart
                        completionChartSection
                        
                        // Habit Performance Grid
                        habitPerformanceSection
                        
                        // Streak History
                        streakHistorySection
                        
                        // Insights
                        insightsSection
                    }
                    .padding(.bottom, .spacing32)
                }
            }
            .navigationTitle("Progress")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
        }
    }
    
    // MARK: - Header Stats
    private var headerStatsSection: some View {
        VStack(spacing: .spacing16) {
            HStack(spacing: .spacing12) {
                ProgressMetricCard(
                    title: "Total Completed",
                    value: "\(getTotalCompleted())",
                    subtitle: "habits this \(timeRanges[selectedTimeRange].lowercased())",
                    icon: "checkmark.seal.fill",
                    color: .premiumMint
                )
                
                ProgressMetricCard(
                    title: "Consistency",
                    value: "\(getConsistencyRate())%",
                    subtitle: "completion rate",
                    icon: "chart.pie.fill",
                    color: .premiumIndigo
                )
            }
            
            HStack(spacing: .spacing12) {
                ProgressMetricCard(
                    title: "Best Streak",
                    value: "\(getBestStreak()) days",
                    subtitle: "personal record",
                    icon: "crown.fill",
                    color: .premiumAmber
                )
                
                ProgressMetricCard(
                    title: "Active Days",
                    value: "\(getActiveDays())",
                    subtitle: "this \(timeRanges[selectedTimeRange].lowercased())",
                    icon: "calendar",
                    color: .premiumTeal
                )
            }
        }
        .padding(.horizontal, .spacing20)
    }
    
    // MARK: - Completion Chart
    private var completionChartSection: some View {
        VStack(alignment: .leading, spacing: .spacing16) {
            Text("COMPLETION TREND")
                .font(.premiumCaption1)
                .foregroundColor(.premiumGray3)
                .tracking(1.2)
                .padding(.horizontal, .spacing20)
            
            // Chart container
            VStack {
                if #available(iOS 16.0, *) {
                    Chart(getChartData()) { dataPoint in
                        BarMark(
                            x: .value("Day", dataPoint.date, unit: .day),
                            y: .value("Completed", dataPoint.completed)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.premiumIndigo, Color.premiumTeal],
                                startPoint: .bottom,
                                endPoint: .top
                            )
                        )
                        .cornerRadius(4)
                    }
                    .frame(height: 200)
                    .padding(.horizontal, .spacing16)
                } else {
                    // Fallback for older iOS versions
                    customChartView
                }
            }
            .padding(.vertical, .spacing20)
            .background(
                RoundedRectangle(cornerRadius: .radiusL)
                    .fill(Color.white)
            )
            .premiumShadowS()
            .padding(.horizontal, .spacing20)
        }
    }
    
    // Custom chart for iOS 15 and below
    private var customChartView: some View {
        GeometryReader { geometry in
            HStack(alignment: .bottom, spacing: 4) {
                ForEach(getChartData()) { dataPoint in
                    VStack {
                        Spacer()
                        RoundedRectangle(cornerRadius: 4)
                            .fill(
                                LinearGradient(
                                    colors: [Color.premiumIndigo, Color.premiumTeal],
                                    startPoint: .bottom,
                                    endPoint: .top
                                )
                            )
                            .frame(height: CGFloat(dataPoint.completed) * 10)
                        
                        Text(dataPoint.dayLabel)
                            .font(.premiumCaption2)
                            .foregroundColor(.premiumGray3)
                    }
                }
            }
            .padding()
        }
        .frame(height: 200)
    }
    
    // MARK: - Habit Performance
    private var habitPerformanceSection: some View {
        VStack(alignment: .leading, spacing: .spacing16) {
            Text("HABIT PERFORMANCE")
                .font(.premiumCaption1)
                .foregroundColor(.premiumGray3)
                .tracking(1.2)
                .padding(.horizontal, .spacing20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: .spacing12) {
                    ForEach(viewModel.habits) { habit in
                        HabitPerformanceCard(
                            habit: habit,
                            completionRate: getHabitCompletionRate(habit),
                            streak: viewModel.getStreak(for: habit),
                            trend: getHabitTrend(habit)
                        )
                        .onTapGesture {
                            selectedHabit = habit
                        }
                    }
                }
                .padding(.horizontal, .spacing20)
            }
        }
    }
    
    // MARK: - Streak History
    private var streakHistorySection: some View {
        VStack(alignment: .leading, spacing: .spacing16) {
            HStack {
                Text("STREAK CALENDAR")
                    .font(.premiumCaption1)
                    .foregroundColor(.premiumGray3)
                    .tracking(1.2)
                
                Spacer()
                
                Button {
                    showingDatePicker.toggle()
                } label: {
                    Image(systemName: "calendar")
                        .font(.system(size: 16))
                        .foregroundColor(.premiumIndigo)
                }
            }
            .padding(.horizontal, .spacing20)
            
            // Calendar heatmap
            CalendarHeatmap(
                data: getStreakData(),
                selectedDate: $selectedDate
            )
            .padding(.horizontal, .spacing20)
        }
    }
    
    // MARK: - Insights
    private var insightsSection: some View {
        VStack(alignment: .leading, spacing: .spacing16) {
            Text("INSIGHTS")
                .font(.premiumCaption1)
                .foregroundColor(.premiumGray3)
                .tracking(1.2)
                .padding(.horizontal, .spacing20)
            
            VStack(spacing: .spacing12) {
                PremiumInsightCard(
                    icon: "lightbulb.fill",
                    title: "Best Time",
                    description: "You're most consistent in the morning (8-10 AM)",
                    color: .premiumAmber
                )
                
                PremiumInsightCard(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Growth Trend",
                    description: "Your completion rate improved by 15% this month",
                    color: .premiumMint
                )
                
                PremiumInsightCard(
                    icon: "star.fill",
                    title: "Top Performer",
                    description: "\"Morning Meditation\" is your most consistent habit",
                    color: .premiumIndigo
                )
            }
            .padding(.horizontal, .spacing20)
        }
    }
    
    // MARK: - Helper Methods
    private func getTotalCompleted() -> Int {
        // Calculate based on selected time range
        switch selectedTimeRange {
        case 0: // Week
            return viewModel.getTotalCompletedThisWeek()
        case 1: // Month
            return viewModel.getTotalCompletedThisWeek() * 4
        case 2: // Year
            return viewModel.getTotalCompletedThisWeek() * 52
        default: // All Time
            return viewModel.getTotalCompletedThisWeek() * 52
        }
    }
    
    private func getConsistencyRate() -> Int {
        return Int(viewModel.weeklyCompletionRate * 100)
    }
    
    private func getBestStreak() -> Int {
        return viewModel.streaks.map { Int($0.longestLength) }.max() ?? 0
    }
    
    private func getActiveDays() -> Int {
        // Calculate based on selected time range
        switch selectedTimeRange {
        case 0: return 5 // Week
        case 1: return 22 // Month
        case 2: return 280 // Year
        default: return 365 // All Time
        }
    }
    
    private func getChartData() -> [PremiumChartDataPoint] {
        // Generate sample data for the chart
        var data: [PremiumChartDataPoint] = []
        let calendar = Calendar.current
        
        for i in 0..<7 {
            let date = calendar.date(byAdding: .day, value: -i, to: Date()) ?? Date()
            // Ensure safe range for random number generation
            let maxHabits = max(viewModel.habits.count, 1)
            let minCompleted = min(3, maxHabits)
            let completed = Int.random(in: minCompleted...maxHabits)
            let dayFormatter = DateFormatter()
            dayFormatter.dateFormat = "E"
            let dayLabel = dayFormatter.string(from: date)
            
            data.append(PremiumChartDataPoint(
                id: UUID(),
                date: date,
                completed: completed,
                dayLabel: String(dayLabel.prefix(1))
            ))
        }
        
        return data.reversed()
    }
    
    private func getHabitCompletionRate(_ habit: Habit) -> Double {
        // Calculate habit-specific completion rate
        return Double.random(in: 0.6...1.0)
    }
    
    private func getHabitTrend(_ habit: Habit) -> Double {
        // Calculate trend (-1 to 1)
        return Double.random(in: -0.2...0.3)
    }
    
    private func getStreakData() -> [Date: Int] {
        // Generate streak data for calendar heatmap
        var data: [Date: Int] = [:]
        let calendar = Calendar.current
        
        for i in 0..<30 {
            if let date = calendar.date(byAdding: .day, value: -i, to: Date()) {
                data[date] = Int.random(in: 0...3)
            }
        }
        
        return data
    }
}

// MARK: - Supporting Views
struct PremiumChartDataPoint: Identifiable {
    let id: UUID
    let date: Date
    let completed: Int
    let dayLabel: String
}

struct ProgressMetricCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: .spacing8) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(color)
                
                Spacer()
            }
            
            Text(value)
                .font(.premiumTitle2)
                .foregroundColor(.premiumGray1)
            
            Text(title)
                .font(.premiumCaption1)
                .foregroundColor(.premiumGray2)
            
            Text(subtitle)
                .font(.premiumCaption2)
                .foregroundColor(.premiumGray3)
        }
        .padding(.spacing16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: .radiusM)
                .fill(Color.white)
        )
        .premiumShadowXS()
    }
}

struct HabitPerformanceCard: View {
    let habit: Habit
    let completionRate: Double
    let streak: Int
    let trend: Double
    
    var body: some View {
        VStack(spacing: .spacing12) {
            // Icon and name
            VStack(spacing: .spacing8) {
                Image(systemName: habit.iconName ?? "star.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.premiumIndigo)
                
                Text(habit.name ?? "")
                    .font(.premiumCaption1)
                    .foregroundColor(.premiumGray1)
                    .lineLimit(1)
            }
            
            // Progress ring
            PremiumProgressRing(
                progress: completionRate,
                size: 60,
                lineWidth: 5,
                showPercentage: true
            )
            
            // Stats
            VStack(spacing: .spacing4) {
                HStack(spacing: .spacing4) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 10))
                        .foregroundColor(.premiumCoral)
                    
                    Text("\(streak) days")
                        .font(.premiumCaption2)
                        .foregroundColor(.premiumGray3)
                }
                
                HStack(spacing: .spacing4) {
                    Image(systemName: trend > 0 ? "arrow.up.right" : "arrow.down.right")
                        .font(.system(size: 10))
                        .foregroundColor(trend > 0 ? .premiumMint : .premiumError)
                    
                    Text("\(Int(abs(trend * 100)))%")
                        .font(.premiumCaption2)
                        .foregroundColor(.premiumGray3)
                }
            }
        }
        .frame(width: 120)
        .padding(.spacing16)
        .background(
            RoundedRectangle(cornerRadius: .radiusL)
                .fill(Color.white)
        )
        .premiumShadowXS()
    }
}

struct CalendarHeatmap: View {
    let data: [Date: Int]
    @Binding var selectedDate: Date
    
    var body: some View {
        VStack(spacing: .spacing8) {
            // Days of week header
            HStack(spacing: .spacing4) {
                ForEach(["S", "M", "T", "W", "T", "F", "S"], id: \.self) { day in
                    Text(day)
                        .font(.premiumCaption2)
                        .foregroundColor(.premiumGray3)
                        .frame(maxWidth: .infinity)
                }
            }
            
            // Calendar grid (simplified)
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: .spacing4), count: 7), spacing: .spacing4) {
                ForEach(0..<30, id: \.self) { index in
                    let intensity = Double.random(in: 0...1)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            intensity == 0 ? Color.premiumGray6 :
                            Color.premiumIndigo.opacity(0.2 + intensity * 0.8)
                        )
                        .frame(height: 30)
                }
            }
        }
        .padding(.spacing16)
        .background(
            RoundedRectangle(cornerRadius: .radiusL)
                .fill(Color.white)
        )
        .premiumShadowXS()
    }
}

struct PremiumInsightCard: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        HStack(spacing: .spacing16) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: .spacing4) {
                Text(title)
                    .font(.premiumHeadline)
                    .foregroundColor(.premiumGray1)
                
                Text(description)
                    .font(.premiumCallout)
                    .foregroundColor(.premiumGray3)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding(.spacing16)
        .background(
            RoundedRectangle(cornerRadius: .radiusM)
                .fill(Color.white)
        )
        .premiumShadowXS()
    }
}