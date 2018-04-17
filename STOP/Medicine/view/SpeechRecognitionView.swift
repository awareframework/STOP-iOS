//
//  SpeachRecognitionView.swift
//  STOP
//
//  Created by Yuuki Nishiyama on 2018/04/17.
//  Copyright © 2018 Yuuki Nishiyama. All rights reserved.
//

import UIKit
import Speech

class SpeechRecognitionView: UIView, SFSpeechRecognizerDelegate {

    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var micControlButton: UIButton!
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en_US"))!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    override func awakeFromNib() {
        let view:UIView = Bundle.main.loadNibNamed("SpeechRecognitionView", owner:self , options: nil)?.first as! UIView
        addSubview(view)
        
        // Do any additional setup after loading the view, typically from a nib.
        speechRecognizer.delegate = self
        let image:UIImage = UIImage(named:"ic_mic_light")!
        micControlButton.backgroundColor = UIColor.init(red:31.0/255 , green: 148.0/255, blue: 249.0/255, alpha: 1.0)
        micControlButton.setImage(image, for: UIControlState.normal)
    }
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    
    
    @IBAction func pushedMicControlButton(_ sender: Any) {
        requestRecognizerAuthorization()
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            print("stop")
            let image:UIImage = UIImage(named:"ic_mic_light")!
            micControlButton.backgroundColor = UIColor.init(red:31.0/255 , green: 148.0/255, blue: 249.0/255, alpha: 1.0)
            micControlButton.setImage(image, for: UIControlState.normal)
        } else {
            do{
                try startRecording()
                let image:UIImage = UIImage(named:"ic_mic")!
                micControlButton.backgroundColor = UIColor.white
                micControlButton.setImage(image, for: UIControlState.normal)
                print("start")
            }catch{
                print("\(error)")
            }
        }
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

