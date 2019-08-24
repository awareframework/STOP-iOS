//
//  Feedback.swift
//  STOP
//
//  Created by Yuuki Nishiyama on 2018/04/16.
//  Copyright © 2018 Yuuki Nishiyama. All rights reserved.
//

import UIKit
import AWAREFramework

class Feedback: AWARESensor {

    override init() {
        let name = "feedback"
        let storage = SQLiteStorage.init(study: AWAREStudy.shared(), sensorName: name, entityName: "EntityFeedback") { (data, context, name) in
            if let data = data , let name = name, let context = context {
                let feedback = NSEntityDescription.insertNewObject(forEntityName: name, into: context) as! EntityFeedback
                feedback.device_id = data["device_id"] as! String
                feedback.timestamp = data["timestamp"] as! Double
                feedback.device_name = data["device_name"] as! String
                feedback.feedback = data["feedback"] as! String
            }
        }
        super.init(awareStudy: AWAREStudy.shared(), sensorName: name, storage:storage)
    }
    
    override func createTable() {
        let maker = TCQMaker.init()
        maker.addColumn("device_name", type: TCQTypeText, default: "''")
        maker.addColumn("feedback", type: TCQTypeText, default: "''")
        self.storage?.createDBTableOnServer(with: maker)
    }
    
    public func saveFeedback(userName:String, deviceName:String, feedback:String){
        
        let data:[String : Any] = [
            "device_id":self.getDeviceId() ?? "",
            "timestamp":AWAREUtils.getUnixTimestamp(Date.init()),
            "user_name":userName,
            "device_name":deviceName,
            "feedback":feedback
            ]
        if let storage = self.storage{
            storage.saveData(with: data, buffer: false, saveInMainThread: true)
        }
        
    }
}
