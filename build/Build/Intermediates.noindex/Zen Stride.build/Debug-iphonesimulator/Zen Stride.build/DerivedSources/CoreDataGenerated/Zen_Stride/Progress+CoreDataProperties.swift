//
//  Progress+CoreDataProperties.swift
//  
//
//  Created by Tono Murrieta  on 22/08/25.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension Progress {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Progress> {
        return NSFetchRequest<Progress>(entityName: "Progress")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var date: Date?
    @NSManaged public var value: Double
    @NSManaged public var notes: String?
    @NSManaged public var completedAt: Date?
    @NSManaged public var isComplete: Bool
    @NSManaged public var habit: Habit?

}

extension Progress : Identifiable {

}
