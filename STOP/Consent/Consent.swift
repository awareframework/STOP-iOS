//
//  Consent.swift
//  STOP
//
//  Created by Yuuki Nishiyama on 2018/06/15.
//  Copyright © 2018 Yuuki Nishiyama. All rights reserved.
//

import UIKit
import AWAREFramework

class Consent: AWARESensor {
    
    override init() {
        let storage = JSONStorage.init(study: AWAREStudy.shared(), sensorName: "consent")
        super.init(awareStudy:AWAREStudy.shared(), sensorName: "consent", storage: storage)
    }
    
    public func saveUserAnswer(_ answer:String){
        let dict:Dictionary <String,Any> = ["device_id":AWAREStudy.shared().getDeviceId(),
                                            "timestamp":AWAREUtils.getUnixTimestamp(Date.init()),
                                            "user_data":answer]
        self.storage.saveData(with: dict, buffer: false, saveInMainThread: true)
    }
    
    //////////////////////////////////////////////////
    public static func isConsentAnswered() -> Bool{
        let state = UserDefaults.standard.bool(forKey: "stop.consent.answer.state")
        return state
//        return false
    }
    
    public static func setContantAnswer(state:Bool){
        UserDefaults.standard.set(state, forKey: "stop.consent.answer.state")
        UserDefaults.standard.synchronize()
    }
    
    
    public static func isConsentRead() -> Bool {
        let state = UserDefaults.standard.bool(forKey: "stop.consent.read.state")
        return state
//        return false
    }
    
    public static func setContentRead(state:Bool) {
        UserDefaults.standard.set(state, forKey: "stop.consent.read.state")
        UserDefaults.standard.synchronize()
    }
    
}
