//
//  SecondViewController.swift
//  STOP
//
//  Created by Yuuki Nishiyama on 2018/04/12.
//  Copyright © 2018 Yuuki Nishiyama. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController, UITableViewDelegate{

    @IBOutlet weak var speechRecognitionView: SpeechRecognitionView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var backgroundView: UIView!
    
    private let medicationSensor = Medication.init()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        medicationSensor.createTable()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        speechRecognitionView.isHidden = true
        backgroundView.isHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /// This method is called then the setting button on the menu bar is pushed.
    /// Moreover, this method make options to move a next view.
    /// - Parameter sender: The generator of this event
    @IBAction func pushedSettingButton(_ sender: Any) {
        let alertController = UIAlertController.init(title: "Move to...", message: nil, preferredStyle: UIAlertControllerStyle.alert)
        
        let settingsButton = UIAlertAction.init(title: "Settings", style: UIAlertActionStyle.default) { (action) in
            if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SettingsView") as? SettingsTableViewController {
                if let navigator = self.navigationController {
                    navigator.pushViewController(viewController, animated: true)
                }
            }
        }
        
        let feedbackButton = UIAlertAction.init(title: "Feedback", style: UIAlertActionStyle.default) { (action) in
            if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FeedbackView") as? FeedbackViewController {
                if let navigator = self.navigationController {
                    navigator.pushViewController(viewController, animated: true)
                }
            }
        }
        
        let cancelButton = UIAlertAction.init(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        
        alertController.addAction(settingsButton)
        alertController.addAction(feedbackButton)
        alertController.addAction(cancelButton)
        
        present(alertController, animated: true) {
            
        }
    }
    
    @IBAction func pushedSpecifyTimeButton(_ sender: Any) {
        let alert = UIAlertController(style: .alert, title: "Select date")
        var selectedData = Date.init()
        alert.addDatePicker(mode: .dateAndTime, date: Date.init(), minuteInterval: 15) { (date) in
            // print(date)
            selectedData = date
        }
        // alert.addAction(title: "OK", style: .cancel)
        alert.addAction(image: nil, title: "OK", color: nil, style: .cancel) { action in
            // completion handler
            self.medicationSensor.saveMedication(timestamp: selectedData)
            self.medicationSensor.startSyncDB()
        }
        alert.show()
    }
    
    @IBAction func pushedVoiceInputButton(_ sender: Any) {
        speechRecognitionView.isHidden = false
        backgroundView.isHidden = false
        speechRecognitionView.pushedMicControlButton(self)
    }
    
    @IBAction func pushedCurrentTimeButton(_ sender: Any) {
        medicationSensor.saveMedication(timestamp: Date.init() )
        medicationSensor.startSyncDB()
    }
    
}



