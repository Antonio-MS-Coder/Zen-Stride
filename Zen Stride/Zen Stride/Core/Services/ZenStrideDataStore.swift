import SwiftUI
import Combine

// Extension to remove duplicates from array
extension Array where Element: Hashable {
    func removingDuplicates() -> [Element] {
        var seen = Set<Element>()
        return filter { seen.insert($0).inserted }
    }
}

// Make models Codable for persistence
extension HabitModel: Codable {
    enum CodingKeys: String, CodingKey {
        case id, name, icon, frequency, unit, isActive
    }
}

extension MicroWin: Codable {
    enum CodingKeys: String, CodingKey {
        case id, habitName, value, unit, icon, timestamp
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(habitName, forKey: .habitName)
        try container.encode(value, forKey: .value)
        try container.encode(unit, forKey: .unit)
        try container.encode(icon, forKey: .icon)
        try container.encode(timestamp, forKey: .timestamp)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try container.decode(UUID.self, forKey: .id)
        let habitName = try container.decode(String.self, forKey: .habitName)
        let value = try container.decode(String.self, forKey: .value)
        let unit = try container.decode(String.self, forKey: .unit)
        let icon = try container.decode(String.self, forKey: .icon)
        let timestamp = try container.decode(Date.self, forKey: .timestamp)
        
        self.init(id: id, habitName: habitName, value: value, unit: unit, icon: icon, color: .premiumIndigo, timestamp: timestamp)
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
    
    // UserDefaults keys
    private let habitsKey = "zenStride.habits"
    private let winsKey = "zenStride.wins"
    private let tokensKey = "zenStride.tokens"
    
    init() {
        loadFromUserDefaults()
        calculateStreak()
    }
    
    func addHabit(_ habit: HabitModel) {
        habits.append(habit)
        saveToUserDefaults()
    }
    
    func removeHabit(_ habit: HabitModel) {
        habits.removeAll { $0.id == habit.id }
        saveToUserDefaults()
    }
    
    func updateHabit(_ habit: HabitModel) {
        if let index = habits.firstIndex(where: { $0.id == habit.id }) {
            habits[index] = habit
            saveToUserDefaults()
        }
    }
    
    func addWin(_ win: MicroWin) {
        wins.append(win)
        calculateStreak()
        saveToUserDefaults()
    }
    
    func removeWin(_ win: MicroWin) {
        wins.removeAll { $0.id == win.id }
        calculateStreak()
        saveToUserDefaults()
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
        streakSaverTokens = 3
        saveToUserDefaults()
    }
    
    // MARK: - Persistence
    private func saveToUserDefaults() {
        let defaults = UserDefaults.standard
        
        // Save habits
        if let habitsData = try? JSONEncoder().encode(habits) {
            defaults.set(habitsData, forKey: habitsKey)
        }
        
        // Save wins
        if let winsData = try? JSONEncoder().encode(wins) {
            defaults.set(winsData, forKey: winsKey)
        }
        
        // Save tokens
        defaults.set(streakSaverTokens, forKey: tokensKey)
    }
    
    private func loadFromUserDefaults() {
        let defaults = UserDefaults.standard
        
        // Load habits
        if let habitsData = defaults.data(forKey: habitsKey),
           let decodedHabits = try? JSONDecoder().decode([HabitModel].self, from: habitsData) {
            habits = decodedHabits
        }
        
        // Load wins
        if let winsData = defaults.data(forKey: winsKey),
           let decodedWins = try? JSONDecoder().decode([MicroWin].self, from: winsData) {
            wins = decodedWins
        }
        
        // Load tokens
        streakSaverTokens = defaults.integer(forKey: tokensKey)
        if streakSaverTokens == 0 {
            streakSaverTokens = 3 // Default value
        }
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