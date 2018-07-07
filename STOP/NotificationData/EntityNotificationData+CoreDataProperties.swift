//
//  EntityNotificationData+CoreDataProperties.swift
//  
//
//  Created by Yuuki Nishiyama on 2018/07/04.
//
//

import Foundation
import CoreData


extension EntityNotificationData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<EntityNotificationData> {
        return NSFetchRequest<EntityNotificationData>(entityName: "EntityNotificationData")
    }

    @NSManaged public var timestamp: NSNumber?
    @NSManaged public var device_id: String?
    @NSManaged public var event: String?

}
