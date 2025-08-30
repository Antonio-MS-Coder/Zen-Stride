import SwiftUI
import Charts
import CoreData

struct ElegantProgressView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel: ProgressViewModel
    @State private var selectedTimeRange = TimeRange.week
    @State private var selectedHabit: Habit?
    
    init(context: NSManagedObjectContext) {
        _viewModel = StateObject(wrappedValue: ProgressViewModel(context: context))
    }
    
    enum TimeRange: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case quarter = "Quarter"
        case year = "Year"
        
        var days: Int {
            switch self {
            case .week: return 7
            case .month: return 30
            case .quarter: return 90
            case .year: return 365
            }
        }
        
        var chartInterval: Calendar.Component {
            switch self {
            case .week: return .day
            case .month: return .day
            case .quarter: return .weekOfYear
            case .year: return .month
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: .zen24) {
                    // Time Range Selector
                    timeRangeSelector
                    
                    // Habit Filter
                    if !viewModel.habits.isEmpty {
                        habitFilter
                    }
                    
                    // Overall Progress Card
                    overallProgressCard
                    
                    // Progress Chart
                    progressChart
                    
                    // Habit Breakdown
                    if selectedHabit == nil {
                        habitBreakdown
                    }
                    
                    // Insights
                    insightsSection
                }
                .padding(.horizontal, .zen20)
                .padding(.vertical, .zen16)
            }
            .background(Color.zenBackground)
            .navigationTitle("Progress")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
        }
        .onAppear {
            viewModel.loadData(for: selectedTimeRange.days)
        }
        .onChange(of: selectedTimeRange) { _, newValue in
            viewModel.loadData(for: newValue.days)
        }
        .onChange(of: selectedHabit) { _, _ in
            viewModel.loadData(for: selectedTimeRange.days, habit: selectedHabit)
        }
    }
    
    // MARK: - Components
    
    private var timeRangeSelector: some View {
        Picker("Time Range", selection: $selectedTimeRange) {
            ForEach(TimeRange.allCases, id: \.self) { range in
                Text(range.rawValue).tag(range)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
    }
    
    private var habitFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: .zen8) {
                ProgressFilterChip(
                    title: "All Habits",
                    isSelected: selectedHabit == nil,
                    color: .zenPrimary
                ) {
                    selectedHabit = nil
                }
                
                ForEach(viewModel.habits) { habit in
                    ProgressFilterChip(
                        title: habit.name ?? "",
                        isSelected: selectedHabit == habit,
                        color: colorForCategory(habit.category ?? "")
                    ) {
                        selectedHabit = habit
                    }
                }
            }
        }
    }
    
    private var overallProgressCard: some View {
        HStack(spacing: .zen20) {
            // Completion Rate
            VStack(alignment: .leading, spacing: .zen8) {
                Text("Completion")
                    .font(.zenCaption)
                    .foregroundColor(.zenTextSecondary)
                
                HStack(alignment: .firstTextBaseline, spacing: .zen4) {
                    Text("\(Int(viewModel.overallCompletionRate * 100))")
                        .font(.zenNumber)
                        .foregroundColor(.zenTextPrimary)
                    Text("%")
                        .font(.zenTitle)
                        .foregroundColor(.zenTextSecondary)
                }
                
                HStack(spacing: .zen4) {
                    Image(systemName: viewModel.trend > 0 ? "arrow.up.right" : "arrow.down.right")
                        .font(.system(size: 12))
                    Text("\(abs(viewModel.trend))% vs last period")
                        .font(.zenFootnote)
                }
                .foregroundColor(viewModel.trend > 0 ? .zenSuccess : .zenError)
            }
            
            Spacer()
            
            // Visual Progress Ring
            ZenProgressRing(
                progress: viewModel.overallCompletionRate,
                size: 80,
                lineWidth: 8
            )
        }
        .padding(.zen20)
        .zenCard()
    }
    
    private var progressChart: some View {
        VStack(alignment: .leading, spacing: .zen16) {
            Text("Progress Over Time")
                .font(.zenSubheadline)
                .foregroundColor(.zenTextPrimary)
            
            if !viewModel.chartData.isEmpty {
                Chart(viewModel.chartData) { dataPoint in
                    if selectedTimeRange == .week || selectedTimeRange == .month {
                        BarMark(
                            x: .value("Date", dataPoint.date, unit: .day),
                            y: .value("Completed", dataPoint.value)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.zenPrimary, Color.zenSecondary],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .cornerRadius(4)
                    } else {
                        LineMark(
                            x: .value("Date", dataPoint.date, unit: selectedTimeRange.chartInterval),
                            y: .value("Completed", dataPoint.value)
                        )
                        .foregroundStyle(Color.zenPrimary)
                        .lineStyle(StrokeStyle(lineWidth: 2))
                        
                        AreaMark(
                            x: .value("Date", dataPoint.date, unit: selectedTimeRange.chartInterval),
                            y: .value("Completed", dataPoint.value)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.zenPrimary.opacity(0.3), Color.clear],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    }
                }
                .frame(height: 200)
                .chartXAxis {
                    AxisMarks(values: .stride(by: selectedTimeRange.chartInterval)) { _ in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                            .foregroundStyle(Color.zenCloud)
                        AxisValueLabel(format: formatForTimeRange())
                            .font(.zenFootnote)
                    }
                }
                .chartYAxis {
                    AxisMarks { _ in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                            .foregroundStyle(Color.zenCloud)
                        AxisValueLabel()
                            .font(.zenFootnote)
                    }
                }
            } else {
                RoundedRectangle(cornerRadius: .zenRadiusMedium)
                    .fill(Color.zenCloud)
                    .frame(height: 200)
                    .overlay(
                        Text("No data available")
                            .font(.zenCaption)
                            .foregroundColor(.zenTextTertiary)
                    )
            }
        }
        .padding(.zen20)
        .zenCard()
    }
    
    private var habitBreakdown: some View {
        VStack(alignment: .leading, spacing: .zen16) {
            Text("Habit Performance")
                .font(.zenSubheadline)
                .foregroundColor(.zenTextPrimary)
            
            VStack(spacing: .zen12) {
                ForEach(viewModel.habitStats) { stat in
                    HabitPerformanceRow(stat: stat)
                }
            }
        }
        .padding(.zen20)
        .zenCard()
    }
    
    private var insightsSection: some View {
        VStack(alignment: .leading, spacing: .zen16) {
            Text("Insights")
                .font(.zenSubheadline)
                .foregroundColor(.zenTextPrimary)
            
            VStack(spacing: .zen12) {
                InsightCard(
                    icon: "sun.max.fill",
                    title: "Best Day",
                    value: viewModel.bestDay,
                    color: .zenTertiary
                )
                
                InsightCard(
                    icon: "flame.fill",
                    title: "Longest Streak",
                    value: "\(viewModel.longestStreak) days",
                    color: .zenSecondary
                )
                
                InsightCard(
                    icon: "star.fill",
                    title: "Most Consistent",
                    value: viewModel.mostConsistentHabit,
                    color: .zenPrimary
                )
                
                if let improvement = viewModel.improvementSuggestion {
                    InsightCard(
                        icon: "lightbulb.fill",
                        title: "Suggestion",
                        value: improvement,
                        color: .zenWarning
                    )
                }
            }
        }
        .padding(.zen20)
        .zenCard()
    }
    
    // MARK: - Helpers
    
    private func formatForTimeRange() -> Date.FormatStyle {
        switch selectedTimeRange {
        case .week:
            return .dateTime.weekday(.abbreviated)
        case .month:
            return .dateTime.day()
        case .quarter:
            return .dateTime.week()
        case .year:
            return .dateTime.month(.abbreviated)
        }
    }
    
    private func colorForCategory(_ category: String) -> Color {
        switch category.lowercased() {
        case "health": return .zenError
        case "fitness": return .zenSecondary
        case "mindfulness": return .zenSuccess
        case "learning": return .zenPrimary
        case "creativity": return .purple
        case "productivity": return .zenTertiary
        default: return .zenPrimary
        }
    }
}

// MARK: - Supporting Views

struct ProgressFilterChip: View {
    let title: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.zenCaption)
                .foregroundColor(isSelected ? .white : color)
                .padding(.horizontal, .zen12)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: .zenRadiusSmall)
                        .fill(isSelected ? color : color.opacity(0.1))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: .zenRadiusSmall)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct HabitPerformanceRow: View {
    let stat: HabitStat
    
    var body: some View {
        HStack(spacing: .zen12) {
            Circle()
                .fill(stat.color)
                .frame(width: 8, height: 8)
            
            Text(stat.name)
                .font(.zenBody)
                .foregroundColor(.zenTextPrimary)
            
            Spacer()
            
            Text("\(Int(stat.completionRate * 100))%")
                .font(.zenBody)
                .foregroundColor(.zenTextSecondary)
            
            // Mini progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.zenCloud)
                    
                    RoundedRectangle(cornerRadius: 2)
                        .fill(stat.color)
                        .frame(width: geometry.size.width * stat.completionRate)
                }
            }
            .frame(width: 60, height: 4)
        }
    }
}

struct InsightCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: .zen12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: .zen4) {
                Text(title)
                    .font(.zenCaption)
                    .foregroundColor(.zenTextTertiary)
                
                Text(value)
                    .font(.zenBody)
                    .foregroundColor(.zenTextPrimary)
            }
            
            Spacer()
        }
        .padding(.zen12)
        .background(color.opacity(0.05))
        .cornerRadius(.zenRadiusSmall)
    }
}

// MARK: - View Model

class ProgressViewModel: ObservableObject {
    private let habitService: HabitService
    private let viewContext: NSManagedObjectContext
    
    @Published var habits: [Habit] = []
    @Published var chartData: [ProgressChartDataPoint] = []
    @Published var habitStats: [HabitStat] = []
    @Published var overallCompletionRate: Double = 0
    @Published var trend: Int = 0
    @Published var bestDay = "Monday"
    @Published var longestStreak = 0
    @Published var mostConsistentHabit = "Morning Meditation"
    @Published var improvementSuggestion: String?
    
    init(context: NSManagedObjectContext) {
        self.viewContext = context
        self.habitService = HabitService(context: context)
        loadData(for: 7)
    }
    
    func loadData(for days: Int, habit: Habit? = nil) {
        habitService.fetchHabits()
        habits = habitService.habits
        
        if let habit = habit {
            loadHabitData(habit: habit, days: days)
        } else {
            loadOverallData(days: days)
        }
        
        calculateInsights(days: days)
    }
    
    private func loadOverallData(days: Int) {
        let calendar = Calendar.current
        let endDate = Date()
        _ = calendar.date(byAdding: .day, value: -days, to: endDate)!
        
        // Generate chart data
        var data: [ProgressChartDataPoint] = []
        var totalCompleted = 0
        var totalPossible = 0
        
        for dayOffset in 0..<days {
            if let date = calendar.date(byAdding: .day, value: -dayOffset, to: endDate) {
                let dayStart = calendar.startOfDay(for: date)
                var completedCount = 0
                
                for habit in habits {
                    if let progress = habitService.getProgress(for: habit, on: dayStart),
                       progress.isComplete {
                        completedCount += 1
                    }
                }
                
                data.append(ProgressChartDataPoint(date: dayStart, value: Double(completedCount)))
                totalCompleted += completedCount
                totalPossible += habits.count
            }
        }
        
        chartData = data.reversed()
        overallCompletionRate = totalPossible > 0 ? Double(totalCompleted) / Double(totalPossible) : 0
        
        // Calculate habit stats
        habitStats = habits.map { habit in
            let rate = habitService.getCompletionRate(for: habit, days: days)
            return HabitStat(
                id: habit.id ?? UUID(),
                name: habit.name ?? "",
                completionRate: rate,
                color: colorForCategory(habit.category ?? "")
            )
        }.sorted { $0.completionRate > $1.completionRate }
        
        // Calculate trend
        let firstHalf = data.prefix(days / 2)
        let secondHalf = data.suffix(days / 2)
        let firstAvg = firstHalf.isEmpty ? 0 : firstHalf.map { $0.value }.reduce(0, +) / Double(firstHalf.count)
        let secondAvg = secondHalf.isEmpty ? 0 : secondHalf.map { $0.value }.reduce(0, +) / Double(secondHalf.count)
        
        if firstAvg > 0 {
            trend = Int(((secondAvg - firstAvg) / firstAvg) * 100)
        }
    }
    
    private func loadHabitData(habit: Habit, days: Int) {
        let history = habitService.getProgressHistory(for: habit, days: days)
        let calendar = Calendar.current
        
        var data: [ProgressChartDataPoint] = []
        for dayOffset in 0..<days {
            if let date = calendar.date(byAdding: .day, value: -dayOffset, to: Date()) {
                let dayStart = calendar.startOfDay(for: date)
                let progress = history.first { progress in
                    calendar.isDate(progress.date ?? Date(), inSameDayAs: dayStart)
                }
                data.append(ProgressChartDataPoint(
                    date: dayStart,
                    value: progress?.isComplete == true ? 1 : 0
                ))
            }
        }
        
        chartData = data.reversed()
        overallCompletionRate = habitService.getCompletionRate(for: habit, days: days)
        habitStats = []
    }
    
    private func calculateInsights(days: Int) {
        // Best day calculation
        let dayCompletions = Dictionary(grouping: chartData) { data in
            Calendar.current.component(.weekday, from: data.date)
        }.mapValues { values in
            values.map { $0.value }.reduce(0, +) / Double(values.count)
        }
        
        if let bestDayNum = dayCompletions.max(by: { $0.value < $1.value })?.key {
            let formatter = DateFormatter()
            bestDay = formatter.weekdaySymbols[bestDayNum - 1]
        }
        
        // Longest streak
        longestStreak = habitService.streaks
            .map { Int($0.longestLength) }
            .max() ?? 0
        
        // Most consistent habit
        if let topHabit = habitStats.first {
            mostConsistentHabit = topHabit.name
        }
        
        // Improvement suggestion
        if overallCompletionRate < 0.5 {
            improvementSuggestion = "Try focusing on just 2-3 habits to build momentum"
        } else if overallCompletionRate < 0.8 {
            improvementSuggestion = "You're doing great! Consider habit stacking for better results"
        } else {
            improvementSuggestion = nil
        }
    }
    
    private func colorForCategory(_ category: String) -> Color {
        switch category.lowercased() {
        case "health": return .zenError
        case "fitness": return .zenSecondary
        case "mindfulness": return .zenSuccess
        case "learning": return .zenPrimary
        case "creativity": return .purple
        case "productivity": return .zenTertiary
        default: return .zenPrimary
        }
    }
}

struct ProgressChartDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
}

struct HabitStat: Identifiable {
    let id: UUID
    let name: String
    let completionRate: Double
    let color: Color
}