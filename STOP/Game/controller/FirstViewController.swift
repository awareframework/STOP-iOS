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

    @IBOutlet weak var smallCircle: UIImageView!
    @IBOutlet weak var bigCircle: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var ballImage: UIImageView!
    
    var startTimer = Timer()
    var gameTimer  = Timer()
    var count = 3
    var timeCount = 0
    
    let accelerometer = Accelerometer.init()
    let linearAccelerometer = LinearAccelerometer.init()
    let gyroScope = Gyroscope.init()
    let rotation = Rotation.init()
    let ballGame = BallGame.init()
    
    // ball game variables
    private var ballXpos=0.0, ballXmax=0.0, ballXaccel=0.0, ballXvel=0.0;
    private var ballYpos=0.0, ballYmax=0.0, ballYaccel=0.0, ballYvel=0.0;
//    private var bigCircleXpos=0.0, bigCircleYpos=0.0;
//    private var smallCircleXpos=0.0, smallCircleYpos=0.0;
    private var ballMaxDistance = 0.0, scoreRaw = 0.0;
    private var deviceXres = 0.0, deviceYres = 0.0, scoreCounter = 0;
    
    // Ball game settings variables
    private var ballSize = UserDefaults.standard.double(forKey: STOPKeys.SETTING_BALL_SIZE);
    private var smallCircleSize = UserDefaults.standard.double(forKey: STOPKeys.SETTING_SMALL_CIRCLE_SIZE);
    private var bigCircleSize = UserDefaults.standard.double(forKey: STOPKeys.SETTING_BIG_CIRCLE_SIZE);
    private var sensitivity = UserDefaults.standard.double(forKey: STOPKeys.SETTING_SENSITIVITY); // 3.0 is default
    private var gameTime = UserDefaults.standard.double(forKey: STOPKeys.SETTING_GAME_TIME)//*1000; // in milliseconds
    
    // sampling flag
    private var sampling = false;
    
    // Strings for storing sampling data in JSON format
    private var gameData = String();
    private var accelSamples = String();
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
        
        smallCircle.isHidden = true
        bigCircle.isHidden = true
        startButton.isHidden = false
        
        self.setGameContents()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidLayoutSubviews() {
        // self.setGameContents()
        // put circles to the center
        smallCircle.frame = CGRect.init(x:0 , y:0, width: smallCircleSize, height: smallCircleSize)
        bigCircle.frame   = CGRect.init(x:0 , y:0, width: bigCircleSize,   height: bigCircleSize)
        
        smallCircle.center = startButton.center
        bigCircle.center = startButton.center
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // check a consent state
        if(!ConsentViewController.isAnswered()){
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "ConsentViewIdentifier") as! ConsentViewController
            // Alternative way to present the new view controller
            // self.navigationController?.show(vc, sender: nil)
            self.present(vc, animated: true, completion: {
                
            })
        }
        
    }

    override func viewDidAppear(_ animated: Bool) {
        self.setGameContents()
    }
    
    private func setGameContents () {
        
        ballSize = UserDefaults.standard.double(forKey: STOPKeys.SETTING_BALL_SIZE);
        smallCircleSize = UserDefaults.standard.double(forKey: STOPKeys.SETTING_SMALL_CIRCLE_SIZE);
        bigCircleSize = UserDefaults.standard.double(forKey: STOPKeys.SETTING_BIG_CIRCLE_SIZE);
        sensitivity = UserDefaults.standard.double(forKey: STOPKeys.SETTING_SENSITIVITY); // 3.0 is default
        gameTime = UserDefaults.standard.double(forKey: STOPKeys.SETTING_GAME_TIME)// *1000; // in milliseconds
        
        ballImage.frame = CGRect.init(x:0,y:0, width:ballSize, height:ballSize)
        ballImage.center = startButton.center
        // ballImage.setNeedsLayout()
        
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
        smallCircle.frame = CGRect.init(x:0 , y:0, width: smallCircleSize, height: smallCircleSize)
        bigCircle.frame   = CGRect.init(x:0 , y:0, width: bigCircleSize,   height: bigCircleSize)
    
        smallCircle.center = startButton.center
        bigCircle.center = startButton.center
    }

    @IBAction func pushedStartButton(_ sender: Any) {
        
        smallCircle.isHidden = false
        bigCircle.isHidden = false
        startButton.isHidden = true
        count = 3
        timeCount = 0
        
        self.startGame()
        
        startTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats:true) { (sTimer) in
            // print(self.timeCount)
            if self.count > 0 {
                self.messageLabel?.text = "...\(self.count)"
                self.count = self.count - 1
            } else {
                sTimer.invalidate()
                self.sampling = true
                
                self.messageLabel?.text = "start!"// "point"
                
                self.gameTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (gTimer) in
                    self.timeCount = self.timeCount + 1
                    self.messageLabel?.text = "time: \(self.timeCount)"// "point"
                    
                    if self.timeCount > Int(self.gameTime){
                        gTimer.invalidate()
                        self.stopGame()
                    }
                })
            }
        }
    }
    
    func startGame(){
        
        accelSamples = ""
        linaccelSamples = ""
        gyroSamples = ""
        rotationSamples = ""
        scoreRaw = 0
        scoreCounter = 0
        
        gameData = "{\"gamedata\":[{\"ball_radius\":\(ballSize),\"sensitivity\":\(sensitivity),\"device_x_res\":\(deviceXres),\"device_y_res\":\(deviceYres),\"samples\":["
        print(gameData)
        
        let block:SensorEventHandler = {(sensor:AWARESensor?,data:[AnyHashable:Any]?) -> Void in
            if let unwrappedSensor = sensor, let unwrappedData = data{
                do{
                    let jsonData   = try JSONSerialization.data(withJSONObject: unwrappedData, options: [])
                    let jsonString = String.init(data: jsonData, encoding: String.Encoding.utf8)
                    if var unwrappedJsonStr = jsonString {
                        unwrappedJsonStr.append(",")
                        if unwrappedSensor.getName() == self.accelerometer.getName() {
                            /// acc ///
                            /// @todo [-1 problem]
                            self.ballXaccel = -1 * (unwrappedData[self.SAMPLE_KEY_DOUBLE_VALUES_0] as! Double)
                            self.ballYaccel = (unwrappedData[self.SAMPLE_KEY_DOUBLE_VALUES_1] as! Double)
                            self.updateBall(unwrappedData[self.SAMPLE_KEY_TIMESTAMP] as! Int64)
                            self.accelSamples .append(unwrappedJsonStr)
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

        accelerometer.setSensingIntervalWithSecond(20000.0/1000.0/1000.0)
        
        accelerometer.startSensor()
        linearAccelerometer.startSensor()
        gyroScope.startSensor()
        rotation.startSensor()
        

    }
    
    func stopGame(){
        
        cancelGame()
        
        // calculating game score
        let finalScore = 100 - ((scoreRaw/Double(scoreCounter)) / ballMaxDistance)*100;
        self.messageLabel?.text = "finish: score is \( String(format: "%.2f",finalScore)) \n"
        
        /// save the final result to GallGame table
        let gameResult = "\(gameData.prefix(gameData.count-1))],\"score\":\(finalScore)}]"
        var accResult = "\"accelerometer\":[]"
        var linAccResult = "\"linearaccelerometer\":[]"
        var gyroResult = "\"gyroscope\":[]"
        var rotationResult = "\"rotation\":[]"
        
        if accelSamples.count > 0 {
            accResult = "\"accelerometer\":[\(accelSamples.prefix(accelSamples.count-1))]"
        }
        
        if linaccelSamples.count > 0 {
            linAccResult = "\"linearaccelerometer\":[\(linaccelSamples.prefix(linaccelSamples.count-1))]"
        }
        
        if gyroSamples.count > 0 {
            gyroResult = "\"gyroscope\":[\(gyroSamples.prefix(gyroSamples.count-1))]"
        }
        
        if rotationSamples.count > 0 {
            rotationResult = "\"rotation\":[\(rotationSamples.prefix(rotationSamples.count-1))]"
        }
        
        let result = "\(gameResult),\(accResult),\(linAccResult),\(gyroResult),\(rotationResult)}"
        
        ballGame.saveData(data: result)
        
        // sync the remote server after 3 seconds
        let dispatchTime = DispatchTime.now() + 3
        DispatchQueue.main.asyncAfter( deadline: dispatchTime ) {
            self.ballGame.storage.setDebug(true)
            self.ballGame.storage.startSyncStorage()
        }
    }
    
    func cancelGame(){
        accelerometer.stopSensor()
        linearAccelerometer.stopSensor()
        gyroScope.stopSensor()
        rotation.stopSensor()
        
        if startTimer.isValid {
            startTimer.invalidate()
        }
        
        if gameTimer.isValid {
            gameTimer.invalidate()
        }
        
        self.smallCircle.isHidden = true
        self.bigCircle.isHidden = true
        self.startButton.isHidden = false
        
        self.sampling = false
        
        self.messageLabel?.text = "Push to play the game!"
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
        
        self.ballImage.frame = CGRect.init(x: ballXpos,
                                           y: ballYpos,
                                           width: Double(ballImage.frame.width),
                                           height:Double(ballImage.frame.height))
    }

    override func viewWillDisappear(_ animated: Bool) {
        // A game session is canceled when the view is changed.
        self.cancelGame()
    }
    
    @IBAction func pushedSettingButton(_ sender: Any) {

        let alertController = UIAlertController.init(title: "Move to...", message: nil, preferredStyle: UIAlertControllerStyle.alert)

        let settingsButton = UIAlertAction.init(title: "Settings", style: UIAlertActionStyle.default) { (action) in
            if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SettingsView") as? SettingsTableViewController {
                if let navigator = self.navigationController {
                    self.cancelGame()
                    navigator.pushViewController(viewController, animated: true)
                }
            }
        }
        
        let feedbackButton = UIAlertAction.init(title: "Feedback", style: UIAlertActionStyle.default) { (action) in
            if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FeedbackView") as? FeedbackViewController {
                if let navigator = self.navigationController {
                    self.cancelGame()
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

