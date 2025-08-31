import Foundation
import CoreData
import SwiftUI

class HabitService: ObservableObject {
    private let viewContext: NSManagedObjectContext
    
    @Published var habits: [Habit] = []
    @Published var todayProgress: [Progress] = []
    @Published var streaks: [Streak] = []
    
    init(context: NSManagedObjectContext) {
        self.viewContext = context
        fetchHabits()
        fetchTodayProgress()
        fetchStreaks()
    }
    
    // MARK: - Fetch Operations
    
    func fetchHabits() {
        let request: NSFetchRequest<Habit> = Habit.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Habit.createdDate, ascending: false)]
        request.predicate = NSPredicate(format: "isActive == true")
        
        do {
            habits = try viewContext.fetch(request)
        } catch {
            print("Error fetching habits: \(error)")
        }
    }
    
    func fetchTodayProgress() {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let request: NSFetchRequest<Progress> = Progress.fetchRequest()
        request.predicate = NSPredicate(format: "date >= %@ AND date < %@", startOfDay as NSDate, endOfDay as NSDate)
        
        do {
            todayProgress = try viewContext.fetch(request)
        } catch {
            print("Error fetching today's progress: \(error)")
        }
    }
    
    func fetchStreaks() {
        let request: NSFetchRequest<Streak> = Streak.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Streak.startDate, ascending: false)]
        
        do {
            streaks = try viewContext.fetch(request)
        } catch {
            print("Error fetching streaks: \(error)")
        }
    }
    
    // MARK: - Progress Tracking
    
    func logProgress(for habit: Habit, value: Double? = nil) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Check if progress already exists for today
        let existingProgress = todayProgress.first { progress in
            progress.habit == habit &&
            calendar.isDate(progress.date ?? Date(), inSameDayAs: today)
        }
        
        if let progress = existingProgress {
            // Update existing progress
            progress.value = value ?? habit.targetValue
            progress.isComplete = progress.value >= habit.targetValue
        } else {
            // Create new progress
            let newProgress = Progress(context: viewContext)
            newProgress.id = UUID()
            newProgress.date = Date()
            newProgress.value = value ?? habit.targetValue
            newProgress.isComplete = newProgress.value >= habit.targetValue
            newProgress.habit = habit
        }
        
        // Update streak
        updateStreak(for: habit)
        
        // Award points if completed
        if let progress = existingProgress ?? todayProgress.last,
           progress.isComplete {
            awardPoints(10) // Base points for completion
        }
        
        save()
        fetchTodayProgress()
    }
    
    func toggleHabitCompletion(for habit: Habit) {
        let isCurrentlyComplete = isHabitCompleteToday(habit)
        
        if isCurrentlyComplete {
            // Mark as incomplete
            if let progress = getTodayProgress(for: habit) {
                progress.isComplete = false
                progress.value = 0
            }
        } else {
            // Mark as complete
            logProgress(for: habit)
        }
        
        save()
    }
    
    func getTodayProgress(for habit: Habit) -> Progress? {
        todayProgress.first { $0.habit == habit }
    }
    
    func isHabitCompleteToday(_ habit: Habit) -> Bool {
        getTodayProgress(for: habit)?.isComplete ?? false
    }
    
    // MARK: - Streak Management
    
    func updateStreak(for habit: Habit) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Find active streak for this habit
        var activeStreak = streaks.first { streak in
            streak.habit == habit && streak.isActive
        }
        
        if activeStreak == nil {
            // Create new streak
            activeStreak = Streak(context: viewContext)
            activeStreak?.id = UUID()
            activeStreak?.habit = habit
            activeStreak?.startDate = today
            activeStreak?.isActive = true
            activeStreak?.currentLength = 0
        }
        
        guard let streak = activeStreak else { return }
        
        // Check if habit was completed yesterday
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        let yesterdayProgress = getProgress(for: habit, on: yesterday)
        
        if yesterdayProgress?.isComplete == true || streak.currentLength == 0 {
            // Continue or start streak
            streak.currentLength += 1
            
            // Check for longest streak
            if streak.currentLength > streak.longestLength {
                streak.longestLength = streak.currentLength
            }
        } else {
            // Break streak - create new one
            streak.isActive = false
            
            let newStreak = Streak(context: viewContext)
            newStreak.id = UUID()
            newStreak.habit = habit
            newStreak.startDate = today
            newStreak.isActive = true
            newStreak.currentLength = 1
            newStreak.longestLength = 1
        }
        
        save()
        fetchStreaks()
    }
    
    func getActiveStreak(for habit: Habit) -> Int {
        Int(streaks.first { $0.habit == habit && $0.isActive }?.currentLength ?? 0)
    }
    
    // MARK: - Progress History
    
    func getProgress(for habit: Habit, on date: Date) -> Progress? {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let request: NSFetchRequest<Progress> = Progress.fetchRequest()
        request.predicate = NSPredicate(
            format: "habit == %@ AND date >= %@ AND date < %@",
            habit, startOfDay as NSDate, endOfDay as NSDate
        )
        
        do {
            return try viewContext.fetch(request).first
        } catch {
            print("Error fetching progress: \(error)")
            return nil
        }
    }
    
    func getProgressHistory(for habit: Habit, days: Int = 30) -> [Progress] {
        let calendar = Calendar.current
        let endDate = Date()
        let startDate = calendar.date(byAdding: .day, value: -days, to: endDate)!
        
        let request: NSFetchRequest<Progress> = Progress.fetchRequest()
        request.predicate = NSPredicate(
            format: "habit == %@ AND date >= %@ AND date <= %@",
            habit, startDate as NSDate, endDate as NSDate
        )
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Progress.date, ascending: true)]
        
        do {
            return try viewContext.fetch(request)
        } catch {
            print("Error fetching progress history: \(error)")
            return []
        }
    }
    
    // MARK: - Statistics
    
    func getCompletionRate(for habit: Habit, days: Int = 30) -> Double {
        let history = getProgressHistory(for: habit, days: days)
        guard !history.isEmpty else { return 0 }
        
        let completed = history.filter { $0.isComplete }.count
        return Double(completed) / Double(days)
    }
    
    func getTotalCompletions(for habit: Habit) -> Int {
        let request: NSFetchRequest<Progress> = Progress.fetchRequest()
        request.predicate = NSPredicate(format: "habit == %@ AND isComplete == true", habit)
        
        do {
            return try viewContext.count(for: request)
        } catch {
            print("Error counting completions: \(error)")
            return 0
        }
    }
    
    func getBestStreak(for habit: Habit) -> Int {
        streaks.filter { $0.habit == habit }
            .map { Int($0.longestLength) }
            .max() ?? 0
    }
    
    // MARK: - Points & Achievements
    
    func awardPoints(_ points: Int) {
        let request: NSFetchRequest<User> = User.fetchRequest()
        
        do {
            if let user = try viewContext.fetch(request).first {
                user.totalPoints += Int32(points)
                
                // Check for level up
                let newLevel = Int32(user.totalPoints / 100) + 1
                if newLevel > user.currentLevel {
                    user.currentLevel = newLevel
                    // Trigger level up celebration
                }
                
                save()
            }
        } catch {
            print("Error awarding points: \(error)")
        }
    }
    
    func checkAchievements(for habit: Habit) {
        let completions = getTotalCompletions(for: habit)
        let currentStreak = getActiveStreak(for: habit)
        
        // Check milestone achievements
        let milestones = [7, 30, 60, 100, 365]
        for milestone in milestones {
            if completions == milestone {
                createAchievement(
                    title: "\(milestone) Day Champion",
                    description: "Completed \(habit.name ?? "habit") for \(milestone) days",
                    icon: "trophy.fill",
                    points: milestone * 10
                )
            }
        }
        
        // Check streak achievements
        let streakMilestones = [7, 14, 30, 60, 100]
        for milestone in streakMilestones {
            if currentStreak == milestone {
                createAchievement(
                    title: "\(milestone) Day Streak!",
                    description: "Maintained a \(milestone) day streak",
                    icon: "flame.fill",
                    points: milestone * 15
                )
            }
        }
    }
    
    private func createAchievement(title: String, description: String, icon: String, points: Int) {
        let achievement = Achievement(context: viewContext)
        achievement.id = UUID()
        achievement.name = title
        achievement.achievementDescription = description
        achievement.iconName = icon
        achievement.points = Int32(points)
        achievement.unlockedDate = Date()
        achievement.isUnlocked = true
        
        awardPoints(points)
        save()
    }
    
    // MARK: - Helpers
    
    private func save() {
        do {
            try viewContext.save()
        } catch {
            print("Error saving context: \(error)")
        }
    }
    
    func deleteHabit(_ habit: Habit) {
        habit.isActive = false
        save()
        fetchHabits()
    }
    
    func updateHabit(_ habit: Habit) {
        save()
        fetchHabits()
    }
}