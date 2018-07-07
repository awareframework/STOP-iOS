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
    
    var appNotifications:NotificationData?
    
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
            if let notifications = self.appNotifications{
                notifications.updateNotifications(force: true)
            }
            
            let debug = Debug.init(awareStudy:AWAREStudy.shared(), dbType: AwareDBTypeJSON)
            debug?.createTable()
            
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
        if let notifications = self.appNotifications{
            notifications.removeAllPendingNotifications()
        }

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
        
        appNotifications = NotificationData(awareStudy: AWAREStudy.shared(), dbType: AwareDBTypeJSON)
        if let notifications = appNotifications{
            notifications.updateNotifications(force: false)
        }
        
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
        if let notifications = appNotifications {
            notifications.updateNotifications(force: false)
        }
    }

    override func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.

    }

//    application:performFetchWithCompletionHandler:
    override func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        if let notifications = appNotifications {
            notifications.updateNotifications(force: false)
        }
        
        if AWAREStudy.shared().getURL() != "" {
            print("[background fetch] exist url")
            let debug = Debug(awareStudy:AWAREStudy.shared(), dbType: AwareDBTypeJSON)
            debug?.startSyncDB()
        }else{
            print("[background fetch] no url")
        }
        
        // NewData, NoData, Failed
        completionHandler(.noData)
    }
}

