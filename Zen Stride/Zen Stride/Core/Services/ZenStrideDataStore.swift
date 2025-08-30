import SwiftUI
import Combine

// Extension to remove duplicates from array
extension Array where Element: Hashable {
    func removingDuplicates() -> [Element] {
        var seen = Set<Element>()
        return filter { seen.insert($0).inserted }
    }
}

// Simple data store for managing app data
class ZenStrideDataStore: ObservableObject {
    @Published var habits: [HabitModel] = []
    @Published var wins: [MicroWin] = []
    @Published var streakDays: Int = 0
    
    // Computed property for all wins
    var allWins: [MicroWin] {
        wins
    }
    
    // Computed property for today's wins
    var todaysWins: [MicroWin] {
        getTodaysWins()
    }
    
    // Streak saver tokens (for gamification)
    @Published var streakSaverTokens: Int = 3
    
    init() {
        // Initialize with empty data for fresh start
        calculateStreak()
    }
    
    func addHabit(_ habit: HabitModel) {
        habits.append(habit)
    }
    
    func removeHabit(_ habit: HabitModel) {
        habits.removeAll { $0.id == habit.id }
    }
    
    func updateHabit(_ habit: HabitModel) {
        if let index = habits.firstIndex(where: { $0.id == habit.id }) {
            habits[index] = habit
        }
    }
    
    func addWin(_ win: MicroWin) {
        wins.append(win)
        calculateStreak()
    }
    
    func removeWin(_ win: MicroWin) {
        wins.removeAll { $0.id == win.id }
        calculateStreak()
    }
    
    func getWinsForHabit(_ habitName: String) -> [MicroWin] {
        wins.filter { $0.habitName == habitName }
    }
    
    func getTodaysWins() -> [MicroWin] {
        let calendar = Calendar.current
        let today = Date()
        return wins.filter { calendar.isDate($0.timestamp, inSameDayAs: today) }
    }
    
    func reset() {
        habits.removeAll()
        wins.removeAll()
        streakDays = 0
    }
    
    func getMonthlyTrend() -> Double {
        let calendar = Calendar.current
        let now = Date()
        
        // Get wins from last 30 days
        let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: now)!
        let recentWins = wins.filter { $0.timestamp > thirtyDaysAgo }
        
        // Get wins from previous 30 days
        let sixtyDaysAgo = calendar.date(byAdding: .day, value: -60, to: now)!
        let previousWins = wins.filter { $0.timestamp > sixtyDaysAgo && $0.timestamp <= thirtyDaysAgo }
        
        // Calculate trend
        if previousWins.isEmpty {
            return recentWins.isEmpty ? 0 : 1.0
        }
        
        let trend = Double(recentWins.count - previousWins.count) / Double(previousWins.count)
        return max(-1.0, min(1.0, trend)) // Clamp between -1 and 1
    }
    
    func getWeeklyProgress() -> [Double] {
        let calendar = Calendar.current
        let now = Date()
        var weeklyData: [Double] = []
        
        // Get data for last 7 days
        for dayOffset in (0..<7).reversed() {
            guard let targetDate = calendar.date(byAdding: .day, value: -dayOffset, to: now) else {
                weeklyData.append(0)
                continue
            }
            
            let dayWins = wins.filter { win in
                calendar.isDate(win.timestamp, inSameDayAs: targetDate)
            }
            
            // Normalize to 0-1 scale (assuming max 10 wins per day)
            let normalizedValue = min(Double(dayWins.count) / 10.0, 1.0)
            weeklyData.append(normalizedValue)
        }
        
        return weeklyData
    }
    
    private func calculateStreak() {
        guard !wins.isEmpty else {
            streakDays = 0
            return
        }
        
        let calendar = Calendar.current
        let sortedDates = wins.map { calendar.startOfDay(for: $0.timestamp) }
            .sorted(by: >)
            .removingDuplicates()
        
        guard let mostRecent = sortedDates.first,
              calendar.isDateInToday(mostRecent) || calendar.isDateInYesterday(mostRecent) else {
            streakDays = 0
            return
        }
        
        var streak = 0
        var currentDate = calendar.isDateInToday(mostRecent) ? mostRecent : calendar.startOfDay(for: Date())
        
        for date in sortedDates {
            if calendar.isDate(date, inSameDayAs: currentDate) {
                streak += 1
                currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate)!
            } else {
                break
            }
        }
        
        streakDays = streak
    }
}