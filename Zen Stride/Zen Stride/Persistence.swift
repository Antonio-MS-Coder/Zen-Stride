//
//  Persistence.swift
//  Zen Stride
//
//  Created by Tono Murrieta  on 21/08/25.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    @MainActor
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        // Create sample user
        let user = User(context: viewContext)
        user.id = UUID()
        user.name = "Preview User"
        user.joinedDate = Date()
        user.hasCompletedOnboarding = true
        user.dailyGoal = 3
        user.totalPoints = 250
        user.currentLevel = 2
        
        // Create sample habits
        let habits = [
            ("Read Daily", "book.fill", "Learning", 10.0, "pages", "#4A90E2"),
            ("Morning Exercise", "figure.run", "Health", 15.0, "minutes", "#7ED321"),
            ("Meditate", "brain.head.profile", "Mindfulness", 5.0, "minutes", "#9B88E3"),
            ("Drink Water", "drop.fill", "Health", 8.0, "glasses", "#50E3C2"),
            ("Practice Spanish", "globe", "Learning", 20.0, "minutes", "#F5A623")
        ]
        
        for (name, icon, category, target, unit, color) in habits {
            let habit = Habit(context: viewContext)
            habit.id = UUID()
            habit.name = name
            habit.iconName = icon
            habit.category = category
            habit.targetValue = target
            habit.targetUnit = unit
            habit.colorHex = color
            habit.createdDate = Date().addingTimeInterval(-TimeInterval.random(in: 0...2592000))
            habit.isActive = true
            habit.frequency = "daily"
            habit.motivationalMessage = "Keep going! You're building something amazing."
            
            // Create some sample progress
            for dayOffset in 0..<7 {
                let progress = Progress(context: viewContext)
                progress.id = UUID()
                progress.date = Calendar.current.date(byAdding: .day, value: -dayOffset, to: Date())!
                progress.value = Double.random(in: 0...target * 1.2)
                progress.isComplete = progress.value >= target
                progress.completedAt = progress.date
                progress.habit = habit
            }
            
            // Create active streak
            let streak = Streak(context: viewContext)
            streak.id = UUID()
            streak.startDate = Calendar.current.date(byAdding: .day, value: -5, to: Date())!
            streak.currentLength = 5
            streak.longestLength = 12
            streak.isActive = true
            streak.habit = habit
        }
        
        // Create sample achievements
        let achievements = [
            ("First Step", "foot.fill", "Getting Started", 1, "#4A90E2"),
            ("Week Warrior", "calendar", "Consistency", 7, "#7ED321"),
            ("Habit Master", "crown.fill", "Mastery", 30, "#F5A623"),
            ("Streak Legend", "flame.fill", "Streaks", 100, "#FF6B6B")
        ]
        
        for (name, icon, category, requirement, color) in achievements {
            let achievement = Achievement(context: viewContext)
            achievement.id = UUID()
            achievement.name = name
            achievement.iconName = icon
            achievement.category = category
            achievement.requirement = Int32(requirement)
            achievement.progress = Int32.random(in: 0...Int32(requirement))
            achievement.isUnlocked = achievement.progress >= achievement.requirement
            achievement.points = Int32(requirement * 10)
            achievement.badgeColorHex = color
            achievement.achievementDescription = "Complete \(requirement) habits"
            if achievement.isUnlocked {
                achievement.unlockedDate = Date().addingTimeInterval(-TimeInterval.random(in: 0...604800))
            }
        }
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Zen_Stride")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    // MARK: - Core Data Operations
    
    func save() {
        let context = container.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    func deleteAllData() {
        let entities = ["Habit", "Progress", "Streak", "Achievement", "User"]
        
        for entity in entities {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            
            do {
                try container.viewContext.execute(deleteRequest)
                try container.viewContext.save()
            } catch {
                print("Error deleting \(entity): \(error)")
            }
        }
    }
    
    // MARK: - User Management
    
    func getCurrentUser() -> User? {
        let request = NSFetchRequest<User>(entityName: "User")
        request.fetchLimit = 1
        
        do {
            let users = try container.viewContext.fetch(request)
            return users.first
        } catch {
            print("Error fetching user: \(error)")
            return nil
        }
    }
    
    func createOrGetUser() -> User {
        if let existingUser = getCurrentUser() {
            return existingUser
        }
        
        let newUser = User(context: container.viewContext)
        newUser.id = UUID()
        newUser.joinedDate = Date()
        newUser.dailyGoal = 3
        newUser.totalPoints = 0
        newUser.currentLevel = 1
        newUser.hasCompletedOnboarding = false
        newUser.notificationsEnabled = true
        newUser.soundEnabled = true
        newUser.hapticsEnabled = true
        newUser.motivationalQuotesEnabled = true
        
        save()
        return newUser
    }
}