//
//  HttpsRequest.swift
//  YYBLEDemo1
//
//  Created by fuhuayou on 2021/4/12.
//

import Foundation
import Alamofire

//#define k

class HttpsRequest : NSObject {
    
    /*
     url: url, https://...
     options: headers, body, needToken, timeout, loading
     */
    static func get(url:String,
                    _ parameters:  [String: Any]?,
                    _ completion: (( _ response:[String : Any] ) -> Void)? ) {
        HttpsRequest.singleton.request("GET", url, parameters: parameters, completion)
    }
    
    static func post(url:String,
                     _ parameters:  [String: Any]?,
                     _ completion: (( _ response:[String : Any] ) -> Void)? ) {
        HttpsRequest.singleton.request("POST", url, parameters: parameters, completion)
    }
    
    // singleton
    static let singleton = HttpsRequest();
    private override init() {}
    
    // async tasks.
    var asyncTasks: [String: Any] = [:];
    
    func request(_ method: String, _ url: String, parameters:[String: Any]?, _ completion: (( _ response:[String : Any] ) -> Void)?) {
        
        let htTask = HttpsTask(url:url, method: method, completion: completion)
        asyncTasks[url] = htTask
        htTask.resume {
            self.asyncTasks.removeValue(forKey: htTask.url!)
        }
        
        var task: DataRequest?
        switch method {
        case "GET":
            task = AF.request(url, method: .get)
        case "POST":
             task = AF.request(url, method: .post, parameters: parameters)
        default:
            break
        }
        
        if let task = task {
            htTask.afTask = task
            print("=========== asyncTasks0000: ", htTask.identifier!)
            htTask.afTask?.responseJSON(completionHandler: { response in
                // success.
                if case let Result.success(data) = response.result {
                    print("=========== success: ", data)
                }
                
                // error.
                if case let Result.failure(data) = response.result {
                    print("=========== failure: ", data)
                }
                
                print("=========== asyncTasks1111: ", htTask.identifier!)
//                htTask.finished(<#T##result: [String : Any]##[String : Any]#>)
                self.asyncTasks.removeValue(forKey: htTask.url!)
               
               
            })
        }

    }
    
}
