//
//  AppDelegate.swift
//  STOP
//
//  Created by Yuuki Nishiyama on 2018/04/12.
//  Copyright © 2018 Yuuki Nishiyama. All rights reserved.
//

import UIKit
import AWAREFramework

@UIApplicationMain
class AppDelegate: AWAREDelegate {

    let notificationIds = ["morning","noon","afternoon","evening","survey"]
    
    override init() {
        
        if !UserDefaults.standard.bool(forKey: "SETTING_STOP_DEFAULT"){
            UserDefaults.standard.set( 50.0, forKey: STOPKeys.SETTING_BALL_SIZE)
            UserDefaults.standard.set(150.0, forKey: STOPKeys.SETTING_SMALL_CIRCLE_SIZE)
            UserDefaults.standard.set(250.0, forKey: STOPKeys.SETTING_BIG_CIRCLE_SIZE)
            UserDefaults.standard.set(  5.0, forKey: STOPKeys.SETTING_SENSITIVITY)
            UserDefaults.standard.set( 10.0, forKey: STOPKeys.SETTING_GAME_TIME)
            UserDefaults.standard.set( true, forKey: "SETTING_STOP_DEFAULT")
            UserDefaults.standard.set(Date().timeIntervalSince1970, forKey:"LAST_NOTIFICATION_UPDATE_TIME")
        }
        
        /// Change the database mode
        let url = Bundle.main.url(forResource: "AWARE_STOP", withExtension: "momd")
        CoreDataHandler.shared()!.overwriteManageObjectModel(withFileURL: url)

        /// Turn off background sensing
        AWARECore.shared()!.isNeedBackgroundSensing = false
    }
    
    public func joinStudy(_ completion:JoinStudyCompletionHandler?){

        /// Set clean interval = never clean the stored data
        AWAREStudy.shared()!.setCleanOldDataType(cleanOldDataTypeNever)
        
        /// Set a remote server url
        let studyURL = "https://api.awareframework.com/index.php/webservice/index/1836/5IuLyJjLQQNK"
        AWAREStudy.shared().setStudyURL(studyURL);
        AWAREStudy.shared().join(withURL:studyURL, completion: { (result, status, error) in
            self.updateNotifications(force: true)
            /// set esms
            if let hadler = completion {
                hadler(result, status, error)
            }
        })
        
        UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
        AWARECore.shared().requestNotification(UIApplication.shared)
    }
    
    public func quitStudy(){
        AWAREStudy.shared().clearSettings()
        AWARESensorManager.shared().stopAndRemoveAllSensors()
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.removePendingNotificationRequests(withIdentifiers: self.notificationIds)
    }
    
    override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        // Override point for customization after application launch.
        super.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        /// set colors on navigation bars
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().barTintColor = UIColor.init(red:31.0/255 , green: 148.0/255, blue: 249.0/255, alpha: 1.0)
        let navBarAttributesDictionary: [NSAttributedStringKey: Any] = [
            NSAttributedStringKey(rawValue: NSAttributedStringKey.foregroundColor.rawValue): UIColor.white]
        UINavigationBar.appearance().titleTextAttributes = navBarAttributesDictionary
        
        UIApplication.shared.isIdleTimerDisabled = true
        
        updateNotifications(force: false)
        
        return true
    }

    override func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        UIApplication.shared.isIdleTimerDisabled = false
    }

    override func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        UIApplication.shared.isIdleTimerDisabled = false
    }

    override func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        UIApplication.shared.isIdleTimerDisabled = true
    }

    override func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        UIApplication.shared.isIdleTimerDisabled = true
        updateNotifications(force:false)
    }

    override func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.

    }

//    application:performFetchWithCompletionHandler:
    override func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
 
        updateNotifications(force:false)
        
        // NewData, NoData, Failed
        completionHandler(.noData)
    }
    
    func updateNotifications(force:Bool){
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
                    if notificationId == "morning" {
                        // Morning notification    8:00 - 11:59
                        let title = NSLocalizedString("notification_game_morning", comment: "notification_game_morning")
                        self.setNotification(identifier: notificationId, title: title,body: body,
                                        repeats: false, startHour: 8, startMin: 0, randomize: 60*4-1, forceOverwrite: force)
                    }else if notificationId == "noon" {
                         // Noon notification      12:00 - 14:59
                        let title = NSLocalizedString("notification_game_noon", comment: "notification_game_noon")
                        self.setNotification(identifier: notificationId, title: title,body: body,
                                             repeats: false, startHour: 12, startMin: 0, randomize: 60*3-1, forceOverwrite: force)
                    }else if notificationId == "afternoon" {
                        // Afternoon notification 15:00 - 18:59
                        let title = NSLocalizedString("notification_game_afternoon", comment: "notification_game_afternoon")
                        self.setNotification(identifier: notificationId, title: title,body: body,
                                             repeats: false, startHour: 15, startMin: 0, randomize: 60*4-1, forceOverwrite: force)
                    }else if notificationId == "evening" {
                        // Evening notification   19:00 - 21:59
                        let title = NSLocalizedString("notification_game_evening", comment: "notification_game_evening")
                        self.setNotification(identifier: notificationId, title: title,body: body,
                                             repeats: false, startHour: 19, startMin: 0, randomize: 60*3-1, forceOverwrite: force)
                    }else if notificationId == "survey" {
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
            }
        }
    }
}

