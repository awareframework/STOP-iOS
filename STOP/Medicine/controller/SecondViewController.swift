//
//  SecondViewController.swift
//  STOP
//
//  Created by Yuuki Nishiyama on 2018/04/12.
//  Copyright © 2018 Yuuki Nishiyama. All rights reserved.
//

import UIKit
import AWAREFramework

class SecondViewController: MainViewController, UITableViewDelegate, UITableViewDataSource{

    @IBOutlet weak var specifyTimeButton: UIButton!
    
    @IBOutlet weak var speechRecognitionView: SpeechRecognitionView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var backgroundView: UIView!
    
    private let medicationSensor = Medication.init()
    
    @IBOutlet weak var voiceInputButtonView: UIView!
    
    @IBOutlet weak var fiftyPercentConstraintForSpecifyTime: NSLayoutConstraint!
    @IBOutlet weak var fiftyPercentConstraintForNow: NSLayoutConstraint!
    
    @IBOutlet weak var thirtyPercentConstraintForSpecifyTime: NSLayoutConstraint!
    @IBOutlet weak var thirtyPercentConstraintForNow: NSLayoutConstraint!
    
    @IBOutlet weak var demoButton: UIBarButtonItem!
    
    var medications:Array<EntityMedication> = []
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        medicationSensor.createTable()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        speechRecognitionView.isHidden = true
        speechRecognitionView.speechRecognitionStartHandler = ({()-> Void in
            print("start")
        })
        speechRecognitionView.speechRecognitionUpdateHandler = ({(result)-> Void in
            // print("update: \(result)")
        })
        speechRecognitionView.speechRecognitionEndHandler = ({(result)-> Void in
            print("end: \(result)")
            // hide speech recogntion views
            self.backgroundView.isHidden = true
            self.speechRecognitionView.isHidden = true
            let wit = WitApiHelper()
            wit.serverResponseHandler = ({(date) -> Void in
                DispatchQueue.main.async {
                    if let unwrappedDate = date {
                        /** The case of converted the voice input value to a date-time value correctly */
                        // alert controller
                        let alertController = UIAlertController.init(title: "Is the date and time correct?", message: self.convertStringFromDate(date: unwrappedDate) , preferredStyle: UIAlertControllerStyle.alert)
                        // an action of a yes button
                        let yesButton = UIAlertAction.init(title: "Yes", style: UIAlertActionStyle.default) { (action) in
                            self.medicationSensor.saveMedication(timestamp: unwrappedDate)
                            self.medicationSensor.startSyncDB()
                            self.reloadTableContents()
                        }
                        /** The case of converted the voice input value to a date-time value incorrectly */
                        // an action of cancle button
                        let cancelButton = UIAlertAction.init(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
                        // add buttons to the alert controller
                        alertController.addAction(yesButton)
                        alertController.addAction(cancelButton)
                        // show the alert controller
                        self.present(alertController, animated: true) {
                        }
                    }else{
                        // alert controller
                        let alertController = UIAlertController.init(title: "Our system could not convert your voice input to a date-time  correclty. Please try it again.", message: nil, preferredStyle: UIAlertControllerStyle.alert)
                        // an action of cancle button
                        let cancelButton = UIAlertAction.init(title: "Close", style: UIAlertActionStyle.cancel, handler: nil)
                        // add buttons to the alert controller
                        alertController.addAction(cancelButton)
                        // show the alert controller
                        self.present(alertController, animated: true) {
                        }
                    }
                }
            })
            wit.convertTextToTimestamp(result)
        })
        backgroundView.isHidden = true
        speechRecognitionView.defaultMessage = NSLocalizedString("voice_when_taken", comment: "voice_when_taken")// "When have you taken medication last time?"
        reloadTableContents()
        adjustButtonSizes()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // set title
        if(!Consent.isConsentAnswered() && Consent.isConsentRead()){
            self.demoButton.title = "Demo"
            self.demoButton.isEnabled = true
        }else{
            self.demoButton.title = ""
            self.demoButton.isEnabled = false
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        adjustButtonSizes()
    }

    func adjustButtonSizes(){
        if !Language().isEnglish() {
            voiceInputButtonView.isHidden = true
            NSLayoutConstraint.deactivate([thirtyPercentConstraintForNow, thirtyPercentConstraintForSpecifyTime])
            NSLayoutConstraint.activate([fiftyPercentConstraintForNow, fiftyPercentConstraintForSpecifyTime])
        }else{
            voiceInputButtonView.isHidden = false
            NSLayoutConstraint.deactivate([fiftyPercentConstraintForNow, fiftyPercentConstraintForSpecifyTime])
            NSLayoutConstraint.activate([thirtyPercentConstraintForNow, thirtyPercentConstraintForSpecifyTime])
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func reloadTableContents(){
        //if let awareDelegate = UIApplication.shared.delegate as? AWAREDelegate{
        medications = medicationSensor.getAllMedications()
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return medications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "MedicationCell", for: indexPath)
        let timestamp = medications[indexPath.row].double_medication
        let datetime = Date.init(unixTimestamp: timestamp/1000)
        
        var number = 0
        if medications.count > 0 {
            number = medications.count - indexPath.row
        }
        cell.textLabel!.text = "\(number) ) \t \( self.convertStringFromDate(date: datetime))"
        cell.textLabel!.textAlignment = NSTextAlignment.center
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // print("cell:\(indexPath.row) fruits:\(medications[indexPath.row])")
        let medication:EntityMedication = medications[indexPath.row]
        let selectedDateTime = Date.init(unixTimestamp:medication.timestamp/1000)
        let alert: UIAlertController = UIAlertController(title: NSLocalizedString("medication_modify_title", comment: "medication_modify_title"), message: "\(convertStringFromDate(date: selectedDateTime))", preferredStyle:  UIAlertControllerStyle.alert)

        let deleteAction: UIAlertAction = UIAlertAction(title:NSLocalizedString("medication_deleted", comment: "medication_deleted") , style: UIAlertActionStyle.destructive, handler:{ (action: UIAlertAction!) -> Void in
            print("Delete")
            self.medicationSensor.removeMedication(object: medication)
            self.reloadTableContents()
        })
        let cancelAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("cancel", comment: "Cancel"), style: UIAlertActionStyle.cancel, handler:{
            (action: UIAlertAction!) -> Void in
            print("Cancel")
        })
        let defaultAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("edit", comment: "Edit"), style: UIAlertActionStyle.default, handler:{
            (action: UIAlertAction!) -> Void in
            let alert = UIAlertController(style: .alert, title: NSLocalizedString("medication_modify_title", comment: "Modify medication record") )//"Select date")
            var selectedData = Date.init(unixTimestamp: medication.double_medication/1000)
            alert.addDatePicker(mode: .dateAndTime, date: selectedData, minuteInterval: 15) { (date) in
                selectedData = date
            }
            alert.addAction(image: nil, title: "OK", color: nil, style: .cancel) { action in
                medication.double_medication = selectedData.timeIntervalSince1970*1000.0
                medication.timestamp = Date().timeIntervalSince1970*1000.0
                self.medicationSensor.updateMedication(object: medication)
                self.medicationSensor.startSyncDB()
                self.reloadTableContents()
            }
            alert.show()
            print("Edit")
        })
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        alert.addAction(defaultAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    
    /// This method is called then the setting button on the menu bar is pushed.
    /// Moreover, this method make options to move a next view.
    /// - Parameter sender: The generator of this event
    @IBAction override func pushedSettingButton(_ sender: Any) {
        super.pushedSettingButton(sender)
    }
    
    @IBAction func pushedSpecifyTimeButton(_ sender: Any) {
        let alert = UIAlertController(style: .alert, title: NSLocalizedString("medication_when_last_time", comment: "When have you taken medication last time?"))
        var selectedData = Date.init()
        alert.addDatePicker(mode: .dateAndTime, date: Date.init(), minuteInterval: 15) { (date) in
            // print(date)
            selectedData = date
        }
        // alert.addAction(title: "OK", style: .cancel)
        alert.addAction(image: nil, title: "OK", color: nil, style: .default ) { action in
            // completion handler
            self.medicationSensor.saveMedication(timestamp: selectedData)
            self.medicationSensor.startSyncDB()
            self.reloadTableContents()
        }
        alert.addAction(image: nil, title: NSLocalizedString("cancel", comment: "Cancel"), color: nil, style: .cancel) { action in
            
        }
        alert.show()
    }
    
    @IBAction func pushedVoiceInputButton(_ sender: Any) {
        speechRecognitionView.isHidden = false
        backgroundView.isHidden = false
        speechRecognitionView.pushedMicControlButton(self)
    }
    
    @IBAction func pushedCurrentTimeButton(_ sender: Any) {
        medicationSensor.saveMedication( timestamp: Date.init() )
        medicationSensor.startSyncDB()
        reloadTableContents()
    }
    
    
    func convertStringFromDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = NSTimeZone.default
        // dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.dateFormat = "HH:mm dd MMM yyyy"
        
        return dateFormatter.string(from: date)
    }
    
    @IBAction func pushedDemoButton(_ sender: UIBarButtonItem) {
        super.pushedDemoButton()
    }
    
}



