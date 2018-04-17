//
//  EntityMedicine.swift
//  STOP
//
//  Created by Yuuki Nishiyama on 2018/04/17.
//  Copyright © 2018 Yuuki Nishiyama. All rights reserved.
//

import UIKit
import CoreData

@objc(EntityMedication)
public class EntityMedication: NSManagedObject {
    @NSManaged var device_id:String
    @NSManaged var timestamp:Double
    @NSManaged var double_medication:Double
}
