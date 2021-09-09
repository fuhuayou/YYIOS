//
//  GCD.swift
//  YYSwiftLearning
//
//  Created by zk-fuhuayou on 2021/9/8.
//

import UIKit

class GCD: NSObject {
    
    func testing() {
        
        //DispatchQueue, 和 DispatchGroup的使用。
        DispatchQueue.global().async {
            let group = DispatchGroup()
            let queue0 = DispatchQueue(label:"queue0", attributes: .concurrent)
            queue0.async(group: group) {
                Thread.sleep(forTimeInterval: 1.0)
                print("=====async queue0, \(Date().description)")
            }
            
            let queue1 = DispatchQueue(label:"queue1", attributes: .concurrent)
            queue1.async(group: group) {
                Thread.sleep(forTimeInterval: 2.0)
                print("=====async queue1, \(Date().description)")
            }
            
            let queue2 = DispatchQueue(label:"queue2", attributes: .concurrent)
            queue2.async(group: group) {
                print("=====async queue2, \(Date().description)")
                Thread.sleep(forTimeInterval: 14.0)
            }
            
            print("=====async wait, \(Date().description)")
            group.wait()
            print("=====async wait done., \(Date().description)")
        }
    }
}
