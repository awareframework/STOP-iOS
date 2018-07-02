//
//  WitApiHelper.swift
//  STOP
//
//  Created by Yuuki Nishiyama on 2018/05/09.
//  Copyright © 2018 Yuuki Nishiyama. All rights reserved.
//

import Foundation

class WitApiHelper{
    
    public typealias ServerResponseHandler = (_ date:Date?) -> Void
    
    public var serverResponseHandler:ServerResponseHandler?
    
    public func convertTextToTimestamp(_ text:String){
        
//        String timezone = "&context={\"timezone\":\"" + TimeZone.getDefault().getID() + "\"}";
//        String getUrl = String.format("%s%s", "https://api.wit.ai/message?q=", URLEncoder.encode(text[0], "utf-8")) + timezone;
        let timeZone = "{\"timezone\":\"\(TimeZone.current.identifier)\"}".addingPercentEncoding(withAllowedCharacters:.urlQueryAllowed)!
        let encodedText:String = text.addingPercentEncoding(withAllowedCharacters:.urlQueryAllowed)!
        let url = URL(string: "https://api.wit.ai/message?q=\(encodedText)&context=\(timeZone)")
        let accessToken = "SWGWOH2KRZ6UYTDKWLK5WA65ALIBLC47"
        var request = URLRequest(url: url!)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.allowsCellularAccess = true
        
        var isSuccess = false
        
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if error == nil, let data = data, let response = response as? HTTPURLResponse {
                print("Content-Type: \(response.allHeaderFields["Content-Type"] ?? "")")
                print("statusCode: \(response.statusCode)")
                print(String(data: data, encoding: .utf8) ?? "")
                if response.statusCode == 200 {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                        let top = json as! Dictionary<String, Any>
                        if let entities = top["entities"] {
                            let unwrappedEntities = entities as! Dictionary<String, Any>
                            let datetimes = unwrappedEntities["datetime"]
                            if let unwrappedDatetimes = datetimes as? Array<Any> {
                                if unwrappedDatetimes.count > 0 {
                                    let firstObject = unwrappedDatetimes[0]
                                    if let unwrappedFirstObj = firstObject as? Dictionary<String,Any>{
                                        if let datetimeStr = unwrappedFirstObj["value"] as? String {
                                            print(datetimeStr)
                                            let formatter = DateFormatter()
                                            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSxxx"
                                            let date = formatter.date(from: datetimeStr)
                                            if let unwrappedDate = date {
                                                if let handler = self.serverResponseHandler {
                                                    isSuccess = true
                                                    handler(unwrappedDate)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    } catch {
                        print(error)
                    }
                }
            }
            if !isSuccess {
                if let handler = self.serverResponseHandler {
                    handler(nil)
                }
            }
        }.resume()
    }
}

