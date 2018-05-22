//
//  EntityBallGame.swift
//  STOP
//
//  Created by Yuuki Nishiyama on 2018/05/21.
//  Copyright © 2018 Yuuki Nishiyama. All rights reserved.
//

import UIKit
import CoreData

@objc(EntityBallGame)
public class EntityBallGame: NSManagedObject {
    @NSManaged var device_id:String
    @NSManaged var timestamp:Double
    @NSManaged var data:String
}
