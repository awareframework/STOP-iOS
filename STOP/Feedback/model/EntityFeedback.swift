//
//  EntityFeedback.swift
//  STOP
//
//  Created by Yuuki Nishiyama on 2018/04/16.
//  Copyright © 2018 Yuuki Nishiyama. All rights reserved.
//

import Foundation
import CoreData

@objc(EntityFeedback)
public class EntityFeedback: NSManagedObject {
    @NSManaged var device_id:String
    @NSManaged var timestamp:Double
    @NSManaged var device_name:String
    @NSManaged var feedback:String
}
