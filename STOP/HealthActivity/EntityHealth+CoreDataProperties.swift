//
//  EntityHealth+CoreDataProperties.swift
//  
//
//  Created by Yuuki Nishiyama on 2018/05/21.
//
//

import Foundation
import CoreData


extension EntityHealth {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<EntityHealth> {
        return NSFetchRequest<EntityHealth>(entityName: "EntityHealth")
    }

    @NSManaged public var timestamp: NSNumber?
    @NSManaged public var device_id: String?
    @NSManaged public var pd_value: String?

}
