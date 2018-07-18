//
//  ConsentDetailsViewController.swift
//  STOP
//
//  Created by Yuuki Nishiyama on 2018/06/20.
//  Copyright © 2018 Yuuki Nishiyama. All rights reserved.
//

import UIKit
import PopupDialog

class ConsentDetailsViewController: UIViewController {

    var resultHandler: ((Bool) -> Void)?
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var declineButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = NSLocalizedString("consent_app_consent", comment: "consent_app_consent")
        declineButton.setTitle(NSLocalizedString("consent_decline", comment: "consent_decline"), for: .normal)
        acceptButton.setTitle(NSLocalizedString("consent_accept", comment: "consent_accept"), for: .normal)
        
        ///// replace "<b></b>" to "Attribute Strong Format" in body text
        let body = NSLocalizedString("consent_app_consent_details", comment:"consent_app_consent_details")
        let attributedBody = NSMutableAttributedString.init(string: body)
        
        // set default font size to all
        attributedBody.addAttributes([ NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16)], range: NSMakeRange(0, attributedBody.length))
        
        /**
         * find a <b></b> and append a strong effect
         */
        var nextRange        = body.startIndex..<body.endIndex
        let targetStartTag   = "<b>"
        let targetEndTag     = "</b>"
        var tagRanges        = Array<NSRange>()
        // find <b> loop
        while let startRange = body.range(of: targetStartTag, options: .caseInsensitive, range: nextRange) {
            nextRange = startRange.upperBound..<body.endIndex
            tagRanges.append(NSMakeRange(startRange.lowerBound.encodedOffset, targetStartTag.count))
            // find <b> loop
            while let endRange = body.range(of: targetEndTag, options: .caseInsensitive, range: nextRange) {
                /**
                 * append strong effect between <b> and </b>
                 * remove <b> and </b> after the loop
                 */
                tagRanges.append(NSMakeRange(endRange.lowerBound.encodedOffset, targetEndTag.count))
                let strongAttributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 18, weight: UIFont.Weight(rawValue: 2) )]
                let length = endRange.upperBound.encodedOffset - startRange.lowerBound.encodedOffset
                attributedBody.addAttributes(strongAttributes, range: NSMakeRange(startRange.lowerBound.encodedOffset, length))
                
                nextRange = endRange.upperBound..<body.endIndex
                break
            }
        }

        // remove tags (<b></b>)
        var previousRemoveLength = 0
        for r in tagRanges {
            /*
             * r.location - previousRemoveLength
             * => change a remove position depend on the previous remove length
             */
            attributedBody.replaceCharacters(in: NSMakeRange(r.location-previousRemoveLength, r.length) , with: "")
            previousRemoveLength += r.length
        }
        
        textView.attributedText = attributedBody
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        // Prepare the popup assets
        let title = NSLocalizedString("consent_welcome_title", comment: "consent_welcome_title")
        let message = NSLocalizedString("consent_welcome", comment: "consent_welcome")
        
        // Create the dialog
        let popup = PopupDialog(title: title, message: message)
        
        // Create buttons
        let cancelButton = DefaultButton(title: NSLocalizedString("consent_welcome_gotit", comment: "consent_welcome_gotit")) {
            print("You canceled the car dialog.")
        }
        
        // Add buttons to dialog
        // Alternatively, you can use popup.addButton(buttonOne)
        // to add a single button
        popup.addButtons([cancelButton])
        
        // Present dialog
        self.present(popup, animated: true, completion: nil)
    }
    
    @IBAction func pushedAcceptButton(_ sender: UIButton) {
        Consent.setConsentRead(state: true)
        if let unwrappedHandler = resultHandler {
            unwrappedHandler(true)
        }
        dismiss(animated: true, completion: {})
    }
    
    @IBAction func pushedDeclineButton(_ sender: UIButton) {
        Consent.setConsentRead(state: true)
        let declineAlert = UIAlertController.init(title:   NSLocalizedString("consent_decline",   comment: "consent_decline"),
                                                  message: NSLocalizedString("consent_declining", comment: "consent_declining"),
                                                  preferredStyle: UIAlertControllerStyle.alert )
        let actionYes = UIAlertAction.init(title: NSLocalizedString("consent_yes", comment: "consent_yes"), style: UIAlertActionStyle.default, handler: { (action) in
            
            if let unwrappedHandler = self.resultHandler {
                unwrappedHandler(false)
            }
            
            // DispatchQueue.main.async {
            self.dismiss(animated: true, completion: {
                // Consent.setConsentRead(state: false)
            })
            
        })
        
        let actionNo  = UIAlertAction.init(title: NSLocalizedString("consent_no", comment: "consent_yes"), style: .cancel, handler: { (action) in
        })
        
        declineAlert.addAction(actionNo)
        declineAlert.addAction(actionYes)
        
        self.present(declineAlert, animated: true, completion: {
            
        })
        
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
