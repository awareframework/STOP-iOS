//
//  ConsentViewController.swift
//  STOP
//
//  Created by Yuuki Nishiyama on 2018/06/11.
//  Copyright © 2018 Yuuki Nishiyama. All rights reserved.
//

import UIKit

class ConsentViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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

    
    @IBAction func pushedSubmitButton(_ sender: Any) {
        ConsentViewController.setAnswer(state: true)
        self.dismiss(animated: true, completion: {
            
        })
    }
    
    //////////////////////////////////////////////////
    public static func isAnswered() -> Bool{
//        let state = UserDefaults.standard.bool(forKey: "stop.consent.state")
//        return state
        return false
    }
    
    public static func setAnswer(state:Bool){
        UserDefaults.standard.set(state, forKey: "stop.consent.state")
    }

}
