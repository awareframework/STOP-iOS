//
//  NotificationData.swift
//  STOP
//
//  Created by Yuuki Nishiyama on 2018/07/04.
//  Copyright © 2018 Yuuki Nishiyama. All rights reserved.
//

import UIKit
import AWAREFramework

class NotificationData: AWARESensor, UNUserNotificationCenterDelegate {
    
    let notificationIds = ["morning","noon","afternoon","evening","survey"]
    
    let sensorName = "notification_data"
    
    override init!(awareStudy study: AWAREStudy!, dbType: AwareDBType) {
        
//        let storage = SQLiteStorage.init(study: study,
//                                         sensorName:sensorName ,
//                                         entityName: NSStringFromClass(EntityNotificationData.self)) { (data, managedContext, entityName) in
//                                            let entity = NSEntityDescription.insertNewObject(forEntityName: entityName!, into: managedContext!) as! EntityNotificationData
//                                            entity.timestamp = data?["timestamp"] as? NSNumber;
//                                            entity.device_id = data?["device_id"] as? String;
//                                            entity.event = data?["event"] as? String;
//        }
        
        let storage = JSONStorage.init(study: study, sensorName: sensorName)
        
        super.init(awareStudy: study, sensorName: sensorName, storage: storage)
        UNUserNotificationCenter.current().delegate = self
        
    }
    
    override func createTable() {
        let maker = TCQMaker.init()
        maker.addColumn("event", type: TCQTypeText, default: "''")
        self.storage.createDBTableOnServer(with: maker)
    }
    
    
    func saveNotificationEvnet(timestamp:Date, event:String){
        let data:[String:Any] = ["timestamp":AWAREUtils.getUnixTimestamp(timestamp),
                                "device_id": AWAREStudy.shared().getDeviceId(),
                                "event": event]
        self.storage.saveData(with: data, buffer: false, saveInMainThread: true)
    }
    
    
    /////////////////////
    // The method will be called on the delegate when the user responded to the notification by opening the application, dismissing the notification or choosing a UNNotificationAction. The delegate must be set before the application returns from application:didFinishLaunchingWithOptions:.
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let now = Date()
        // let identifier = response.notification.request.identifier
        let content = response.notification.request.content
        self.saveNotificationEvnet(timestamp: now, event: "\(content.title.lowercased())_opened")
        self.storage.startSyncStorage()
    }
    
    public func updateNotifications(force:Bool){
        let center = UNUserNotificationCenter.current()
        
        center.getPendingNotificationRequests { (pendingNotifications) in
            
            for notificationId in self.notificationIds {
                var isPending = false
                for pendingNotification in pendingNotifications {
                    if pendingNotification.identifier == notificationId {
                        isPending = true
                        print("next time => \(pendingNotification.identifier): \(pendingNotification.trigger)")
                    }
                }
                
                if isPending == false || force {
                    // generate notification
                    let body = NSLocalizedString("notification_game_text", comment: "notification_game_text")
                    if notificationId == self.notificationIds[0] {
                        // Morning notification    8:00 - 11:59
                        let title = NSLocalizedString("notification_game_morning", comment: "notification_game_morning")
                        self.setNotification(identifier: notificationId, title: title,body: body,
                                             repeats: false, startHour: 8, startMin: 0, randomize: 60*4-1, forceOverwrite: force)
                    }else if notificationId == self.notificationIds[1] {
                        // Noon notification      12:00 - 14:59
                        let title = NSLocalizedString("notification_game_noon", comment: "notification_game_noon")
                        self.setNotification(identifier: notificationId, title: title,body: body,
                                             repeats: false, startHour: 12, startMin: 0, randomize: 60*3-1, forceOverwrite: force)
                    }else if notificationId == self.notificationIds[2] {
                        // Afternoon notification 15:00 - 18:59
                        let title = NSLocalizedString("notification_game_afternoon", comment: "notification_game_afternoon")
                        self.setNotification(identifier: notificationId, title: title,body: body,
                                             repeats: false, startHour: 15, startMin: 0, randomize: 60*4-1, forceOverwrite: force)
                    }else if notificationId == self.notificationIds[3] {
                        // Evening notification   19:00 - 21:59
                        let title = NSLocalizedString("notification_game_evening", comment: "notification_game_evening")
                        self.setNotification(identifier: notificationId, title: title,body: body,
                                             repeats: false, startHour: 19, startMin: 0, randomize: 60*3-1, forceOverwrite: force)
                    }else if notificationId == self.notificationIds[4] {
                        // Survey notification    10:00 - 11:00
                        let title = NSLocalizedString("notification_survey", comment: "notification_survey")
                        let surveyBody = NSLocalizedString("notification_survey_text", comment: "notification_survey_text")
                        self.setNotification(identifier: notificationId, title: title, body: surveyBody,
                                             //repeats: false, startHour: 10, startMin: 17, randomize: 5, forceOverwrite: force)
                            repeats: false, startHour: 10, startMin: 0, randomize: 60, forceOverwrite: force)
                    }
                }
            }
        }
    }
    
    func setNotification(identifier:String, title:String, body:String, repeats:Bool, startHour:Int, startMin:Int, randomize:Int, forceOverwrite:Bool) {
        
        let center = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default()
        
        var dateComponents = DateComponents()
        if randomize == 0 {
            dateComponents.hour   =  startHour
            dateComponents.minute =  startMin
        }else{
            // randomize
            var targetDate = Date();
            let now = Date()
            if (forceOverwrite){
                targetDate = now;
            }else{
                let tomorrow = now.addingTimeInterval(60*60*24)
                targetDate = tomorrow
            }
            var components = Calendar.current.dateComponents(in: TimeZone.current, from: targetDate)
            components.hour = startHour
            components.minute = startMin
            
            ///////////////////////
            if components.date?.timeIntervalSince1970 < now.timeIntervalSince1970 {
                let tomorrow = now.addingTimeInterval(60*60*24)
                components = Calendar.current.dateComponents(in: TimeZone.current, from: tomorrow)
                components.hour = startHour
                components.minute = startMin
            }
            ////////////////////////
            
            let notificationDateTime = components.date
            
            let randomizedMin = arc4random_uniform(UInt32(randomize))
            
            let randomizedDateTime = notificationDateTime?.addingTimeInterval(TimeInterval(randomizedMin*60))
            let randomizedDateTimeComponents = Calendar.current.dateComponents(in: TimeZone.current, from: randomizedDateTime!)
            
            dateComponents.hour = randomizedDateTimeComponents.hour
            dateComponents.minute = randomizedDateTimeComponents.minute
            dateComponents.day = randomizedDateTimeComponents.day
            dateComponents.month = randomizedDateTimeComponents.month
            dateComponents.year = randomizedDateTimeComponents.year
            print("next time => \(dateComponents)")
        }
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        center.add(request) { (error) in
            if let e = error {
                print("\(identifier): error => \(e.localizedDescription)")
            }else{
                print("\(identifier): done")
                
                // save notification events
                let now = Date()
                self.saveNotificationEvnet(timestamp: now, event: "\(title.lowercased())_shown")
            }
        }
    }
    
    
    func sendTestNotification(){
        let center = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        content.title = "test"
        content.sound = UNNotificationSound.default()

        let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 60, repeats: true)
        let request = UNNotificationRequest(identifier: UUID.init().uuidString, content: content, trigger: trigger)
        center.add(request) { (error) in
            if let e = error {
                print("error => \(e.localizedDescription)")
            }else{
                print(" done")
            }
        }
    }
    
    public func removeAllPendingNotifications() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: self.notificationIds)
    }
    
}
