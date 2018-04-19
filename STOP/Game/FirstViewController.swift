//
//  FirstViewController.swift
//  STOP
//
//  Created by Yuuki Nishiyama on 2018/04/12.
//  Copyright © 2018 Yuuki Nishiyama. All rights reserved.
//

import UIKit
import Foundation
import AWAREFramework

class FirstViewController: UIViewController {

    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var ballImage: UIImageView!
    var appTimer:Timer? = nil
    var count = 3
    
    let accelerometer = Accelerometer.init()
    let linearAccelerometer = LinearAccelerometer.init()
    let gyroScope = Gyroscope.init()
    let rotation = Rotation.init()
    
    // ball game variables
    private var ballXpos=0.0, ballXmax=0.0, ballXaccel=0.0, ballXvel=0.0;
    private var ballYpos=0.0, ballYmax=0.0, ballYaccel=0.0, ballYvel=0.0;
//    private var bigCircleXpos, bigCircleYpos;
//    private var smallCircleXpos, smallCircleYpos;
    private var ballMaxDistance = 0.0, scoreRaw = 0.0;
    private var deviceXres = 0.0, deviceYres = 0.0, scoreCounter = 0;
    
    // Ball game settings variables
    private var ballSize = 0;
    private var smallCircleSize = 0;
    private var bigCircleSize = 0;
    private var sensitivity = 10.0; // 3.0 is default
    private var gameTime = 60*1000; // in milliseconds
    
    // sampling flag
    private var sampling = false;
    
    // Strings for storing sampling data in JSON format
    private var gameData = String();
    private var acceSamples = String();
    private var linaccelSamples = String();
    private var gyroSamples = String();
    private var rotationSamples = String();
    
    private let SAMPLE_KEY_TIMESTAMP = "timestamp";
    private let SAMPLE_KEY_DEVICE_ID = "device_id";
    private let SAMPLE_KEY_DOUBLE_VALUES_0 = "double_values_0";
    private let SAMPLE_KEY_DOUBLE_VALUES_1 = "double_values_1";
    private let SAMPLE_KEY_DOUBLE_VALUES_2 = "double_values_2";
    private let SAMPLE_KEY_ACCURACY = "accuracy";
    private let SAMPLE_KEY_LABEL = "label";
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        accelerometer.setStore(false)
        linearAccelerometer.setStore(false)
        gyroScope.setStore(false)
        rotation.setStore(false)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidLayoutSubviews() {
        ballImage.center = startButton.center
        ballImage.setNeedsLayout()
        
        self.deviceXres = Double(self.view.frame.height)
        self.deviceYres = Double(self.view.frame.width)
        
        // setting up the maximum allowed X and Y values
        ballXmax = Double(self.view.frame.width  - ballImage.frame.width)
        ballYmax = Double(self.view.frame.height - ballImage.frame.height)
        
        // put ball to the center
         ballXpos = ballXmax / 2;
         ballYpos = ballYmax / 2;
        
        // count maximum possible distance ball can cover from center
        ballMaxDistance = sqrt(ballXpos*ballXpos + ballYpos*ballYpos);
        
        // put circles to the center
//        smallCircleXpos = (size.x - smallCircleSize)/2;
//        smallCircleYpos = (size.y - smallCircleSize - 235 - 175)/2;
//        bigCircleXpos = (size.x - bigCircleSize)/2;
//        bigCircleYpos = (size.y - bigCircleSize - 235 -175)/2;
    }
    
    @IBAction func pushedStartButton(_ sender: Any) {
        
        /// @todo
        self.sampling = true
        
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
                Timer.scheduledTimer(withTimeInterval: 30, repeats: false, block: { (timer) in
                    self.messageLabel?.text = "finish"
                    self.startButton.isHidden = false
                    timer.invalidate()
                    self.stopGame()
                })
            }
        }
    }
    
    func startGame(){
        
        acceSamples = ""
        linaccelSamples = ""
        gyroSamples = ""
        rotationSamples = ""
        scoreRaw = 0
        scoreCounter = 0
        
        let block:SensorEventHandler = {(sensor:AWARESensor?,data:[AnyHashable:Any]?) -> Void in
            if let unwrappedSensor = sensor, let unwrappedData = data{
                do{
                    let jsonData   = try JSONSerialization.data(withJSONObject: unwrappedData, options: [])
                    let jsonString = String.init(data: jsonData, encoding: String.Encoding.utf8)
                    if var unwrappedJsonStr = jsonString {
                        unwrappedJsonStr.append(",")
                        if unwrappedSensor.getName() == self.accelerometer.getName() {
                            /// acc ///
                            /// @todo -1
                            self.ballXaccel = -1 * (unwrappedData[self.SAMPLE_KEY_DOUBLE_VALUES_0] as! Double)
                            self.ballYaccel = (unwrappedData[self.SAMPLE_KEY_DOUBLE_VALUES_1] as! Double)
                            self.updateBall(unwrappedData[self.SAMPLE_KEY_TIMESTAMP] as! Int64)
                            self.acceSamples.append(unwrappedJsonStr)
                        } else if unwrappedSensor.getName() == self.linearAccelerometer.getName() {
                            /// liner-acc ///
                            self.linaccelSamples.append(unwrappedJsonStr)
                        } else if unwrappedSensor.getName() == self.gyroScope.getName() {
                            self.gyroSamples.append(unwrappedJsonStr)
                        } else if unwrappedSensor.getName() == self.rotation.getName() {
                            self.rotationSamples.append(unwrappedJsonStr)
                        }
                    }
                }catch{
                    print("error: \(error)")
                }
            }
        }

        accelerometer.setSensorEventHandler(block)
        linearAccelerometer.setSensorEventHandler(block)
        gyroScope.setSensorEventHandler(block)
        rotation.setSensorEventHandler(block)

        accelerometer.startSensor()
        linearAccelerometer.startSensor()
        gyroScope.startSensor()
        rotation.startSensor()
        

    }
    
    func stopGame(){
        accelerometer.stopSensor()
        linearAccelerometer.stopSensor()
        gyroScope.startSensor()
        rotation.stopSensor()
    }
    
    
    func updateBall(_ timestamp:Int64) {
        ballXvel = (ballXaccel * sensitivity);
        ballYvel = (ballYaccel * sensitivity);
        
        let xS = (ballXvel / 2) * sensitivity;
        let yS = (ballYvel / 2) * sensitivity;
        
        ballXpos -= xS;
        ballYpos -= yS;
        
        let changeX = ballXpos - ballXmax/2;
        let changeY = ballYpos - ballYmax/2;
        let distance = sqrt(changeX*changeX + changeY*changeY);
        
        if (sampling) {
            gameData.append("{\"timestamp\":\(timestamp),")
            gameData.append("\"ball_x\":\(changeX),")
            gameData.append("\"ball_y\":\(changeY),")
            gameData.append("\"distance\":\(distance)},")
            
            scoreRaw += distance;
            scoreCounter += 1;
        }
        
        //off screen movements
        if (ballXpos > ballXmax) {
            ballXpos = ballXmax;
        } else if (ballXpos < 0) {
            ballXpos = 0;
        }
        
        if (ballYpos > ballYmax) {
            ballYpos = ballYmax;
        } else if (ballYpos < 0) {
            ballYpos = 0;
        }
        
        self.ballImage.frame = CGRect.init(x: ballXpos, y: ballYpos, width: Double(ballImage.frame.width), height:Double( ballImage.frame.height))
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

