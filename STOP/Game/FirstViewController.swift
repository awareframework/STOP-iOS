//
//  FirstViewController.swift
//  STOP
//
//  Created by Yuuki Nishiyama on 2018/04/12.
//  Copyright © 2018 Yuuki Nishiyama. All rights reserved.
//

import UIKit
import AWAREFramework

class FirstViewController: UIViewController {

    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var ballImage: UIImageView!
    var appTimer:Timer? = nil
    var count = 3
    
    let accelerometer = Accelerometer.init()
    let linearAccelerometer = LinearAccelerometer.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        accelerometer.setStore(false)
        linearAccelerometer.setStore(false)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidLayoutSubviews() {
        ballImage.center = startButton.center
        ballImage.setNeedsLayout()
    }
    
    @IBAction func pushedStartButton(_ sender: Any) {
        startButton.isHidden = true;
        Timer.scheduledTimer(withTimeInterval: 1, repeats:true) { (timer) in
            if self.count > 0 {
                self.messageLabel?.text = "...\(self.count)"
                self.count = self.count - 1
            } else {
                self.count = 3
                timer.invalidate()
                self.messageLabel?.text = "point"
                self.startGame()
                Timer.scheduledTimer(withTimeInterval: 5, repeats: false, block: { (timer) in
                    self.messageLabel?.text = "finish"
                    self.startButton.isHidden = false
                    timer.invalidate()
                    self.stopGame()
                })
            }
        }
    }
    
    func startGame(){
        
        let block:SensorEventHandler = {(sensor:AWARESensor?,data:[AnyHashable:Any]?) -> Void in
            print(data)
        }
        
        accelerometer.setSensorEventHandler(block)
        accelerometer.startSensor()
        
        linearAccelerometer.setSensorEventHandler(block)
        linearAccelerometer.startSensor()
    }
    
    func stopGame(){
        accelerometer.stopSensor()
        linearAccelerometer.stopSensor()
    }
    
    
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
}

