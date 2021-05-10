//
//  BLETask.swift
//  YYBLEDemo1
//
//  Created by zk-fuhuayou on 2021/4/29.
//
//swiftlint:disable empty_count
import Foundation
enum BLETaskPriority:Int {
    case low = 0
    case `default` = 1
    case height = 2
    case emergency = 3
}

enum BLETaskWriteType:Int {
    case withResponse = 0
    case withoutResponse = 1
}

enum BLETaskCompletedState:Int {
    case fail = 0
    case success = 1
    case timeout = 2
}

enum BLETaskType:Int {
    case normal = 0
    case disconnect = 1
    case ota = 2
    case connectWithDevice = 3
    case connectWithServerUUID = 4
    case connectFromConnectedList = 5
    case reconnect = 6
}


class BLETask: NSObject {
    
    var taskType:BLETaskType = .normal
    
    var identifier: String?
    var priority: BLETaskPriority = .default
    var cmdData: Data?
    var service: String?
    var characteristic: String?
    var writeReadType: BLETaskWriteType = .withoutResponse
    var timeout:Float = 5.0
    var resonseBlock: BLECALLBACK?
    var tasksCenterBlock: ((BLETask) -> Void)?
    //timer
    var timer: ZKTimer?
    var isTimeout = false
    
    //write with response.
    var resonseServerUUID: String?
    var resonseCharacteristic: String?
    var resonseData: Data?
    
    //task type: async or sync.
    var isAsync = false
    
    //system levels use
    var parameters: [String:Any]?
    
    init(type:BLETaskType = .normal,
         priority:BLETaskPriority = .height,
         timeout:Float = 5.0,
         parameters:[String:Any]? = nil,
         resonseBlock: (([String: Any]) -> Void)? = nil) {
        self.taskType = type
        self.timeout = timeout
        self.parameters = parameters
        self.resonseBlock = resonseBlock
    }
    
    init(data:Any? = nil,
         service:String? = nil,
         characteristic:String? = nil,
         writeReadType: BLETaskWriteType = .withoutResponse,
         resonseService: String? = nil,
         resonseCharacteristic: String? = nil,
         timeout:Float = 5.0,
         priority:BLETaskPriority = .default,
         isAsync:Bool = false,
         identifier:String? = nil,
         resonseBlock: (([String: Any]) -> Void)? = nil) {
        self.identifier = identifier
        self.isAsync = isAsync
        self.priority = priority
        let isData = data is Data
        if isData {
            self.cmdData = data as? Data
        } else {
            let iBytes:[UInt8] = data as? [UInt8] ?? []
            if iBytes.count > 0 {
                self.cmdData = Data(bytes: iBytes, count: iBytes.count)
            }
        }
        self.service = service
        self.characteristic = characteristic
        self.writeReadType = writeReadType
        if self.writeReadType == .withResponse {
            self.resonseServerUUID = resonseService == nil ? service : resonseService
            self.resonseCharacteristic = resonseCharacteristic == nil ? characteristic : resonseCharacteristic
        }
        self.timeout = timeout
        self.resonseBlock = resonseBlock
    }
    
    func execute() {
        self.timer = ZKTimer(interval:Double(self.timeout), repeats: false) {[weak self] _ in
            self?.isTimeout = true
            self?.taskCompleted(response: ["state":BLETaskCompletedState.timeout, "message":"timeout"])
        }
    }
    
    func taskCompleted(response:[String: Any]? = nil) {
        //invaliate timer.
        self.timer?.invalidate()
        self.timer = nil
        
        //remove from tasks center.
        if let tasksCenterBlock = self.tasksCenterBlock {
            tasksCenterBlock(self)
            self.tasksCenterBlock = nil
        }
        
        //callback.
        if response != nil {
            if let block = self.resonseBlock {
                block(response!)
                self.resonseBlock = nil
            }
        }
        self.resonseBlock = nil
    }
}
