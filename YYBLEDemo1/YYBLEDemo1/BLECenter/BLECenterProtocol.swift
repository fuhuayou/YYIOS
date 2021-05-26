//
//  BLECenterProtocol.swift
//  YYBLEDemo1
//
//  Created by zk-fuhuayou on 2021/5/8.
//

import Foundation
import CoreBluetooth
//swiftlint:disable attributes
@objc enum BLEConnState : Int {
    case searching = -1
    case disconnected = 0
    case connecting = 1
    case connected = 2
    case disconnecting = 3
}

//swiftlint:disable attributes
@objc protocol BLECenterStateProtocol {
    
    //power state.
    @objc optional func onPowerStateDidUpdate(state: CBManagerState)
    
    //scan state.
    @objc optional func onScanStateDidUpdate(isScan: Bool)
    
    //connect state
    @objc optional func onConnectStateDidUpdate(state: BLEConnState)
}
