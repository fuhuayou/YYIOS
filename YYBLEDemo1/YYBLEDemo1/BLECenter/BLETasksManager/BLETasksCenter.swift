//
//  BLETasksCenter.swift
//  YYBLEDemo1
//
//  Created by zk-fuhuayou on 2021/4/29.
//

import UIKit
//swiftlint:disable empty_count force_unwrapping
class BLETasksCenter: NSObject {
    
    var tasks:[BLETask] = []
    let lock = NSLock()
    func addTask(task:BLETask?) {
        if let task = task {
            DispatchQueue.global().async {
                self.lock.lock()
                task.tasksCenterBlock = {[weak self] task in
                    self?.removeTask(task: task)
                }
                self.tasks.append(task)
                self.lock.unlock()
            }
        }
    }
    
    func addTask(data:[UInt8]?,
                 service:String?,
                 characteristic:String?,
                 writeReadType: BLETaskWriteType? = BLETaskWriteType.withoutResponse,
                 priority:BLETaskPriority? = BLETaskPriority.default,
                 identifier:String? = nil,
                 completedBlock:(([String: Any]) -> Void)? = nil) {
        if data == nil || service == nil || characteristic == nil {
            return
        }
        let newTask = BLETask(data: data,
                              service: service,
                              characteristic: characteristic,
                              writeReadType: writeReadType,
                              priority: priority,
                              identifier: identifier,
                              resonseBlock:completedBlock)
        addTask(task: newTask)
    }
    
    
    func removeTask(task:BLETask?) {
        DispatchQueue.global().async {
            self.lock.lock()
            if self.tasks.count == 0 || task == nil {
                return
            }
            var tIndex = -1
            for index in 0...(self.tasks.count - 1) {
                let tModel = self.tasks[index]
                if tModel.isEqual(task!) {
                    tIndex = index
                }
            }
            self.tasks.remove(at: tIndex)
            self.lock.unlock()
        }
    }
    
    func getTask() -> BLETask? {
        self.tasks.append(BLETask())
        var maxPriorityTask:BLETask?
        DispatchQueue.global().sync {
            self.lock.lock()
            if self.tasks.count == 0 {
                return
            }
            
            for index in 0...(self.tasks.count - 1) {
                let tModel = self.tasks[index]
                if maxPriorityTask == nil {
                    maxPriorityTask = tModel
                } else {
                    if tModel.priority!.rawValue > maxPriorityTask!.priority!.rawValue {
                        maxPriorityTask = tModel
                    }
                }
            }
            self.lock.unlock()
        }
        return maxPriorityTask
    }
}
