import SwiftUI
import Combine

// Simple data store for managing app data
class ZenStrideDataStore: ObservableObject {
    @Published var habits: [HabitModel] = []
    @Published var wins: [MicroWin] = []
    
    init() {
        // Initialize with empty data for fresh start
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
    }
    
    func removeWin(_ win: MicroWin) {
        wins.removeAll { $0.id == win.id }
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
    }
}