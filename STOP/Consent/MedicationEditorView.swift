//
//  MedicationEditorView.swift
//  STOP
//
//  Created by Yuuki Nishiyama on 2018/06/22.
//  Copyright © 2018 Yuuki Nishiyama. All rights reserved.
//

import UIKit
import SVProgressHUD

struct MedicationInfo {
    var medicationName = ""
    var timesPerDay    = ""
    var pillsEachTimes = ""
    var oftenNumber    = ""
    var oftenUnit      = ""
    var firstMedicationTime = ""
    var comment        = ""
}

@IBDesignable class MedicationEditorView: UIView, UIPickerViewDelegate, UIPickerViewDataSource {

    public typealias MedicationEditorAddButtonEventHandler = (_ medicationInfo:MedicationInfo) -> Void
    public typealias MedicationEditorCancelButtonEventHandler = () -> Void
    
    @IBOutlet weak var medicationNameField: UITextField!
    @IBOutlet weak var timesPerDayField: UITextField!
    @IBOutlet weak var pillsEachTimesField: UITextField!
    @IBOutlet weak var oftenNumberField: UITextField!
    @IBOutlet weak var oftenUnitPicker: UIPickerView!
    @IBOutlet weak var firstMedicationTimeField: UITextField!
    @IBOutlet weak var commentTextField: UITextField!
    
    let units = [NSLocalizedString("minutes", comment: "minutes") ,
                 NSLocalizedString("hours", comment: "hours")]
    
    var addButtonEventHandler:MedicationEditorAddButtonEventHandler?
    var cancelButtonEventHandler:MedicationEditorCancelButtonEventHandler?
    
    override init(frame:CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init(coder aCoder: NSCoder) {
        super.init(coder: aCoder)!
        setup()
    }
    
    func setup() {
        let view = Bundle.main.loadNibNamed("MedicationEditorView", owner: self, options: nil)?.first as! UIView
        view.frame = self.bounds
        self.addSubview(view)
        
        oftenUnitPicker.delegate = self
        oftenUnitPicker.dataSource = self
    }
    
    ///////////////////////////
    
    public func setAddButtonEventHandler(_ handler:@escaping MedicationEditorAddButtonEventHandler) {
        addButtonEventHandler = handler
    }
    
    public func setCancelButtonEventHandler(_ hadler:@escaping MedicationEditorCancelButtonEventHandler){
        cancelButtonEventHandler = hadler
    }
    
    ///////////////////////////

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return units.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print(units[row])
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return units[row]
    }

    @IBAction func pushedAddButton(_ sender: Any) {
        
        var medicationInfo = MedicationInfo()
        
        if let name = medicationNameField.text{
            medicationInfo.medicationName = name
        }
        
        if let timesPerDay = timesPerDayField.text {
            medicationInfo.timesPerDay = timesPerDay
        }
        
        if let pillsEachTimes = pillsEachTimesField.text {
            medicationInfo.pillsEachTimes = pillsEachTimes
        }
        
        if let oftenNumber = oftenNumberField.text {
            medicationInfo.oftenNumber = oftenNumber
        }
        
        medicationInfo.oftenUnit = units[oftenUnitPicker.selectedRow(inComponent: 0)]
        
        if let firstMedicationTime = firstMedicationTimeField.text {
            medicationInfo.firstMedicationTime = firstMedicationTime
        }
        
        if let comment = commentTextField.text {
            medicationInfo.comment = comment
        }
        
        medicationNameField.resignFirstResponder()
        timesPerDayField.resignFirstResponder()
        pillsEachTimesField.resignFirstResponder()
        oftenNumberField.resignFirstResponder()
        firstMedicationTimeField.resignFirstResponder()
        commentTextField.resignFirstResponder()
        
        // validation
        guard medicationInfo.medicationName != "" else {
            // send notification
            sendAlert()
            return
        }
        
        guard medicationInfo.timesPerDay != "" else {
            sendAlert()
            return
        }

        guard medicationInfo.pillsEachTimes != "" else {
            sendAlert()
            return
        }

        guard medicationInfo.oftenNumber != "" else {
            sendAlert()
            return
        }
        
        guard medicationInfo.oftenUnit != "" else {
            sendAlert()
            return
        }

        guard medicationInfo.firstMedicationTime != "" else {
            sendAlert()
            return
        }

        // send medication info using handler
        if let addHandler = addButtonEventHandler {
            addHandler(medicationInfo)
        }
    }
    
    func sendAlert(){
        SVProgressHUD.setDefaultStyle(SVProgressHUDStyle.dark)
        SVProgressHUD.showInfo(withStatus: NSLocalizedString("consent_fill_entries", comment: "consent_fill_entries"))
        SVProgressHUD.dismiss(withDelay: 2)
    }
    
    @IBAction func pushedCancelButton(_ sender: Any) {
        if let cancelHandler = cancelButtonEventHandler{
            cancelHandler()
        }
    }
    
    public func cleanItems(){
        medicationNameField.text = ""
        timesPerDayField.text    = ""
        pillsEachTimesField.text = ""
        oftenNumberField.text    = ""
        firstMedicationTimeField.text = ""
        commentTextField.text    = ""
    }
}
