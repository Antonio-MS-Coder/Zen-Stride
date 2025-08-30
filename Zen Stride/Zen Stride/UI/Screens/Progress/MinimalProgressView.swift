import SwiftUI
import Charts
import CoreData

struct MinimalProgressView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var selectedTimeRange = TimeRange.week
    @State private var selectedHabit: Habit?
    
    @FetchRequest(
        entity: Habit.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Habit.createdDate, ascending: false)],
        predicate: NSPredicate(format: "isActive == true")
    ) private var habits: FetchedResults<Habit>
    
    @FetchRequest(
        entity: Progress.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Progress.date, ascending: false)]
    ) private var allProgress: FetchedResults<Progress>
    
    enum TimeRange: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case year = "Year"
        
        var days: Int {
            switch self {
            case .week: return 7
            case .month: return 30
            case .year: return 365
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: .notion24) {
                    // Time Range Selector
                    Picker("Time Range", selection: $selectedTimeRange) {
                        ForEach(TimeRange.allCases, id: \.self) { range in
                            Text(range.rawValue).tag(range)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal, .notion16)
                    
                    // Habit Filter
                    if !habits.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: .notion8) {
                                FilterChip(
                                    title: "All",
                                    isSelected: selectedHabit == nil,
                                    action: { selectedHabit = nil }
                                )
                                
                                ForEach(habits) { habit in
                                    FilterChip(
                                        title: habit.name ?? "",
                                        isSelected: selectedHabit == habit,
                                        action: { selectedHabit = habit }
                                    )
                                }
                            }
                            .padding(.horizontal, .notion16)
                        }
                    }
                    
                    // Chart
                    chartSection
                    
                    // Statistics
                    statsSection
                }
                .padding(.vertical, .notion16)
            }
            .background(Color.notionBackground)
            .navigationTitle("Progress")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
        }
    }
    
    private var chartSection: some View {
        VStack(alignment: .leading, spacing: .notion12) {
            Text("Completion Rate")
                .font(.notionSubheading)
                .foregroundColor(.notionText)
                .padding(.horizontal, .notion16)
            
            if let chartData = getChartData() {
                Chart(chartData) { data in
                    BarMark(
                        x: .value("Day", data.date, unit: .day),
                        y: .value("Completed", data.value)
                    )
                    .foregroundStyle(Color.notionAccent)
                    .cornerRadius(2)
                }
                .frame(height: 200)
                .padding(.horizontal, .notion16)
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day)) { _ in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                            .foregroundStyle(Color.notionBorder)
                        AxisValueLabel(format: .dateTime.weekday(.abbreviated))
                            .font(.notionCaption)
                    }
                }
                .chartYAxis {
                    AxisMarks { _ in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                            .foregroundStyle(Color.notionBorder)
                        AxisValueLabel()
                            .font(.notionCaption)
                    }
                }
            } else {
                Text("No data available")
                    .font(.notionBody)
                    .foregroundColor(.notionTextSecondary)
                    .frame(maxWidth: .infinity, minHeight: 200)
                    .padding(.horizontal, .notion16)
            }
        }
        .padding(.vertical, .notion16)
        .notionCard(showBorder: true)
        .padding(.horizontal, .notion16)
    }
    
    private var statsSection: some View {
        VStack(alignment: .leading, spacing: .notion16) {
            Text("Statistics")
                .font(.notionSubheading)
                .foregroundColor(.notionText)
                .padding(.horizontal, .notion16)
            
            VStack(spacing: .notion12) {
                StatRow(label: "Total Habits", value: "\(habits.count)")
                Divider().foregroundColor(.notionDivider)
                StatRow(label: "Completed Today", value: "\(getTodayCompleted())")
                Divider().foregroundColor(.notionDivider)
                StatRow(label: "Current Streak", value: "\(getCurrentStreak()) days")
                Divider().foregroundColor(.notionDivider)
                StatRow(label: "Success Rate", value: "\(getSuccessRate())%")
            }
            .padding(.notion16)
            .notionCard()
            .padding(.horizontal, .notion16)
        }
    }
    
    private func getChartData() -> [ChartDataPoint]? {
        let calendar = Calendar.current
        let endDate = Date()
        _ = calendar.date(byAdding: .day, value: -selectedTimeRange.days, to: endDate)!
        
        var data: [ChartDataPoint] = []
        
        for dayOffset in 0..<selectedTimeRange.days {
            if let date = calendar.date(byAdding: .day, value: -dayOffset, to: endDate) {
                let dayStart = calendar.startOfDay(for: date)
                let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart)!
                
                let completed = allProgress.filter { progress in
                    guard let progressDate = progress.date else { return false }
                    if let habit = selectedHabit {
                        return progressDate >= dayStart && progressDate < dayEnd && 
                               progress.habit == habit && progress.isComplete
                    } else {
                        return progressDate >= dayStart && progressDate < dayEnd && progress.isComplete
                    }
                }.count
                
                data.append(ChartDataPoint(date: dayStart, value: Double(completed)))
            }
        }
        
        return data.isEmpty ? nil : data
    }
    
    private func getTodayCompleted() -> Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
        
        return allProgress.filter { progress in
            guard let date = progress.date else { return false }
            return date >= today && date < tomorrow && progress.isComplete
        }.count
    }
    
    private func getCurrentStreak() -> Int {
        // Simplified - would need proper implementation
        return 0
    }
    
    private func getSuccessRate() -> Int {
        guard !allProgress.isEmpty else { return 0 }
        let completed = allProgress.filter { $0.isComplete }.count
        return Int((Double(completed) / Double(allProgress.count)) * 100)
    }
}

struct ChartDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.notionCaption)
                .foregroundColor(isSelected ? .notionAccent : .notionTextSecondary)
                .padding(.horizontal, .notion12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.notionAccentLight : Color.notionGray50)
                .overlay(
                    RoundedRectangle(cornerRadius: .notionCornerSmall)
                        .stroke(isSelected ? Color.notionAccent : Color.notionBorder, lineWidth: 1)
                )
        }
    }
}

struct StatRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.notionBody)
                .foregroundColor(.notionTextSecondary)
            
            Spacer()
            
            Text(value)
                .font(.notionBody)
                .foregroundColor(.notionText)
        }
    }
}