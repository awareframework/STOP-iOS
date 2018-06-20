//
//  ConsentDetailsViewController.swift
//  STOP
//
//  Created by Yuuki Nishiyama on 2018/06/20.
//  Copyright © 2018 Yuuki Nishiyama. All rights reserved.
//

import UIKit

class ConsentDetailsViewController: UIViewController {

    var resultHandler: ((Bool) -> Void)?
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var declineButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = NSLocalizedString("consent_app_consent", comment: "consent_app_consent")
        textView.text = NSLocalizedString("consent_app_consent_details", comment:"consent_app_consent_details")
        declineButton.setTitle(NSLocalizedString("consent_decline", comment: "consent_decline"), for: .normal)
        acceptButton.setTitle(NSLocalizedString("consent_accept", comment: "consent_accept"), for: .normal) 
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func pushedAcceptButton(_ sender: UIButton) {
        Consent.setContentRead(state: true)
        if let unwrappedHandler = resultHandler {
            unwrappedHandler(true)
        }
        dismiss(animated: true, completion: {})
    }
    
    
    @IBAction func pushedDeclineButton(_ sender: UIButton) {
        Consent.setContentRead(state: true)
        if let unwrappedHandler = resultHandler {
            unwrappedHandler(false)
        }
        dismiss(animated: true, completion: {})
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
