//
//  User+CoreDataProperties.swift
//  
//
//  Created by Tono Murrieta  on 31/08/25.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var dailyGoal: Int32
    @NSManaged public var totalPoints: Int32
    @NSManaged public var currentLevel: Int32
    @NSManaged public var joinedDate: Date?
    @NSManaged public var preferredReminderTime: Date?
    @NSManaged public var notificationsEnabled: Bool
    @NSManaged public var soundEnabled: Bool
    @NSManaged public var hapticsEnabled: Bool
    @NSManaged public var motivationalQuotesEnabled: Bool
    @NSManaged public var hasCompletedOnboarding: Bool

}

extension User : Identifiable {

}
