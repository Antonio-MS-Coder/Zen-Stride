import SwiftUI
import CoreData
import Combine

class ElegantDashboardViewModel: ObservableObject {
    private let habitService: HabitService
    let viewContext: NSManagedObjectContext
    private var cancellables = Set<AnyCancellable>()
    
    @Published var habits: [Habit] = []
    @Published var todayProgress: [Progress] = []
    @Published var streaks: [Streak] = []
    @Published var currentUser: User?
    @Published var todayCompletionRate: Double = 0
    @Published var weeklyCompletionRate: Double = 0
    @Published var greeting = "Good morning"
    @Published var timeOfDay = TimeOfDay.morning
    
    enum TimeOfDay {
        case morning, afternoon, evening, night
    }
    
    init(context: NSManagedObjectContext) {
        self.viewContext = context
        self.habitService = HabitService(context: context)
        
        setupBindings()
        fetchUser()
        updateTimeOfDay()
        
        // Set up timer to update time of day
        Timer.publish(every: 3600, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                self.updateTimeOfDay()
            }
            .store(in: &cancellables)
    }
    
    private func setupBindings() {
        habitService.$habits
            .assign(to: &$habits)
        
        habitService.$todayProgress
            .assign(to: &$todayProgress)
        
        habitService.$streaks
            .assign(to: &$streaks)
        
        // Calculate completion rate when progress updates
        habitService.$todayProgress
            .map { progress in
                guard !self.habits.isEmpty else { return 0 }
                let completed = progress.filter { $0.isComplete }.count
                return Double(completed) / Double(self.habits.count)
            }
            .assign(to: &$todayCompletionRate)
        
        // Calculate weekly completion rate (placeholder - would calculate from week's data)
        habitService.$todayProgress
            .map { _ in
                // This is a simplified calculation - in reality would fetch week's data
                return 0.65 + Double.random(in: -0.1...0.2) // Simulated value between 55-85%
            }
            .assign(to: &$weeklyCompletionRate)
    }
    
    private func fetchUser() {
        let request: NSFetchRequest<User> = User.fetchRequest()
        
        do {
            currentUser = try viewContext.fetch(request).first
            
            // Create default user if none exists
            if currentUser == nil {
                let newUser = User(context: viewContext)
                newUser.id = UUID()
                newUser.name = "Friend"
                newUser.joinedDate = Date()
                newUser.currentLevel = 1
                newUser.totalPoints = 0
                newUser.dailyGoal = 3
                
                try viewContext.save()
                currentUser = newUser
            }
        } catch {
            print("Error fetching user: \(error)")
        }
    }
    
    private func updateTimeOfDay() {
        let hour = Calendar.current.component(.hour, from: Date())
        
        switch hour {
        case 5..<12:
            timeOfDay = .morning
            greeting = "Good morning"
        case 12..<17:
            timeOfDay = .afternoon
            greeting = "Good afternoon"
        case 17..<22:
            timeOfDay = .evening
            greeting = "Good evening"
        default:
            timeOfDay = .night
            greeting = "Good night"
        }
    }
    
    // MARK: - Public Methods
    
    func refreshData() {
        habitService.fetchHabits()
        habitService.fetchTodayProgress()
        habitService.fetchStreaks()
    }
    
    func toggleHabit(_ habit: Habit) {
        habitService.toggleHabitCompletion(for: habit)
        
        // Check achievements
        habitService.checkAchievements(for: habit)
        
        // Refresh user data for points update
        fetchUser()
    }
    
    func getTodayProgress(for habit: Habit) -> Progress? {
        habitService.getTodayProgress(for: habit)
    }
    
    func isHabitComplete(_ habit: Habit) -> Bool {
        habitService.isHabitCompleteToday(habit)
    }
    
    func getStreak(for habit: Habit) -> Int {
        habitService.getActiveStreak(for: habit)
    }
    
    func getCompletedCount() -> Int {
        todayProgress.filter { $0.isComplete }.count
    }
    
    func getPersonalizedMessage() -> String {
        let completed = getCompletedCount()
        let total = habits.count
        
        if total == 0 {
            return "Ready to start your journey?"
        }
        
        let rate = Double(completed) / Double(total)
        
        switch (timeOfDay, rate) {
        case (.morning, _):
            return rate == 0 ? "Let's make today count!" : "Great start to the day!"
        case (.afternoon, let r) where r < 0.5:
            return "Keep the momentum going"
        case (.afternoon, _):
            return "You're doing amazing!"
        case (.evening, let r) where r < 0.5:
            return "Still time to finish strong"
        case (.evening, let r) where r < 1.0:
            return "Almost there!"
        case (.evening, _):
            return "Perfect day! 🎉"
        case (.night, let r) where r == 1.0:
            return "You crushed it today!"
        case (.night, _):
            return "Time to rest and recharge"
        }
    }
    
    func getCurrentStreak() -> Int {
        streaks.filter { $0.isActive }
            .map { Int($0.currentLength) }
            .max() ?? 0
    }
    
    func getTotalPoints() -> Int {
        Int(currentUser?.totalPoints ?? 0)
    }
    
    func getTotalCompletedToday() -> Int {
        todayProgress.filter { $0.isComplete }.count
    }
    
    func getTotalCompletedThisWeek() -> Int {
        // This would fetch actual week data from Core Data
        // For now, return a calculated value
        let weeklyTotal = habits.count * 7
        return Int(Double(weeklyTotal) * weeklyCompletionRate)
    }
}