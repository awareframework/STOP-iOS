//
//  Medicine.swift
//  STOP
//
//  Created by Yuuki Nishiyama on 2018/04/17.
//  Copyright © 2018 Yuuki Nishiyama. All rights reserved.
//

import UIKit
import AWAREFramework

class Medication: AWARESensor {
    override init() {
        let name = "medication"
        let storage = SQLiteStorage.init(study: AWAREStudy.shared(), sensorName: name, entityName: "EntityMedication") { (data, context, name) in
            if let data = data , let name = name, let context = context {
                let medication = NSEntityDescription.insertNewObject(forEntityName: name, into: context) as! EntityMedication
                medication.device_id = data["device_id"] as! String
                medication.timestamp = data["timestamp"] as! Double
                medication.double_medication = data["double_medication"] as! Double
            }
        }
        super.init(awareStudy: AWAREStudy.shared(), sensorName: name, storage:storage)
    }
    
    override func createTable() {
        let maker = TCQMaker.init()
        maker.addColumn("double_medication", type: TCQTypeReal, default: "0")
        self.storage.createDBTableOnServer(with: maker)
    }
    
    public func saveMedication(timestamp:Date){
        
        let data:[String : Any] = [
            "device_id":self.getDeviceId(),
            "timestamp":AWAREUtils.getUnixTimestamp(Date.init()),
            "double_medication":AWAREUtils.getUnixTimestamp(timestamp)
        ]
        if let storage = self.storage{
            storage.saveData(with: data, buffer: false, saveInMainThread: true)
        }
    }
    
    public func getAllMedications() -> Array<EntityMedication>{
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "EntityMedication")
        let sectionSortDescriptor = NSSortDescriptor(key: "double_medication", ascending: false)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        do {
            let medications = try CoreDataHandler.shared().managedObjectContext.fetch(fetchRequest)
            return medications as! Array<EntityMedication>
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        return []
    }
    
    public func removeMedication(object:NSManagedObject){
        CoreDataHandler.shared().managedObjectContext.delete(object)
    }
    
    public func updateMedication(object:NSManagedObject){
        do{
            try CoreDataHandler.shared().managedObjectContext.save()
        } catch let error as NSError {
            print(error)
        }
    }
}
