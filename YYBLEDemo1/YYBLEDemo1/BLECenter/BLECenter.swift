//
//  BLECenter.swift
//  YYBLEDemo
//
//  Created by fuhuayou on 2021/3/16.
//

import UIKit
import CoreBluetooth
//swiftlint:disable force_unwrapping empty_count force_cast control_statement attributes file_length type_body_length
class BLECenter: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate, BLETasksCenterProtocol {
    
    //delegate.
    var delegates:MulticastDelegate<BLECenterStateProtocol> = MulticastDelegate()
    
    // type
    typealias TaskCallback = BLECALLBACK
    
    let BLEQUEUE = "BLEQUEUE"
    let BLEIDENTIFIER = "BLEIDENTIFIER"
    var filter: String?
    var bleCenter: CBCentralManager
    //scan
    var scanDevices: [BLEDevice]?
    var centralStateSemaphore: DispatchSemaphore?
    var scanDevicesCallback:((_ devices:[BLEDevice]?) -> Void)?
    var searchDeviceCallback:((BLEDevice) -> Void)?
    
    //connect
    var connectedDevice: BLEDevice?
    var connectingDevice: BLEDevice?
    var connectCallback : TaskCallback?
    
    //connected services
    var connServices: [String: [CBCharacteristic]]?//"service: [特征值数组]"
    
    //restored
    var restoreSemaphore:  DispatchSemaphore?
    
    //task center.
    var tasksCenterMgr = BLETasksCenter()
    override init() {
        self.bleCenter = CBCentralManager()
        super.init()
        self.initBLE()
        print("=========BLECenter FINISED INIT==============")
    }
    
    /*
     init the ble center.
     */
    func initBLE() {
        self.centralStateSemaphore = DispatchSemaphore(value: 0)
        self.bleCenter = CBCentralManager(
            delegate: self as CBCentralManagerDelegate,
            queue: DispatchQueue(label: "BLEQUEUE"),
            options:[CBCentralManagerOptionShowPowerAlertKey: 0,
                     CBCentralManagerOptionRestoreIdentifierKey: BLEIDENTIFIER])
        tasksCenterMgr.delegate = self
        print("========= BLECenter BEGAIN TO INIT CENTRAL ==========")
    }
    
    /**
     Scan devices.
     */
    func scan(_ isEnable: Bool,
              _ filter: String? = nil,
              _ durarion: Int? = 10,
              _ retrieveServers: [String]? = nil,
              _ scanCallback:((_ devices:[BLEDevice]?) -> Void)? = nil) {
        scanDevicesCallback = scanCallback
        DispatchQueue.global().async {
            if self.bleCenter.state != .poweredOn {
                if let centralStateSemaphore = self.centralStateSemaphore {
                    centralStateSemaphore.wait()
                    self.centralStateSemaphore = nil
                }
            }
            
            if isEnable {
                self.filter = filter
                self.scanDevices = []
                if self.bleCenter.isScanning {
                    self.bleCenter.stopScan()
                }
                
                self.bleCenter.scanForPeripherals(withServices:nil, options: nil)
                self.delegates.do { $0.onScanStateDidUpdate?(isScan: true) }
                
                let services = self.changeToUUIDD(servers: retrieveServers)
                if let services = services {
                    let devices = self.bleCenter.retrieveConnectedPeripherals(withServices:services)
                    print("========= retrieveConnectedPeripherals: ", devices)
                    for peripheral in devices {
                        self.centralManager(self.bleCenter, didDiscover: peripheral, advertisementData:[:], rssi:NSNumber(0))
                    }
                }
                
                print("========= BLECenter DID SCAN ==============")
            } else {
                self.bleCenter.stopScan()
                self.delegates.do { $0.onScanStateDidUpdate?(isScan: false) }
                print("========= BLECenter DID STOP SCAN ==============")
            }
        }
    }
    
    func searchDevice(enable: Bool = true,
                      uuid: String? = nil,
                      name: String? = nil,
                      retrieveServers: [String]? = nil,
                      duration:Int = 20,
                      callback:BLECALLBACK?) {
        var iCallback = callback
        guard (uuid != nil || name != nil) else {
            iCallback?([BLEConstants.STATE: BLETaskCompletedState.fail, BLEConstants.MESSAGE: "uuid and name should not be all nil."])
            iCallback = nil
            return;
        }
        let timer = ZKTimer(interval: Double(duration), repeats: false) { timer in
            timer?.invalidate()
            iCallback?([BLEConstants.STATE: BLETaskCompletedState.timeout, BLEConstants.MESSAGE: "Timeout."])
            iCallback = nil
            self.scan(false)
        }
        let isUUID = uuid != nil ? true : false
        
        self.searchDeviceCallback = {device in
            if isUUID && device.blePeripheral!.identifier.uuidString == uuid {
                iCallback?([BLEConstants.STATE: BLETaskCompletedState.success, BLEConstants.MESSAGE: "success.", BLEConstants.VALUE: device])
                iCallback = nil
                timer.invalidate()
                self.scan(false)
                self.searchDeviceCallback = nil
            } else if (!isUUID && device.blePeripheral!.name == name) {
                iCallback?([BLEConstants.STATE: BLETaskCompletedState.success, BLEConstants.MESSAGE: "success.", BLEConstants.VALUE: device])
                iCallback = nil
                timer.invalidate()
                self.scan(false)
                self.searchDeviceCallback = nil
            }
        }
        self.scan(enable, nil, 20, retrieveServers, nil)
    }
    
    /**
     connect device.
     */
    func iConnectDevice(device: BLEDevice, callback: TaskCallback? = nil) {
        //stop scan.
        self.scan(false)
        connectCallback = callback
        if device.blePeripheral == nil {
            connectCallback?([BLEConstants.STATE : BLETaskCompletedState.fail,
                              BLEConstants.MESSAGE : "device nil"])
            return
        }
        self.connectedDevice = device
        self.delegates.do { $0.onConnectStateDidUpdate?(state: .connecting)}
        self.bleCenter.connect((device.blePeripheral)!, options: nil)
    }
    
    /**
     connect device from the system's connected devices.
     */
    func iRetrieveConnect(serviceUUID:String?, callback: TaskCallback? = nil) {
        //stop scan.
        guard serviceUUID != nil else {
            callback?([BLEConstants.STATE : BLETaskCompletedState.fail,
                              BLEConstants.MESSAGE : "service uuid could not be nil."])
            return
        }
        let uuids = changeToUUIDD(servers: [serviceUUID!])
        let devices = self.bleCenter.retrieveConnectedPeripherals(withServices: uuids!)
        guard devices.count > 0 else {
            callback?([BLEConstants.STATE : BLETaskCompletedState.fail,
                              BLEConstants.MESSAGE : "Could not find device."])
            return
        }
        let device = devices[0]
        let bleDeivce = BLEDevice(device.name, device.identifier.uuidString, device)
        self.iConnectDevice(device: bleDeivce, callback: callback)
    }
    
    func iReconnect(callback: BLECALLBACK? = nil) {
        let deviceInfo = (UserDefaults.standard.value(forKey: BLEConstants.BLE_LAST_CONNECTED) as? [String:Any]) ?? nil
        guard deviceInfo != nil else {
            callback?([BLEConstants.STATE: BLETaskCompletedState.fail, BLEConstants.MESSAGE: "No last connected device found"])
            return
        }
        
        self.searchDevice(enable:true,
                          uuid:deviceInfo![BLEConstants.BLE_DEVICE_UUID] as? String,
                          retrieveServers: deviceInfo![BLEConstants.SERVICE_UUIDS] as? [String],
                          duration:20) { response in
            let state:BLETaskCompletedState = response[BLEConstants.STATE] as! BLETaskCompletedState
            if state == .success {
                let device:BLEDevice = response[BLEConstants.VALUE] as! BLEDevice
                self.iConnectDevice(device: device, callback: callback)
            } else {
                callback?(response)
            }
        }
    }
    
    /**
     disconnect device
     */
    func disconnectDevice(callback: ((Bool) -> Void)?) {
        
        if self.connectedDevice != nil && self.connectedDevice!.blePeripheral != nil {
            self.delegates.do {$0.onConnectStateDidUpdate?(state: .disconnecting)}
            bleCenter.cancelPeripheralConnection(self.connectedDevice!.blePeripheral!)
        }
        
        if let callback = callback {
            callback(true)
        }
    }
    
    /**
     send data.
     */
    func iSendData(data: Data?,
                   service: String,
                   characteristic: String,
                   type: BLETaskWriteType = .withoutResponse,
                   callback: (([String : Any]) -> Void)?) {
        
        //get characteristic
        let characteristics = connServices?[service]
        if characteristics == nil || characteristics!.count == 0 {
            if let callback = callback {
                callback(["state": BLETaskCompletedState.fail, "message": "Could not find characteristics."])
            }
            return
        }
        var tCha:CBCharacteristic?
        for cha in characteristics! where cha.uuid.uuidString == characteristic {
            tCha = cha
        }
        if tCha == nil {
            if let callback = callback {
                callback(["state": BLETaskCompletedState.fail, "message": "Could not find command characteristic."])
            }
            return
        }
        
        //check data.
        if data == nil || data!.count == 0 {
            if let callback = callback {
                callback(["state": BLETaskCompletedState.fail, "message": "Data nil."])
            }
            return
        }
        self.connectedDevice?.blePeripheral?.writeValue(data!, for: tCha!, type: changeReadWriteType(type: type))
        if let callback = callback {
            callback(["state": BLETaskCompletedState.success, "message": "success."])
        }
    }
    
    /**
     ================ Delegate methods. ================
     */
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if (peripheral.name != nil && ((self.filter == nil) || peripheral.name!.lowercased().contains(self.filter!))) {
            
            if self.scanDevices == nil {
                self.scanDevices = Array()
            }
            
            var exist = false
            for per in self.scanDevices! where per.blePeripheral?.identifier.uuidString == peripheral.identifier.uuidString {
                exist = true
            }
            
            if !exist {
                print("================" + peripheral.name!)
                let aDev = BLEDevice(peripheral.name, peripheral.identifier.uuidString, peripheral)
                self.scanDevices?.append(aDev)
                scanDevicesCallback?(scanDevices!)
                self.searchDeviceCallback?(aDev)
            }
        }
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("============ centralManagerDidUpdateState: ", central.state)
        self.delegates.do { $0.onPowerStateDidUpdate?(state: central.state)}
        if central.state == .poweredOn {
            if let centralStateSemaphore = self.centralStateSemaphore {
                centralStateSemaphore.signal()
            }
            
            if let restoreSemaphore = self.restoreSemaphore {
                restoreSemaphore.signal()
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.delegate = self
        peripheral.discoverServices(nil)
        connectCallback?([BLEConstants.STATE : BLETaskCompletedState.success,
                          BLEConstants.MESSAGE : "didConnect",
                          BLEConstants.VALUE : self.connectedDevice!])
        delegates.do {$0.onConnectStateDidUpdate?(state: .connected)}
        UserDefaults.standard.set([BLEConstants.BLE_DEVICE_UUID: peripheral.identifier.uuidString,
                                   BLEConstants.BLE_DEVICE_NAME:(peripheral.name ?? ""),
                                   BLEConstants.SERVICE_UUIDS: peripheral.services != nil ? peripheral.services!.map {service in return service.uuid.uuidString} : []],
                                  forKey: BLEConstants.BLE_LAST_CONNECTED)
        print("============ didConnect peripheral: ", peripheral)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        connServices = [:]
        delegates.do {$0.onConnectStateDidUpdate?(state: .disconnected)}
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        connectCallback?([BLEConstants.STATE : BLETaskCompletedState.fail,
                          BLEConstants.MESSAGE : "didFailToConnect"])
        delegates.do {$0.onConnectStateDidUpdate?(state: .disconnected)}
    }
    
    //Ble wake up by the IOS system.
    func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
        print("============ willRestoreState: ", dict)
        if dict[CBCentralManagerRestoredStatePeripheralsKey] == nil {
            return
        }
        let deviceLsit:[CBPeripheral] = dict[CBCentralManagerRestoredStatePeripheralsKey] as! [CBPeripheral]
        if deviceLsit.count > 0 {
            let peripheral = deviceLsit[0]
            let aDev = BLEDevice(peripheral.name, peripheral.identifier.uuidString, peripheral)
            if central.state == .poweredOn {
                self.connectDevice(device: aDev, callback: nil)
            } else {
                DispatchQueue.global().async {
                    self.restoreSemaphore = DispatchSemaphore(value: 0)
                    self.restoreSemaphore!.wait()
                    self.connectDevice(device: aDev)
                    self.restoreSemaphore = nil
                }
            }
        }
    }
    
    // CBPeripheralDelegate methods.
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        // 特征值为空，则返回
        if service.characteristics == nil {
            return
        }
        
        print("========= service: ", service.uuid.uuidString)
        connServices?[service.uuid.uuidString] = service.characteristics
        for characteristic in  service.characteristics! {
            print("=========  ------characteristic: ", characteristic.uuid.uuidString)
        }
        // 全部打开。
        for characteristic in service.characteristics! {
            peripheral.setNotifyValue(true, for: characteristic)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if peripheral.services == nil {
            return
        }
        
        if connServices == nil {
            connServices = Dictionary()
        }
        print("=========services: ", peripheral.services!)
        for service in peripheral.services! {
            connServices?[service.uuid.uuidString] = [CBCharacteristic]()
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        print("=========== didWriteValueFor ======== : ")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        self.tasksCenterMgr.didReceiveDataFrom(characteristic: characteristic, error: error)
        print("=========== didUpdateValueFor ======== : ", characteristic.service.uuid.uuidString, characteristic.uuid.uuidString, characteristic.value ?? "nil")
    }
    
    func peripheralIsReady(toSendWriteWithoutResponse peripheral: CBPeripheral) {
    }
}


extension BLECenter {
    
    func changeToUUIDD(servers: [String]?) -> [CBUUID]? {
        if servers == nil || servers!.count == 0 {
            return nil
        }
        return servers?.map({ val in
            return CBUUID(string: val)
        })
    }
    
    func changeReadWriteType(type:BLETaskWriteType) -> CBCharacteristicWriteType {
        var ttType: CBCharacteristicWriteType
        switch type {
        case .withResponse:
            ttType = .withoutResponse
        default:
            ttType = .withoutResponse
        }
        return ttType
    }
}

extension BLECenter {
    
    func connectDevice(device: BLEDevice, callback:TaskCallback? = nil) {
        self.tasksCenterMgr.executeSystemSyncTask(type: .connectWithDevice,
                                                  priority: .height,
                                                  parameters: [BLEConstants.DEVICE : device],
                                                  completedBlock: callback)
    }
    
    func connectFromConnectedList(serviceUUID:String, callback:TaskCallback? = nil) {
        self.tasksCenterMgr.executeSystemSyncTask(type: .connectFromConnectedList,
                                                  priority: .height,
                                                  parameters: [BLEConstants.SERVICE_UUID : serviceUUID],
                                                  completedBlock: callback)
    }
    
    func reconnect(callback:TaskCallback? = nil) {
        self.tasksCenterMgr.executeSystemSyncTask(type: .reconnect,
                                                  priority: .height,
                                                  parameters: nil,
                                                  completedBlock: callback)
    }
    
    func sendData(_ service: String,
                  _ characteristic: String,
                  data: Data? = nil,
                  bytes: [UInt8]? = nil,
                  type: BLETaskWriteType = .withoutResponse,
                  resonseService: String? = nil,
                  resonseCharacteristic: String? = nil,
                  priority:BLETaskPriority = .default,
                  isAsync:Bool = false,
                  callback: (([String: Any]) -> Void)? = nil) {
        
        guard (data != nil || data != nil) else {
            callback?([BLEConstants.STATE: BLETaskCompletedState.fail, BLEConstants.MESSAGE: "Data could not be nil. "])
            return
        }
        
        let val:Any = data != nil ? (data!) : (bytes!)
        self.tasksCenterMgr.executeTask(data: val,
                                        service: service,
                                        characteristic: characteristic,
                                        writeReadType: type,
                                        priority: priority,
                                        isAsync: isAsync,
                                        completedBlock: callback)
    }
}
