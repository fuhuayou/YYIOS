//
//  BLECenterProtocol.swift
//  YYBLEDemo1
//
//  Created by zk-fuhuayou on 2021/5/8.
//

import Foundation
import CoreBluetooth
//swiftlint:disable attributes
@objc protocol BLECenterStateProtocol {
    
    //power state.
    @objc optional func onPowerStateDidUpdate(state: CBManagerState)
    
    //scan state.
    @objc optional func onScanStateDidUpdate(isScan: Bool)
    
    //connect state
    @objc optional func onConnectStateDidUpdate(state: CBPeripheralState)
}
