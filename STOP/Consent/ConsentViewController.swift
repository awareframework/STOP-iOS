//
//  ConsentViewController.swift
//  STOP
//
//  Created by Yuuki Nishiyama on 2018/06/11.
//  Copyright © 2018 Yuuki Nishiyama. All rights reserved.
//

import UIKit
import SVProgressHUD

class ConsentViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

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
    @IBOutlet weak var medicationsTextView: UITextView!
    
    // Symptoms
    
    @IBOutlet weak var symptomsLabelView: UIStackView!
    @IBOutlet weak var symptomsLabel: UILabel!
    @IBOutlet weak var symptomsStackView: UIStackView!
    var symptomViews = Array<SymptomContentView>()
    let symptomIds = ["5","6","7","8","9","10","11","12","13","14","15","16","17"]

    
    // Submit button
    @IBOutlet weak var submitButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        pdDateUnitPicker.delegate = self
        pdDateUnitPicker.dataSource = self
        
        // set unit of date
        dataUnits = ["months ago", "years ago"]
    
        // set symptom items
        for symptomId in symptomIds {
            let symptomView = SymptomContentView(frame:CGRect.init(x: 0, y: 0, width: self.view.bounds.width, height: 0))
            
            symptomView.title?.text = NSLocalizedString("symptom_"+symptomId+"_0", comment: "title of " + symptomId)
            for itemNum in ["1","2","3","4","5"] {
                symptomView.addItem(description: NSLocalizedString("symptom_"+symptomId+"_"+itemNum, comment: "content-"+itemNum+" of "+symptomId))
            }
            symptomsStackView.addArrangedSubview(symptomView)
            symptomViews.append(symptomView)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {

        if !Consent.isConsentRead() {
            performSegue(withIdentifier: "consentDetailsView",sender: nil)
//            let storyboard: UIStoryboard = self.storyboard!
//            let nextView = storyboard.instantiateViewController(withIdentifier: "consentDetailsView")
//            
//            present(nextView, animated: true, completion: nil)
            
        }
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func changedPDState(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0{
            hideContents(false)
        } else {
            hideContents(true)
        }
    }
    
    func hideContents(_ state:Bool){
        nickNameView.isHidden = state
        ageView.isHidden = state
        pdLabelView.isHidden = state
        pdInputView.isHidden = state
        medicationLabelView.isHidden = state
        medicationsTextView.isHidden = state
        symptomsLabelView.isHidden = state
        symptomsStackView.isHidden = state
    }
    
    
    @IBAction func pushedSubmitButton(_ sender: Any) {

        if checkAllItemsState() {
            Consent.setContantAnswer(state: true)
            self.dismiss(animated: true, completion: {
                SVProgressHUD.showSuccess(withStatus: NSLocalizedString("consent_loading", comment: "consent_loading"))
                SVProgressHUD.setDefaultStyle(SVProgressHUDStyle.dark)
                SVProgressHUD.dismiss(withDelay: 3)
            })
        } else{
            SVProgressHUD.showError(withStatus: NSLocalizedString("consent_empty_entries", comment: "consent_empty_entries"))
            SVProgressHUD.setDefaultStyle(SVProgressHUDStyle.dark)
            SVProgressHUD.dismiss(withDelay: 3)
        }
        
    }
    
    func checkAllItemsState()->Bool{
        guard nicknameTextFiled.text?.count > 0 else {
            return false
        }
        
        guard ageTextField.text?.count > 0 else {
            return false;
        }
        
        guard pdDateTextField.text?.count > 0 else {
            return false;
        }
        
        guard medicationsTextView.text?.count > 0 else{
            return false;
        }
        
        for symptomView in symptomViews {
            guard symptomView.isSelected() else {
                return false
            }
        }
        
        return true
    }
    
    /////////////////////
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return (dataUnits?.count)!
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return dataUnits?[component]
    }

}
