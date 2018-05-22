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
    
    let health:HealthActivity?
    
    override init() {
        /// Set a remote server url
        AWAREStudy.shared()!.setStudyURL("https://api.awareframework.com/index.php/webservice/index/1773/BqLDdqzNp5aB")
        /// Set clean interval = never clean the stored data
        AWAREStudy.shared()!.setCleanOldDataType(cleanOldDataTypeNever)
        
        /// Change the database mode
        let url = Bundle.main.url(forResource: "AWARE_STOP", withExtension: "momd")
        CoreDataHandler.shared()!.overwriteManageObjectModel(withFileURL: url)
        /// Turn off background sensing
        AWARECore.shared()!.isNeedBackgroundSensing = false
        
        if !UserDefaults.standard.bool(forKey: "SETTING_STOP_DEFAULT"){
            UserDefaults.standard.set(50.0, forKey: STOPKeys.SETTING_BALL_SIZE)
            UserDefaults.standard.set(150.0, forKey: STOPKeys.SETTING_SMALL_CIRCLE_SIZE)
            UserDefaults.standard.set(250.0, forKey: STOPKeys.SETTING_BIG_CIRCLE_SIZE)
            UserDefaults.standard.set(2.0, forKey: STOPKeys.SETTING_SENSITIVITY)
            UserDefaults.standard.set(10.0, forKey: STOPKeys.SETTING_GAME_TIME)
            UserDefaults.standard.set(true, forKey: "SETTING_STOP_DEFAULT")
        }
        health = HealthActivity.init(awareStudy: AWAREStudy.shared(), dbType: AwareDBTypeSQLite)
        health?.createTable()
    }
    
    @objc func receivedHealthSurveyAnswer(notification: Notification){
        let userInfo = notification.userInfo
        let cells = userInfo![KEY_AWARE_ESM_CELLS] as! Array<BaseESMView>
        for cell in cells {
            let answer = cell.getUserAnswer()
            health?.saveValue(answer!)
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
        
        /// set esms
        if let uwEsmManager = ESMScheduleManager.shared() {
            uwEsmManager.removeAllNotifications()
            uwEsmManager.deleteAllSchedules()
            
            let esmSchdule = ESMSchedule.init()
            esmSchdule.scheduleId = ""
            esmSchdule.expirationThreshold = 0
            
            let esmItem = ESMItem.init(asRadioESMWithTrigger: "radio", radioItems: ["None","Some","Severe"])
            esmItem?.setInstructions("How was your PD yesterday?")
            
            esmSchdule.addESM(esmItem)
            
            uwEsmManager.add(esmSchdule)
        }
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.receivedHealthSurveyAnswer(notification:)),
                                               name: Notification.Name(ACTION_AWARE_ESM_NEXT),
                                               object: nil)
        
        return true
    }

    override func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    override func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    override func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    override func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    override func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

