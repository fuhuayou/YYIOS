//
//  HttpsTask.swift
//  YYBLEDemo1
//
//  Created by fuhuayou on 2021/4/14.
//

import UIKit
import Alamofire
class HttpsTask: NSObject {
    
    init(url:String,
         method:String = "GET",
         timeout:Int = 60,
         priority:Int = 0,
         identifier:String = Date.milliseconds(),
         completion: (( _ response:[String : Any] ) -> Void)? ) {
        self.url = url
        self.method = method
        self.timeout = timeout
        self.priority = priority
        self.identifier = identifier
        self.completion = completion
    }
    
    var url: String? //url.
    var method: String?
    var timeout: Int? = 60 // timeout.
    var afTask: DataRequest? // task.
    var priority: Int? = 0 // priority default: 0,
    var identifier: String? // default: timestamp milliseconds
    var completion: (([String: Any]) -> Void)?
    private var timer: ZKTimer?
    
    func finished(_ result: [String: Any]) {
        timer?.invalidate()
        if let completion = self.completion {
            completion(result)
            self.completion = nil
        }
    }
    
    func resume(responseBlock:(() -> Void)?) {
        timer = ZKTimer(interval: Double(self.timeout ?? 60),
                        repeats: false) { [weak self] timer in
            if let afTask = self?.afTask {
                afTask.cancel()
                self?.afTask = nil
            }
            
            if let completion = self?.completion {
                completion(["success":false, "code": 10000, "body": ["message": "timeout"]])
                self?.completion = nil;
            }
            
            if let responseBlock = responseBlock {
                responseBlock()
            }
        }
    }
    
    deinit {
        print("==============")
    }
}

extension Date {
    
    // milliseconds string.
    static func milliseconds() -> String {
        let timeInterval: TimeInterval = Date().timeIntervalSince1970
        let millisecond = CLongLong(round(timeInterval*1000))
        return "\(millisecond)"
    }
    
}
