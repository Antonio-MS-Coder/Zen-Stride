//
//  Habit+CoreDataProperties.swift
//  
//
//  Created by Tono Murrieta  on 31/08/25.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension Habit {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Habit> {
        return NSFetchRequest<Habit>(entityName: "Habit")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var habitDescription: String?
    @NSManaged public var category: String?
    @NSManaged public var colorHex: String?
    @NSManaged public var iconName: String?
    @NSManaged public var targetValue: Double
    @NSManaged public var targetUnit: String?
    @NSManaged public var frequency: String?
    @NSManaged public var isActive: Bool
    @NSManaged public var createdDate: Date?
    @NSManaged public var reminderTime: Date?
    @NSManaged public var motivationalMessage: String?
    @NSManaged public var progresses: NSSet?
    @NSManaged public var streaks: NSSet?

}

// MARK: Generated accessors for progresses
extension Habit {

    @objc(addProgressesObject:)
    @NSManaged public func addToProgresses(_ value: Progress)

    @objc(removeProgressesObject:)
    @NSManaged public func removeFromProgresses(_ value: Progress)

    @objc(addProgresses:)
    @NSManaged public func addToProgresses(_ values: NSSet)

    @objc(removeProgresses:)
    @NSManaged public func removeFromProgresses(_ values: NSSet)

}

// MARK: Generated accessors for streaks
extension Habit {

    @objc(addStreaksObject:)
    @NSManaged public func addToStreaks(_ value: Streak)

    @objc(removeStreaksObject:)
    @NSManaged public func removeFromStreaks(_ value: Streak)

    @objc(addStreaks:)
    @NSManaged public func addToStreaks(_ values: NSSet)

    @objc(removeStreaks:)
    @NSManaged public func removeFromStreaks(_ values: NSSet)

}

extension Habit : Identifiable {

}
