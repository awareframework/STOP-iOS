//
//  HealthActivity.swift
//  STOP
//
//  Created by Yuuki Nishiyama on 2018/05/21.
//  Copyright © 2018 Yuuki Nishiyama. All rights reserved.
//

import UIKit
import AWAREFramework

class HealthActivity: AWARESensor {

    override init!(awareStudy study: AWAREStudy!, dbType: AwareDBType) {
        let storage = SQLiteStorage.init(study: study, sensorName: "health", entityName: "EntityHealth") { (data, managedContext, entityName) in
            let entity = NSEntityDescription.insertNewObject(forEntityName: entityName!, into: managedContext!) as! EntityHealth
            entity.timestamp = data?["timestamp"] as? NSNumber;
            entity.device_id = data?["device_id"] as? String;
            entity.pd_value = data?["pd_value"] as? String;
        }
        super.init(awareStudy: study, sensorName: "health", storage: storage)
    }
    
    override func createTable() {
        let maker = TCQMaker.init()
        maker.addColumn("pd_value", type: TCQTypeText, default: "''")
        self.storage.createDBTableOnServer(with: maker)
    }
    
    public func saveValue(_ value: String) {
        let timestamp = AWAREUtils.getUnixTimestamp(NSDate.init() as Date?) as! Double
        let data:[String:Any] = ["timestamp":timestamp,"device_id":self.getDeviceId(),"pd_value":value]
        self.storage.saveData(with:data, buffer: false, saveInMainThread: true)
        self.storage.startSyncStorage();
    }
    
}

