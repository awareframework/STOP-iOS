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
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var speechRecognitionView: SpeechRecognitionView!
    
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
        backgroundView.isHidden = true
        speechRecognitionView.isHidden = true
        
        speechRecognitionView.speechRecognitionEndHandler = ({ (result) -> Void in
            let alertController = UIAlertController.init(title: "Do you insert this text?", message:result, preferredStyle: UIAlertControllerStyle.alert)
            let yesButton = UIAlertAction.init(title: "Yes", style: UIAlertActionStyle.default) { (action) in
                self.feedbackMessageField.text = self.feedbackMessageField.text + result + ".\n "
            }
            let cancelButton = UIAlertAction.init(title: "Cancel", style: UIAlertActionStyle.cancel) { (action) in
            }
            
            self.backgroundView.isHidden = true
            self.speechRecognitionView.isHidden = true
            
            alertController.addAction(yesButton)
            alertController.addAction(cancelButton)
            
            self.present(alertController, animated: true) {
            }
            
        })
        
        speechRecognitionView.defaultMessage = "What do you think about STOP?"
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func pushedClearButton(_ sender: Any) {
        feedbackMessageField.text = ""
    }
    
    @IBAction func pushedAudioInputButton(_ sender: Any) {
        backgroundView.isHidden = false
        speechRecognitionView.isHidden = false
        
        speechRecognitionView.pushedMicControlButton(self)
    
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
