//
//  FeedbackViewController.swift
//  STOP
//
//  Created by Yuuki Nishiyama on 2018/04/12.
//  Copyright © 2018 Yuuki Nishiyama. All rights reserved.
//

import UIKit
import AWAREFramework

class FeedbackViewController: UIViewController {

    @IBOutlet weak var deviceNameField: UITextField!
    @IBOutlet weak var deviceIdField: UITextField!
    @IBOutlet weak var feedbackMessageField: UITextView!
    
    var feedbackSensor:Feedback?
    
    required init?(coder aDecoder: NSCoder) {
        // fatalError("init(coder:) has not been implemented")
        super.init(coder: aDecoder)
        feedbackSensor = Feedback.init()
        feedbackSensor?.createTable()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        deviceNameField.text = AWAREStudy.shared()!.getDeviceName()
        deviceIdField.text = AWAREStudy.shared()!.getDeviceId()
        // Do any additional setup after loading the view.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func pushedClearButton(_ sender: Any) {
        feedbackMessageField.text = ""
    }
    
    @IBAction func pushedAudioInputButton(_ sender: Any) {
    
    }
    
    
    /// Upload a feedback to the server
    ///
    /// - Parameter sender: A notification sender
    @IBAction func pushedSubmitButton(_ sender: Any) {
        
        if let deviceName = self.deviceNameField.text,
           let feedbackText = self.feedbackMessageField.text,
        let feedbackSensor = self.feedbackSensor {
            feedbackSensor.saveFeedback(deviceName: deviceName, feedback: feedbackText)
            feedbackSensor.storage.startSyncStorage { (name, progress, error) in
                print(name)
            }
            feedbackSensor.startSyncDB()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.feedbackMessageField.endEditing(true)
        self.view.endEditing(true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
