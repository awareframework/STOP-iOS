//
//  MainViewController.swift
//  STOP
//
//  Created by Yuuki Nishiyama on 2018/06/21.
//  Copyright © 2018 Yuuki Nishiyama. All rights reserved.
//

import UIKit
import AWAREFramework

class MainViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func viewWillAppear(_ animated: Bool) {
        
        // check a consent state
        if(!Consent.isConsentRead() && !Consent.isConsentAnswered() ){
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "ConsentViewIdentifier") as! ConsentViewController
            self.present(vc, animated: true, completion: {
                
            })
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func pushedSettingButton(_ sender: Any) {
        
        let alertController = UIAlertController(title: NSLocalizedString("move_to", comment: "move_to"), message: nil, preferredStyle: .alert)
        
        /*
        let settingsButton = UIAlertAction.init(title: NSLocalizedString("main_experiment", comment: "main_experiment"), style: UIAlertActionStyle.default) { (action) in
            if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SettingsView") as? SettingsTableViewController {
                if let navigator = self.navigationController {
                    //self.cancelGame()
                    navigator.pushViewController(viewController, animated: true)
                }
            }
        }
         */
        
        let feedbackButton = UIAlertAction(title: NSLocalizedString("main_participant_info", comment: "main_participant_info"), style: .default) { (action) in
            if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FeedbackView") as? FeedbackViewController {
                if let navigator = self.navigationController {
                    //self.cancelGame()
                    navigator.pushViewController(viewController, animated: true)
                }
            }
        }
        
        /// add a setting button
        // alertController.addAction(settingsButton)
        
        // add a feedback button
        alertController.addAction(feedbackButton)
        
        /// add a join or quit study button
        if Consent.isConsentAnswered() {
            let quitStudyButton = UIAlertAction(title: NSLocalizedString("main_quit_study",comment: "Quit Study"), style: .destructive) {(action) in
                DispatchQueue.main.async {
                    self.pushedDemoButton()
                    let debug = Debug(awareStudy:AWAREStudy.shared(), dbType: AwareDBTypeJSON)
                    debug.saveEvent(withText: "quit_study", type: DebugTypeInfo.rawValue, label: "STOP")
                    debug.startSyncDB()
                }
            }
            alertController.addAction(quitStudyButton)
        }else{
            let quitStudyButton = UIAlertAction(title:NSLocalizedString("main_join_study",comment: "Join Study"),
                                                     style: .destructive) {(action) in
                                                        DispatchQueue.main.async {
                                                            self.pushedDemoButton()
                                                            let debug = Debug(awareStudy:AWAREStudy.shared(), dbType: AwareDBTypeJSON)
                                                            debug.saveEvent(withText: "join_study", type: DebugTypeInfo.rawValue, label: "STOP")
                                                            debug.startSyncDB()
                                                        }
            }
            alertController.addAction(quitStudyButton)
        }
        
        /// add a cancel button
        let cancelButton = UIAlertAction(title: NSLocalizedString("cancel", comment: "cancel") , style: .cancel, handler: nil)
        
        alertController.addAction(cancelButton)
        
        present(alertController, animated: true) {
            
        }
    }
    
    public func pushedDemoButton(){
        /// add a join or quit study button
        if Consent.isConsentAnswered() {
            let quitStudyAlert = UIAlertController(title: NSLocalizedString("main_quit_study",comment: "Join Study"),
                                                        message: NSLocalizedString("main_quit_details", comment: "main_quit_details"),
                                                        preferredStyle: .alert)
            let quitCancelButton = UIAlertAction(title: NSLocalizedString("cancel", comment: "cancel"),
                                                      style: .cancel, handler: { (action) in
                                                        
            })
            
            let quitConfirmButton = UIAlertAction(title: NSLocalizedString("confirm", comment: "confirm"),
                                                       style: .destructive, handler: { (action) in
                                                        // quit study
                                                        DispatchQueue.main.async {
                                                            Consent.setConsentRead(state: false)
                                                            Consent.setConsentAnswer(state: false)
                                                            let delegate = UIApplication.shared.delegate as! AppDelegate
                                                            delegate.quitStudy()
                                                            self.viewWillAppear(true)
                                                            // exit(0)
                                                        }
            })
            quitStudyAlert.addAction(quitCancelButton)
            quitStudyAlert.addAction(quitConfirmButton)
            self.present(quitStudyAlert, animated: true, completion: {
                
            })
        }else{
            let joinStudyAlert = UIAlertController(title: NSLocalizedString("main_join_study",comment: "Join Study"),
                                                        message: NSLocalizedString("main_demo_details", comment: "main_demo_details"),
                                                        preferredStyle: .alert)
            let joinCancelButton = UIAlertAction(title: NSLocalizedString("cancel", comment: "cancel"),
                                                      style: .cancel, handler: { (action) in
                                                        
            })
            
            let joinConfirmButton = UIAlertAction(title: NSLocalizedString("confirm", comment: "confirm"),
                                                       style: .default, handler: { (action) in
                                                        // join study
                                                        DispatchQueue.main.async {
                                                            Consent.setConsentRead(state: false)
                                                            Consent.setConsentAnswer(state: false)
                                                            self.viewWillAppear(true)
                                                        }
            })
            joinStudyAlert.addAction(joinCancelButton)
            joinStudyAlert.addAction(joinConfirmButton)
            self.present(joinStudyAlert, animated: true, completion: {
                
            })
        }
    }

}
