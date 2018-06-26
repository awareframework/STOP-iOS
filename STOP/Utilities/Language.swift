//
//  Language.swift
//  STOP
//
//  Created by Yuuki Nishiyama on 2018/06/20.
//  Copyright © 2018 Yuuki Nishiyama. All rights reserved.
//

import UIKit

class Language {
    
    fileprivate func get() -> String {
        let languages = NSLocale.preferredLanguages
        if let type = languages.first {
            return type
        }
        return ""
    }
    

    func isJapanese() -> Bool {
        return self.get().contains("ja") ? true : false
    }
    

    func isEnglish() -> Bool {
        return self.get().contains("en") ? true : false
    }
    
}
