//
//  Achievement+CoreDataProperties.swift
//  
//
//  Created by Tono Murrieta  on 22/08/25.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension Achievement {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Achievement> {
        return NSFetchRequest<Achievement>(entityName: "Achievement")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var achievementDescription: String?
    @NSManaged public var iconName: String?
    @NSManaged public var badgeColorHex: String?
    @NSManaged public var category: String?
    @NSManaged public var requirement: Int32
    @NSManaged public var progress: Int32
    @NSManaged public var isUnlocked: Bool
    @NSManaged public var unlockedDate: Date?
    @NSManaged public var points: Int32

}

extension Achievement : Identifiable {

}
