//
//  SymptomItemView.swift
//  STOP
//
//  Created by Yuuki Nishiyama on 2018/06/14.
//  Copyright © 2018 Yuuki Nishiyama. All rights reserved.
//

import UIKit

@IBDesignable class SymptomItemView: UIView {

    public typealias ButtonClickEventHandler = (_ state:Bool, _ button:UIButton) -> Void
    
    var buttonClickEventHandler:ButtonClickEventHandler?
    
    @IBOutlet weak var radioButton: UIButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    let checkedImage = UIImage(named: "stop_selected_circle")! as UIImage
    let uncheckedImage = UIImage(named: "stop_unselected_circle")! as UIImage
    
    
    var isSelected = false
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override init(frame:CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init(coder aCoder: NSCoder) {
        super.init(coder: aCoder)!
        setup()
    }
    
    func setup() {
        let view = Bundle.main.loadNibNamed("SymptomItemView", owner: self, options: nil)?.first as! UIView
        view.frame = self.bounds
        self.addSubview(view)
    }

    
    public func setButtonClickEventHandler(_ handler:@escaping ButtonClickEventHandler){
        buttonClickEventHandler = handler;
    }
    
    public func changeButtonStatus(_ state:Bool){
        if state {
            isSelected = true
            radioButton.setImage( checkedImage , for: .normal)
        } else {
            isSelected = false
            radioButton.setImage( uncheckedImage , for: .normal)
        }
    }

    
    @IBAction func pushedRadioButton(_ sender: UIButton) {
        
        if let handler = buttonClickEventHandler {
            handler(!isSelected, sender)
        }
        
        if isSelected {
            isSelected = false
            sender.setImage( uncheckedImage , for: .normal)
        }else{
            isSelected = true
            sender.setImage( checkedImage , for: .normal)
        }
    }
    
}
