//
//  SecondViewController.swift
//  STOP
//
//  Created by Yuuki Nishiyama on 2018/04/12.
//  Copyright © 2018 Yuuki Nishiyama. All rights reserved.
//

import UIKit
import Speech

class SecondViewController: UIViewController, UITableViewDelegate, SFSpeechRecognizerDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en_US"))!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    private let medicationSensor = Medication.init()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        medicationSensor.createTable()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        speechRecognizer.delegate = self
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
        requestRecognizerAuthorization()
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            print("stop")
            // button.isEnabled = false
        } else {
            do{
                try startRecording()
                print("start")
            }catch{
                print("\(error)")
            }
        }
    }
    
    @IBAction func pushedCurrentTimeButton(_ sender: Any) {
        medicationSensor.saveMedication(timestamp: Date.init() )
        medicationSensor.startSyncDB()
    }
    
    
    ////// audio input related function /////////
    private func startRecording() throws {
        refreshTask()
        
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(AVAudioSessionCategoryRecord)
        try audioSession.setMode(AVAudioSessionModeMeasurement)
        try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        let inputNode = audioEngine.inputNode // else { fatalError("Audio engine has no input node") }
        guard let recognitionRequest = recognitionRequest else { fatalError("Unable to created a SFSpeechAudioBufferRecognitionRequest object") }
        
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let `self` = self else { return }
            
            var isFinal = false
            
            if let result = result {
                isFinal = result.isFinal
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                print(result?.bestTranscription.formattedString)
            }
        }
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.recognitionRequest?.append(buffer)
        }
        
        try startAudioEngine()
    }
    
    private func refreshTask() {
        if let recognitionTask = recognitionTask {
            recognitionTask.cancel()
            self.recognitionTask = nil
        }
    }
    
    private func startAudioEngine() throws {
        audioEngine.prepare()
        try audioEngine.start()
    }
    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
        
        } else {
        
        }
    }
    
    private func requestRecognizerAuthorization() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            OperationQueue.main.addOperation { [weak self] in
                switch authStatus {
                case .authorized: break
                case .denied: break
                case .restricted: break
                case .notDetermined: break
                }
            }
        }
    }
}



