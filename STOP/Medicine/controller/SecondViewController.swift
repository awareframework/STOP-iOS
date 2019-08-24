//
//  SecondViewController.swift
//  STOP
//
//  Created by Yuuki Nishiyama on 2018/04/12.
//  Copyright © 2018 Yuuki Nishiyama. All rights reserved.
//

import UIKit
import AWAREFramework
import SVProgressHUD

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
                        let alertController = UIAlertController.init(title: "Is the date and time correct?", message: self.convertStringFromDate(date: unwrappedDate) , preferredStyle: .alert)
                        // an action of a yes button
                        let yesButton = UIAlertAction.init(title: "Yes", style: .default) { (action) in
                            self.medicationSensor.saveMedication(timestamp: unwrappedDate)
                            self.medicationSensor.startSyncDB()
                            self.reloadTableContents()
                        }
                        /** The case of converted the voice input value to a date-time value incorrectly */
                        // an action of cancle button
                        let cancelButton = UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil)
                        // add buttons to the alert controller
                        alertController.addAction(yesButton)
                        alertController.addAction(cancelButton)
                        // show the alert controller
                        self.present(alertController, animated: true) {
                        }
                    }else{
                        // alert controller
                        let alertController = UIAlertController.init(title: "Our system could not convert your voice input to a date-time  correclty. Please try it again.", message: nil, preferredStyle: .alert)
                        // an action of cancle button
                        let cancelButton = UIAlertAction.init(title: "Close", style: .cancel, handler: nil)
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
        let datetime = Date(unixTimestamp: timestamp/1000)
        
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
        let selectedDateTime = Date(unixTimestamp:medication.timestamp/1000)
        let alert: UIAlertController = UIAlertController(title: NSLocalizedString("medication_modify_title", comment: "medication_modify_title"), message: "\(convertStringFromDate(date: selectedDateTime))", preferredStyle: .alert)

        let deleteAction: UIAlertAction = UIAlertAction(title:NSLocalizedString("delete", comment: "delete"), style: .destructive, handler:{ (action: UIAlertAction!) -> Void in
            print("Delete")
            self.medicationSensor.removeMedication(object: medication)
            self.reloadTableContents()
            
            SVProgressHUD.showInfo(withStatus: NSLocalizedString("medication_deleted", comment: "medication_deleted"))
            SVProgressHUD.setDefaultStyle(.dark)
            SVProgressHUD.dismiss(withDelay: 2)
        })
        let cancelAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("cancel", comment: "Cancel"), style: .cancel, handler:{
            (action: UIAlertAction!) -> Void in
            print("Cancel")
        })
        let defaultAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("edit", comment: "Edit"), style: .default, handler:{
            (action: UIAlertAction!) -> Void in
            let alert = UIAlertController(title: NSLocalizedString("medication_modify_title", comment: "Modify medication record"), message: nil, preferredStyle: .alert)
            var selectedData = Date(unixTimestamp: medication.double_medication/1000)
            alert.addDatePicker(mode: .dateAndTime, date: selectedData, minuteInterval: 15) { (date) in
                selectedData = date
            }
            alert.addAction(image: nil, title: "OK", color: nil, style: .cancel) { action in
                // check future data or not
                if selectedData.timeIntervalSince1970 <= Date().timeIntervalSince1970 {
                    medication.double_medication = selectedData.timeIntervalSince1970*1000.0
                    medication.timestamp = Date().timeIntervalSince1970*1000.0
                    self.medicationSensor.updateMedication(object: medication)
                    self.medicationSensor.startSyncDB()
                    self.reloadTableContents()
                }else{
                    SVProgressHUD.setDefaultStyle(.dark)
                    SVProgressHUD.showInfo(withStatus: NSLocalizedString("medication_future", comment: "medication_future"))
                    SVProgressHUD.dismiss(withDelay: 2)
                }
            }
            self.present(alert, animated: true, completion: nil)
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
        let alert = UIAlertController(title: NSLocalizedString("medication_when_last_time", comment: "When have you taken medication last time?"), message: nil, preferredStyle: .alert)
        var selectedData = Date.init()
        alert.addDatePicker(mode: .dateAndTime, date: Date.init(), minuteInterval: 15) { (date) in
            // print(date)
            selectedData = date
        }
        // alert.addAction(title: "OK", style: .cancel)
        alert.addAction(image: nil, title: "OK", color: nil, style: .default ) { action in
            // completion handler
            if selectedData.timeIntervalSince1970 <= Date().timeIntervalSince1970 {
                self.medicationSensor.saveMedication(timestamp: selectedData)
                self.medicationSensor.startSyncDB()
                self.reloadTableContents()
            }else{
                SVProgressHUD.showInfo(withStatus: NSLocalizedString("medication_future", comment: "medication_future"))
                SVProgressHUD.setDefaultStyle(.dark)
                SVProgressHUD.dismiss(withDelay: 2)
            }
        }
        alert.addAction(image: nil, title: NSLocalizedString("cancel", comment: "Cancel"), color: nil, style: .cancel) { action in
            
        }
        present(alert, animated: true, completion: nil)
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


// MARK: - Initializers
public extension Date {
    
    /// SwifterSwift: Create a new date form calendar components.
    ///
    ///     let date = Date(year: 2010, month: 1, day: 12) // "Jan 12, 2010, 7:45 PM"
    ///
    /// - Parameters:
    ///   - calendar: Calendar (default is current).
    ///   - timeZone: TimeZone (default is current).
    ///   - era: Era (default is current era).
    ///   - year: Year (default is current year).
    ///   - month: Month (default is current month).
    ///   - day: Day (default is today).
    ///   - hour: Hour (default is current hour).
    ///   - minute: Minute (default is current minute).
    ///   - second: Second (default is current second).
    ///   - nanosecond: Nanosecond (default is current nanosecond).
    init?(
        calendar: Foundation.Calendar? = Calendar.current,
        timeZone: TimeZone? = NSTimeZone.default,
        era: Int? = DateComponents().era ,
        year: Int? = DateComponents().year,
        month: Int? = DateComponents().month,
        day: Int? = DateComponents().day,
        hour: Int? = DateComponents().hour,
        minute: Int? = DateComponents().minute,
        second: Int? = DateComponents().second,
        nanosecond: Int? = DateComponents().nanosecond) {
        
        var components = DateComponents()
        components.calendar = calendar
        components.timeZone = timeZone
        components.era = era
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        components.minute = minute
        components.second = second
        components.nanosecond = nanosecond
        
        guard let date = calendar?.date(from: components) else { return nil }
        self = date
    }
    
    /// SwifterSwift: Create date object from ISO8601 string.
    ///
    ///     let date = Date(iso8601String: "2017-01-12T16:48:00.959Z") // "Jan 12, 2017, 7:48 PM"
    ///
    /// - Parameter iso8601String: ISO8601 string of format (yyyy-MM-dd'T'HH:mm:ss.SSSZ).
    init?(iso8601String: String) {
        // https://github.com/justinmakaila/NSDate-ISO-8601/blob/master/NSDateISO8601.swift
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        guard let date = dateFormatter.date(from: iso8601String) else { return nil }
        self = date
    }
    
    /// SwifterSwift: Create new date object from UNIX timestamp.
    ///
    ///     let date = Date(unixTimestamp: 1484239783.922743) // "Jan 12, 2017, 7:49 PM"
    ///
    /// - Parameter unixTimestamp: UNIX timestamp.
    init(unixTimestamp: Double) {
        self.init(timeIntervalSince1970: unixTimestamp)
    }
    
    /// SwifterSwift: Create date object from Int literal
    ///
    ///     let date = Date(integerLiteral: 2017_12_25) // "2017-12-25 00:00:00 +0000"
    /// - Parameter value: Int value, e.g. 20171225, or 2017_12_25 etc.
    init?(integerLiteral value: Int) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        guard let date = formatter.date(from: String(value)) else { return nil }
        self = date
    }
    
}

