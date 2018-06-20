//
//  SymptomContentView.swift
//  STOP
//
//  Created by Yuuki Nishiyama on 2018/06/13.
//  Copyright © 2018 Yuuki Nishiyama. All rights reserved.
//

import UIKit

@IBDesignable class SymptomContentView: UIView {

    @IBOutlet weak var baseStackView: UIStackView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var mainStackView: UIStackView!
    @IBOutlet weak var splitView: UIView!
    
    var items = Array<SymptomItemView>()
    
    override init(frame:CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init(coder aCoder: NSCoder) {
        super.init(coder: aCoder)!
        setup()
    }
    
    func setup() {
        let view = Bundle.main.loadNibNamed("SymptomContentView", owner: self, options: nil)?.first as! UIView
        view.frame = self.bounds
        self.addSubview(view)
    }
    
    public func addItem(description:String){
        
        let eventHandler:SymptomItemView.ButtonClickEventHandler = { (_ state:Bool, _ button:UIButton) -> Void in
            for i in self.items {
                i.changeButtonStatus(false)
            }
        }
        
        let item = SymptomItemView( frame: CGRect.init(x: 0, y: 0, width: self.frame.width, height: 0) )
        item.setButtonClickEventHandler(eventHandler)
        item.descriptionLabel?.text = description
        
        mainStackView.addArrangedSubview(item)
        self.items.append(item)
    }
    
    public func getSelectedItemNumber() -> Int {
        for (index, item) in self.items.enumerated() {
            if item.isSelected{
                return index
            }
        }
        return -1
    }
    
    public func isSelected() -> Bool{
        if getSelectedItemNumber() == -1 {
            return false
        }else{
            return true
        }
    }
}
