//
//  HealthActivityViewController.swift
//  STOP
//
//  Created by Yuuki Nishiyama on 2018/06/29.
//  Copyright © 2018 Yuuki Nishiyama. All rights reserved.
//

import UIKit
import SVProgressHUD
import AWAREFramework

class HealthActivityViewController: UIViewController {
    
    var health:HealthActivity?
    
    @IBOutlet weak var radioButtonZero:  UIButton!
    @IBOutlet weak var radioButtonOne:   UIButton!
    @IBOutlet weak var radioButtonTwo:   UIButton!
    @IBOutlet weak var radioButtonThree: UIButton!
    @IBOutlet weak var radioButtonFour:  UIButton!
    
    var selectedRadioButton:Int = -1;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.health = HealthActivity.init(awareStudy: AWAREStudy.shared(), dbType: AwareDBTypeSQLite)
        self.health?.createTable()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func pushedRadioButton(_ sender: UIButton) {
        let unselectedImg = UIImage.init(named: "stop_unselected_circle")
        let selectedImg = UIImage.init(named: "stop_selected_circle")
        radioButtonZero.setImage(unselectedImg, for: .normal)
        radioButtonOne.setImage(unselectedImg, for: .normal)
        radioButtonTwo.setImage(unselectedImg, for: .normal)
        radioButtonThree.setImage(unselectedImg, for: .normal)
        radioButtonFour.setImage(unselectedImg, for: .normal)
        
        sender.setImage(selectedImg, for: .normal)
        selectedRadioButton = sender.tag
    }
    
    @IBAction func pushedSubmitButton(_ sender: UIButton) {
        print(selectedRadioButton)
        if selectedRadioButton != -1 {
            health?.saveValue("\(selectedRadioButton)")
            health?.storage.setDebug(true)
            health?.storage.startSyncStorage(callBack: { (name, progress, error) in
                let message = NSLocalizedString("health_survey_saved", comment: "health_survey_saved")
                SVProgressHUD.showSuccess(withStatus: message)
                SVProgressHUD.setDefaultStyle(SVProgressHUDStyle.dark)
                SVProgressHUD.dismiss(withDelay: 3)
                self.navigationController?.popViewController(animated: true)
            })
        }else{
            let message = NSLocalizedString("health_empty_response", comment: "health_empty_response")
            SVProgressHUD.showError(withStatus: message)
            SVProgressHUD.setDefaultStyle(SVProgressHUDStyle.dark)
            SVProgressHUD.dismiss(withDelay: 3)
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
