//
//  ConsentViewController.swift
//  STOP
//
//  Created by Yuuki Nishiyama on 2018/06/11.
//  Copyright © 2018 Yuuki Nishiyama. All rights reserved.
//

import UIKit
import SVProgressHUD
import AWAREFramework

class ConsentViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, UITextViewDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var baseScrollView: UIScrollView!
    
    // PD state
    @IBOutlet weak var pdStateLabel: UILabel!
    @IBOutlet weak var pdStateSwitch: UISegmentedControl!
    
    // Nickname
    @IBOutlet weak var nickNameView: UIStackView!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var nicknameTextFiled: UITextField!
    
    // Age
    @IBOutlet weak var ageView: UIStackView!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var ageTextField: UITextField!
    
    // PD date label
    @IBOutlet weak var pdLabelView: UIStackView!
    @IBOutlet weak var pdInputView: UIStackView!
    @IBOutlet weak var pdDateLabel: UILabel!
    @IBOutlet weak var pdDateTextField: UITextField!
    @IBOutlet weak var pdDateUnitPicker: UIPickerView!
    var dataUnits:Array<String>?
    
    // Medications
    @IBOutlet weak var medicationLabelView: UIStackView!
    @IBOutlet weak var medicationsLabel: UILabel!
    @IBOutlet weak var medicationsTableView: UITableView!
    
    // Symptoms
    @IBOutlet weak var symptomsLabelView: UIStackView!
    @IBOutlet weak var symptomsLabel: UILabel!
    @IBOutlet weak var symptomsStackView: UIStackView!
    var symptomViews = Array<SymptomContentView>()
    let symptomIds = ["5","6","7","8","9","10","11","12","13","14","15","16","17"]
    let symptomKeys = ["speech",
                       "salivation",
                       "swallowing",
                       "handwriting",
                       "cutting_food_and_handling_utensils",
                       "dressing",
                       "hygiene",
                       "turning_in_bed_and_adjusting_bed_clothes",
                       "falling_(unrelated_to_freezing)",
                       "freezing_when_walking",
                       "walking",
                       "tremor_(symptomatic_complaint_of_tremor_in_any_part_of_body)",
                       "sensory_complaints_related_to_parkinsonism"]
    
    /// Variables for medication tables
    static let identifier = "MedicationsTableViewCell"
    var medicationEditorView:MedicationEditorView?
    var medicationEditorBackgroundView:UIView?
    var medications = Array<MedicationInfo>()
    
    // Conenst
    let consent = Consent()
    
    // Submit button
    @IBOutlet weak var submitButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        pdDateUnitPicker.delegate = self
        pdDateUnitPicker.dataSource = self
        
        nicknameTextFiled.delegate = self
        ageTextField.delegate = self
        pdDateTextField.delegate = self
        
        medicationsTableView.delegate = self
        medicationsTableView.dataSource = self
        medicationsTableView.register(UITableViewCell.self, forCellReuseIdentifier: ConsentViewController.identifier)
        
        // nicknameTextFiled.text = AWAREStudy.shared().getDeviceName()

        let tap = UITapGestureRecognizer.init(target: self, action: #selector(self.dismissKeyboard))
        self.view.addGestureRecognizer(tap)
        
        // set unit of date
        dataUnits = ["months ago", "years ago"]
    
        // set symptom items
        for (index, symptomId) in zip(symptomIds.indices, symptomIds) {
            let symptomView = SymptomContentView(frame:CGRect.init(x: 0, y: 0, width: self.view.bounds.width, height: 0))
            
            symptomView.title?.text = NSLocalizedString("symptom_"+symptomId+"_0", comment: "title of " + symptomId)
            for itemNum in ["1","2","3","4","5"] {
                symptomView.addItem(description: NSLocalizedString("symptom_"+symptomId+"_"+itemNum, comment: "content-"+itemNum+" of "+symptomId))
            }
            symptomView.key = symptomKeys[index]
            symptomsStackView.addArrangedSubview(symptomView)
            symptomViews.append(symptomView)
        }
        
        
        /// set a background view of medication editor
        medicationEditorBackgroundView = UIView(frame:self.view.frame)
        medicationEditorBackgroundView?.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, transparency: 0.5)
        medicationEditorBackgroundView?.isHidden = true
        self.view.addSubview(medicationEditorBackgroundView!)
        
        /// set medication editor view itself
        medicationEditorView = MedicationEditorView.init(frame:CGRect(x:10, y:30, width:self.view.frame.width - 20, height: 430))
        self.view.addSubview(medicationEditorView!)
        medicationEditorView?.isHidden = true
        
        // heightAnchor.constraint(equalToConstant:height).isActive = true
        
        medicationEditorView?.setAddButtonEventHandler({ (medicationInfo:MedicationInfo) in
            self.medicationEditorView?.isHidden = true
            self.medicationEditorBackgroundView?.isHidden = true
            DispatchQueue.main.async {
                self.medications.append(medicationInfo)
                self.medicationsTableView.reloadData()
            }
        })
        
        medicationEditorView?.setCancelButtonEventHandler {
            self.medicationEditorView?.isHidden = true
            self.medicationEditorBackgroundView?.isHidden = true
        }

        
        UIApplication.shared.sendAction(#selector(resignFirstResponder), to: nil, from: nil, for: nil)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        // move to consent details view
        if !Consent.isConsentRead() {
            performSegue(withIdentifier: "consentDetailsView",sender: nil)
        }
    }
    
    @objc func dismissKeyboard(){
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let controller = segue.destination as! ConsentDetailsViewController
        controller.resultHandler = { isAccepted in
            if isAccepted {
                
            } else {
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: { })
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func pushedAddMedicationButton(_ sender: UIButton) {
        medicationEditorView?.isHidden = false
        medicationEditorBackgroundView?.isHidden = false
    }
    

    @IBAction func changedPDState(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0{
            hideContents(false)
        } else {
            hideContents(true)
        }
    }
    
    func hideContents(_ state:Bool){
        pdLabelView.isHidden = state
        pdInputView.isHidden = state
        medicationLabelView.isHidden = state
        symptomsLabelView.isHidden = state
        symptomsStackView.isHidden = state
        medicationsTableView.isHidden = state
    }
    
    
    @IBAction func pushedSubmitButton(_ sender: Any) {

        if checkAllItemsState() {
            if let userAnswer = getUserAnswer() {
                // Join study
                let delegate = UIApplication.shared.delegate as! AppDelegate
                delegate.joinStudy({ (result, state, error) in
                    Consent.setConsentAnswer(state: true)
                    // save the user answer to consent sensor
                    self.consent.saveUserAnswer(userAnswer)
                    self.consent.startSyncDB()
                    self.dismiss(animated: true, completion: {
                        SVProgressHUD.showSuccess(withStatus: NSLocalizedString("consent_loading", comment: "consent_loading"))
                        SVProgressHUD.setDefaultStyle(SVProgressHUDStyle.dark)
                        SVProgressHUD.dismiss(withDelay: 3)
                    })
                })
            } else {
                SVProgressHUD.showError(withStatus: NSLocalizedString("consent_empty_entries", comment: "consent_empty_entries"))
                SVProgressHUD.setDefaultStyle(SVProgressHUDStyle.dark)
                SVProgressHUD.dismiss(withDelay: 3)
            }
        } else {
            SVProgressHUD.showError(withStatus: NSLocalizedString("consent_empty_entries", comment: "consent_empty_entries"))
            SVProgressHUD.setDefaultStyle(SVProgressHUDStyle.dark)
            SVProgressHUD.dismiss(withDelay: 3)
        }
    }
    
    func getUserAnswer() -> String? {
        // append user name
        var userAnswer = Dictionary<String, Any> ()
        AWAREStudy.shared().setDeviceName(nicknameTextFiled?.text)
        userAnswer["username"] = nicknameTextFiled?.text
        
        // append age
        if let age = Int(ageTextField.text!) {
            userAnswer["age"] = age
        }else{
            userAnswer["age"] = 0
        }
        
        // append diagnosed_pd
        if pdStateSwitch.selectedSegmentIndex == 0 {
            userAnswer["diagnosed_pd"] = true
        } else {
            userAnswer["diagnosed_pd"] = false
        }

        // append diagnosed_time, medications, and symptoms information if the PD state is ON
        if pdStateSwitch.selectedSegmentIndex == 0 {
            // diagnosed_time
            let before = Int(self.pdDateTextField.text!)!
            let selectedUnit = self.pdDateUnitPicker.selectedRow(inComponent: 0)
            var date = Date()
            if selectedUnit == 0 { // month ago
                date = self.calcDate(year: 0, month: -1 * before, day: 0, hour: 0, minute: 0, second: 0)
            } else{ // year ago
                date = self.calcDate(year:  -1 * before, month: 0, day: 0, hour: 0, minute: 0, second: 0)
            }
            userAnswer["diagnosed_time"] = AWAREUtils.getUnixTimestamp(date)
            
            // "medications"
            var medicationInfoArray = Array<Dictionary<String,Any>>()
            for medInfo in medications {
                medicationInfoArray.append([
                    "medication":medInfo.medicationName,
                    "times_per_day":medInfo.timesPerDay,
                    "pills_per_time":medInfo.pillsEachTimes,
                    "how_often":medInfo.oftenNumber,
                    "first_med_daily":medInfo.firstMedicationTime,
                    "comment":medInfo.comment
                    ])
            }
            userAnswer["medications"] = medicationInfoArray
            
            // "symptoms"
            var symptomsDict = Dictionary<String, Int>()
            for symptom in symptomViews {
                if symptom.isSelected(){
                    symptomsDict[symptom.key] = symptom.getSelectedItemNumber()
                }
            }
            userAnswer["symptoms"] = symptomsDict
        }
        
        // convert a Dictionary object to JSON-String
        do {
            let jsonData = try JSONSerialization.data(withJSONObject:userAnswer)
            let jsonStr = String.init(data: jsonData, encoding: .utf8)
            return jsonStr
        } catch(let e) {
            print(e)
            return nil
        }
    }
    
    
    func checkAllItemsState()->Bool{
        guard nicknameTextFiled.text?.count > 0 else {
            return false
        }
        
        guard ageTextField.text?.count > 0 else {
            return false;
        }
        
        if pdStateSwitch.selectedSegmentIndex == 0 {
            guard pdDateTextField.text?.count > 0 else {
                return false;
            }
            
            for symptomView in symptomViews {
                guard symptomView.isSelected() else {
                    return false
                }
            }
            
            guard medications.count > 0 else {
                return false
            }
        }
        return true
    }
    
    ////////////////// unit picker view ///////////
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return (dataUnits?.count)!
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return dataUnits?[row]
    }
    
    
    /////////////////// medication table //////////////
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return medications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = medicationsTableView.dequeueReusableCell(withIdentifier: ConsentViewController.identifier, for: indexPath)
        cell.textLabel?.text = medications.item(at: indexPath.row)?.medicationName
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let rowActionDelete = UITableViewRowAction(style: .destructive, title: "Delete") { (action: UITableViewRowAction, idx: IndexPath) in
            self.medications.remove(at: idx.row)
            self.medicationsTableView.reloadData()
        }
        return [rowActionDelete]
    }
    
    
    ////////////////////
    func calcDate(year:Int ,month:Int ,day:Int ,hour:Int ,minute:Int ,second:Int ,baseDate:String? = nil) -> Date {
        
        let formatter = DateFormatter()
        formatter.locale = NSLocale(localeIdentifier: "ja_JP") as Locale
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        var components = DateComponents()
        
        components.setValue(year,for: Calendar.Component.year)
        components.setValue(month,for: Calendar.Component.month)
        components.setValue(day,for: Calendar.Component.day)
        components.setValue(hour,for: Calendar.Component.hour)
        components.setValue(minute,for: Calendar.Component.minute)
        components.setValue(second,for: Calendar.Component.second)
        
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        
        let base:Date?
        
        if let _ = baseDate {
            if let _ = formatter.date(from: baseDate!) {
                base = formatter.date(from: baseDate!)!
            } else {
                base = Date()
            }
        } else {
            base = Date()
        }
        
        return calendar.date(byAdding: components, to: base!)!
    }
    
}
