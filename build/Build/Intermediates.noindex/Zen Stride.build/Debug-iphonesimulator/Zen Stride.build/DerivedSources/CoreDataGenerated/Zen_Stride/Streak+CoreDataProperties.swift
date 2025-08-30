//
//  Streak+CoreDataProperties.swift
//  
//
//  Created by Tono Murrieta  on 22/08/25.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension Streak {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Streak> {
        return NSFetchRequest<Streak>(entityName: "Streak")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var startDate: Date?
    @NSManaged public var endDate: Date?
    @NSManaged public var currentLength: Int32
    @NSManaged public var longestLength: Int32
    @NSManaged public var isActive: Bool
    @NSManaged public var habit: Habit?

}

extension Streak : Identifiable {

}
