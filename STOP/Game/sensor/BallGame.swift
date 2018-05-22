//
//  BallGame.swift
//  STOP
//
//  Created by Yuuki Nishiyama on 2018/05/21.
//  Copyright © 2018 Yuuki Nishiyama. All rights reserved.
//

import Foundation

import UIKit
import AWAREFramework

class BallGame: AWARESensor {
    override init() {
        let name = "ball_game"
        let storage = SQLiteStorage.init(study: AWAREStudy.shared(), sensorName: name, entityName: "EntityBallGame") { (data, context, name) in
            if let data = data , let name = name, let context = context {
                let ballGame = NSEntityDescription.insertNewObject(forEntityName: name, into: context) as! EntityBallGame
                ballGame.device_id = data["device_id"] as! String
                ballGame.timestamp = data["timestamp"] as! Double
                ballGame.data = data["data"] as! String
            }
        }
        super.init(awareStudy: AWAREStudy.shared(), sensorName: name, storage:storage)
    }
    
    override func createTable() {
        let maker = TCQMaker.init()
        maker.addColumn("data", type: TCQTypeText, default: "")
        self.storage.createDBTableOnServer(with: maker)
    }
    
    
    /// save a game data to the storage
    public func saveData(data:String){
        let data:[String : Any] = [
            "device_id":self.getDeviceId(),
            "timestamp":AWAREUtils.getUnixTimestamp(Date.init()),
            "data":data
        ]
        if let storage = self.storage{
            storage.saveData(with: data, buffer: false, saveInMainThread: true)
        }
    }
}
