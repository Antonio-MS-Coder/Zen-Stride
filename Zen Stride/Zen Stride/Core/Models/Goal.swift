import Foundation
import SwiftUI

// MARK: - Goal Types
enum GoalType: String, CaseIterable {
    case quantitative = "Quantitative"  // Weight loss, books read, savings
    case milestone = "Milestone"        // Learn a skill, complete project
    case streak = "Streak"             // Daily meditation, workout streak
    
    var icon: String {
        switch self {
        case .quantitative: return "chart.line.uptrend.xyaxis"
        case .milestone: return "flag.checkered"
        case .streak: return "flame.fill"
        }
    }
}

enum UpdateFrequency: String, CaseIterable {
    case daily = "Daily"
    case weekly = "Weekly"
    case biweekly = "Bi-weekly"
    case monthly = "Monthly"
    
    var days: Int {
        switch self {
        case .daily: return 1
        case .weekly: return 7
        case .biweekly: return 14
        case .monthly: return 30
        }
    }
}

// MARK: - Goal Progress Update
struct GoalUpdate {
    let date: Date
    let value: Double
    let note: String?
    
    init(date: Date = Date(), value: Double, note: String? = nil) {
        self.date = date
        self.value = value
        self.note = note
    }
}

// MARK: - Goal Model
struct Goal: Identifiable {
    let id: UUID
    let name: String
    let type: GoalType
    let category: String
    let startValue: Double
    let targetValue: Double
    let currentValue: Double
    let unit: String
    let deadline: Date?
    let updateFrequency: UpdateFrequency
    let updates: [GoalUpdate]
    let createdDate: Date
    let isActive: Bool
    
    // Computed properties
    var progress: Double {
        guard targetValue != startValue else { return 0 }
        
        switch type {
        case .quantitative:
            // For goals like weight loss where you decrease
            if startValue > targetValue {
                let totalChange = startValue - targetValue
                let currentChange = startValue - currentValue
                return max(0, min(1, currentChange / totalChange))
            } else {
                // For goals like reading books where you increase
                let totalChange = targetValue - startValue
                let currentChange = currentValue - startValue
                return max(0, min(1, currentChange / totalChange))
            }
        case .milestone:
            return currentValue >= targetValue ? 1.0 : currentValue / targetValue
        case .streak:
            return min(1.0, currentValue / targetValue)
        }
    }
    
    var progressPercentage: Int {
        Int(progress * 100)
    }
    
    var remainingValue: Double {
        abs(targetValue - currentValue)
    }
    
    var daysUntilDeadline: Int? {
        guard let deadline = deadline else { return nil }
        let days = Calendar.current.dateComponents([.day], from: Date(), to: deadline).day
        return days
    }
    
    var isOnTrack: Bool {
        guard let daysLeft = daysUntilDeadline, daysLeft > 0 else { return true }
        
        let progressPerDay = progress / Double(daysLeft)
        let requiredProgressPerDay = (1.0 - progress) / Double(daysLeft)
        
        return progressPerDay >= requiredProgressPerDay * 0.9 // 90% of required pace
    }
    
    var nextUpdateDue: Date {
        let lastUpdate = updates.max(by: { $0.date < $1.date })?.date ?? createdDate
        return Calendar.current.date(byAdding: .day, value: updateFrequency.days, to: lastUpdate) ?? Date()
    }
    
    var isUpdateDue: Bool {
        nextUpdateDue <= Date()
    }
    
    // Helper methods
    func formattedValue(_ value: Double) -> String {
        if value.truncatingRemainder(dividingBy: 1) == 0 {
            return "\(Int(value))"
        } else {
            return String(format: "%.1f", value)
        }
    }
    
    var formattedProgress: String {
        "\(formattedValue(currentValue)) / \(formattedValue(targetValue)) \(unit)"
    }
    
    var motivationalMessage: String {
        switch progress {
        case 0..<0.25:
            return "Great start! Every step counts."
        case 0.25..<0.5:
            return "You're building momentum!"
        case 0.5..<0.75:
            return "Halfway there! Keep pushing!"
        case 0.75..<1.0:
            return "So close! You've got this!"
        default:
            return "Goal achieved! Incredible work! 🎉"
        }
    }
}

// MARK: - Sample Goals
extension Goal {
    static let sampleGoals: [Goal] = [] // Empty array for fresh start
}