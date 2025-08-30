import SwiftUI
import CoreData
import Combine

@MainActor
class DashboardViewModel: ObservableObject {
    @Published var habits: [Habit] = []
    @Published var todayProgress: [Progress] = []
    @Published var currentUser: User?
    @Published var todayCompletionRate: Double = 0
    @Published var activeStreaks: [Streak] = []
    @Published var motivationalQuote: String = ""
    @Published var isLoading = false
    
    private let context: NSManagedObjectContext
    private let persistenceController: PersistenceController
    private var cancellables = Set<AnyCancellable>()
    
    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
        self.persistenceController = PersistenceController.shared
        setupUser()
        fetchData()
        generateMotivationalQuote()
    }
    
    private func setupUser() {
        currentUser = persistenceController.createOrGetUser()
    }
    
    func fetchData() {
        isLoading = true
        fetchHabits()
        fetchTodayProgress()
        fetchActiveStreaks()
        calculateTodayCompletion()
        isLoading = false
    }
    
    private func fetchHabits() {
        let request = NSFetchRequest<Habit>(entityName: "Habit")
        request.predicate = NSPredicate(format: "isActive == true")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Habit.createdDate, ascending: false)]
        
        do {
            habits = try context.fetch(request)
        } catch {
            print("Error fetching habits: \(error)")
        }
    }
    
    private func fetchTodayProgress() {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let request = NSFetchRequest<Progress>(entityName: "Progress")
        request.predicate = NSPredicate(format: "date >= %@ AND date < %@", startOfDay as NSDate, endOfDay as NSDate)
        
        do {
            todayProgress = try context.fetch(request)
        } catch {
            print("Error fetching today's progress: \(error)")
        }
    }
    
    private func fetchActiveStreaks() {
        let request = NSFetchRequest<Streak>(entityName: "Streak")
        request.predicate = NSPredicate(format: "isActive == true")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Streak.currentLength, ascending: false)]
        
        do {
            activeStreaks = try context.fetch(request)
        } catch {
            print("Error fetching streaks: \(error)")
        }
    }
    
    private func calculateTodayCompletion() {
        guard !habits.isEmpty else {
            todayCompletionRate = 0
            return
        }
        
        let completedCount = todayProgress.filter { $0.isComplete }.count
        todayCompletionRate = Double(completedCount) / Double(habits.count)
    }
    
    func logProgress(for habit: Habit, value: Double) {
        let progress = Progress(context: context)
        progress.id = UUID()
        progress.date = Date()
        progress.value = value
        progress.isComplete = value >= habit.targetValue
        progress.completedAt = Date()
        progress.habit = habit
        
        // Update streak
        updateStreak(for: habit)
        
        // Award points if completed
        if progress.isComplete {
            awardPoints(10)
            checkAchievements()
        }
        
        persistenceController.save()
        fetchData()
    }
    
    private func updateStreak(for habit: Habit) {
        // Find or create active streak
        let request = NSFetchRequest<Streak>(entityName: "Streak")
        request.predicate = NSPredicate(format: "habit == %@ AND isActive == true", habit)
        request.fetchLimit = 1
        
        do {
            let streaks = try context.fetch(request)
            if let streak = streaks.first {
                // Check if streak continues
                let calendar = Calendar.current
                let yesterday = calendar.date(byAdding: .day, value: -1, to: Date())!
                let lastProgress = getLastProgress(for: habit, before: Date())
                
                if let lastDate = lastProgress?.date,
                   calendar.isDate(lastDate, inSameDayAs: yesterday) {
                    streak.currentLength += 1
                    if streak.currentLength > streak.longestLength {
                        streak.longestLength = streak.currentLength
                    }
                }
            } else {
                // Create new streak
                let newStreak = Streak(context: context)
                newStreak.id = UUID()
                newStreak.startDate = Date()
                newStreak.currentLength = 1
                newStreak.longestLength = 1
                newStreak.isActive = true
                newStreak.habit = habit
            }
        } catch {
            print("Error updating streak: \(error)")
        }
    }
    
    private func getLastProgress(for habit: Habit, before date: Date) -> Progress? {
        let request = NSFetchRequest<Progress>(entityName: "Progress")
        request.predicate = NSPredicate(format: "habit == %@ AND date < %@", habit, date as NSDate)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Progress.date, ascending: false)]
        request.fetchLimit = 1
        
        do {
            return try context.fetch(request).first
        } catch {
            print("Error fetching last progress: \(error)")
            return nil
        }
    }
    
    private func awardPoints(_ points: Int) {
        guard let user = currentUser else { return }
        user.totalPoints += Int32(points)
        
        // Check for level up
        let newLevel = Int32(user.totalPoints / 100) + 1
        if newLevel > user.currentLevel {
            user.currentLevel = newLevel
            // Trigger level up celebration
        }
    }
    
    private func checkAchievements() {
        let request = NSFetchRequest<Achievement>(entityName: "Achievement")
        request.predicate = NSPredicate(format: "isUnlocked == false")
        
        do {
            let lockedAchievements = try context.fetch(request)
            for achievement in lockedAchievements {
                achievement.progress += 1
                if achievement.progress >= achievement.requirement {
                    achievement.isUnlocked = true
                    achievement.unlockedDate = Date()
                    awardPoints(Int(achievement.points))
                }
            }
        } catch {
            print("Error checking achievements: \(error)")
        }
    }
    
    func getTodayProgress(for habit: Habit) -> Progress? {
        todayProgress.first { $0.habit == habit }
    }
    
    func getProgressPercentage(for habit: Habit) -> Double {
        guard let progress = getTodayProgress(for: habit) else { return 0 }
        return min(progress.value / habit.targetValue, 1.0)
    }
    
    private func generateMotivationalQuote() {
        let quotes = [
            "Small steps daily lead to big changes yearly.",
            "Progress is progress, no matter how small.",
            "Your only limit is you.",
            "Every expert was once a beginner.",
            "Success is the sum of small efforts repeated day in and day out.",
            "The journey of a thousand miles begins with one step.",
            "Don't watch the clock; do what it does. Keep going.",
            "You are one decision away from a totally different life."
        ]
        motivationalQuote = quotes.randomElement() ?? quotes[0]
    }
}