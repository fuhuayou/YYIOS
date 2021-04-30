//
//  BLETask.swift
//  YYBLEDemo1
//
//  Created by zk-fuhuayou on 2021/4/29.
//

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

class BLETask: NSObject {
    var identifier: String?
    var priority: BLETaskPriority? = BLETaskPriority.default
    var cmdData: [UInt8]?
    var service: String?
    var characteristic: String?
    var writeReadType: BLETaskWriteType? = BLETaskWriteType.withoutResponse
    var timeout:Float? =  5.0
    var resonseBlock: (([String: Any]) -> Void)?
    var tasksCenterBlock: ((BLETask) -> Void)?
    //timer
    var timer: ZKTimer?
    init(data:[UInt8]? = nil,
         service:String? = nil,
         characteristic:String? = nil,
         writeReadType: BLETaskWriteType? = BLETaskWriteType.withoutResponse,
         timeout:Float? = 5.0,
         priority:BLETaskPriority? = BLETaskPriority.default,
         identifier:String? = nil,
         resonseBlock: (([String: Any]) -> Void)? = nil) {
        self.identifier = identifier
        self.priority = priority
        self.cmdData = data
        self.service = service
        self.characteristic = characteristic
        self.writeReadType = writeReadType
        self.timeout = timeout
        self.resonseBlock = resonseBlock
    }
    
    func execute() {
        self.timer = ZKTimer(interval:Double(self.timeout!), repeats: false) {[weak self] _ in
            self?.taskCompleted(response: ["state":BLETaskCompletedState.timeout, "message":"timeout"])
        }
    }
    
    func taskCompleted(response:[String: Any]) {
        //invaliate timer.
        self.timer?.invalidate()
        self.timer = nil
        
        //remove from tasks center.
        if let tasksCenterBlock = self.tasksCenterBlock {
            tasksCenterBlock(self)
        }
        
        //callback.
        if let block = self.resonseBlock {
            block(response)
        }
    }
}
