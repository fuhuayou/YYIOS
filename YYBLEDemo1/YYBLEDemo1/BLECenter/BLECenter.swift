//
//  BLECenter.swift
//  YYBLEDemo
//
//  Created by fuhuayou on 2021/3/16.
//

import UIKit
import CoreBluetooth
//swiftlint:disable force_unwrapping empty_count force_cast control_statement attributes
class BLECenter: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    // type
    typealias BLECallback = (Any) -> Void
    
    let BLEQUEUE = "BLEQUEUE"
    let BLEIDENTIFIER = "BLEIDENTIFIER"
    var filter: String?
    var bleCenter: CBCentralManager?
    //scan
    var scanDevices: [BLEDevice]?
    var centralStateSemaphore: DispatchSemaphore?
    var scanDevicesCallback:((_ devices:[BLEDevice]?) -> Void)?
    
    //connect
    var connectedDevice: BLEDevice?
    var connectingDevice: BLEDevice?
    var connectCallback : BLECallback?
    
    //connected services
    var connServices: [String: [CBCharacteristic]]?//"service: [特征值数组]"
    
    //restored
    var restoreSemaphore:  DispatchSemaphore?
    
    override init() {
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
            if let centralStateSemaphore = self.centralStateSemaphore {
                centralStateSemaphore.wait()
                self.centralStateSemaphore = nil
            }

            if isEnable {
                self.filter = filter
                self.scanDevices = []
                if self.bleCenter!.isScanning {
                    self.bleCenter?.stopScan()
                }
                
                self.bleCenter?.scanForPeripherals(withServices:nil, options: nil)
                if let bleCenter = self.bleCenter {
                    
                    let services = self.changeToUUIDD(servers: retrieveServers)
                    if services != nil {
                        let devices = bleCenter.retrieveConnectedPeripherals(withServices:services!)
                        print("========= retrieveConnectedPeripherals: ", devices)
                        for peripheral in devices {
                            self.centralManager(bleCenter, didDiscover: peripheral, advertisementData:[:], rssi:NSNumber(0))
                        }
                    }
                }
                print("========= BLECenter DID SCAN ==============")
            } else {
                self.bleCenter?.stopScan()
                print("========= BLECenter DID STOP SCAN ==============")
            }
        }
    }

    /**
     connect device.
     */
    func connectDevice(_ device: BLEDevice?, _ callback: BLECallback?) {
        connectCallback = callback
        self.connectDevice(device)
    }
    
    @objc func connectDevice(_ device: BLEDevice?) {
        self.scan(false)
        if device == nil || device?.blePeripheral == nil {
            connectCallback?(["sucess" : false, "message" : "device nil"])
            return
        }
        self.connectedDevice = device
        self.bleCenter?.connect((device?.blePeripheral)!, options: nil)
    }
    
    /**
     disconnect device
     */
     func disconnectDevice(callback: ((Bool) -> Void)?) {
        if let bleCenter = self.bleCenter {
            if self.connectedDevice != nil && self.connectedDevice!.blePeripheral != nil {
                bleCenter.cancelPeripheralConnection(self.connectedDevice!.blePeripheral!)
            }
        }
    
        if let callback = callback {
            callback(true)
        }
    }
    
    /**
     send data.
     */
    func sendData(_ data: Data?,
                  _ service: String,
                  _ characteristic: String,
                  _ callback: ((Bool, String) -> Void)? = nil) {
        self.sendData(data, service, characteristic, CBCharacteristicWriteType.withoutResponse, callback)
    }
    func sendData(_ data: Data?,
                  _ service: String,
                  _ characteristic: String,
                  _ type: CBCharacteristicWriteType = CBCharacteristicWriteType.withoutResponse,
                  _ callback: ((Bool, String) -> Void)? = nil) {
        
        //get characteristic
        let characteristics = connServices?[service]
        if characteristics == nil || characteristics!.count == 0 {
            if let callback = callback {
                callback(false, "Could not find characteristics")
            }
            return
        }
        var tCha:CBCharacteristic?
        for cha in characteristics! where cha.uuid.uuidString == characteristic {
           tCha = cha
        }
        if tCha == nil {
            if let callback = callback {
                callback(false, "Could not find command characteristic")
            }
            return
        }
        
        //check data.
        if data == nil || data!.count == 0 {
            if let callback = callback {
                callback(false, "Data nil.")
            }
            return
        }
        self.connectedDevice?.blePeripheral?.writeValue(data!, for: tCha!, type: type)
        if let callback = callback {
            callback(true, "Did send success.")
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
            }
        }
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("============ centralManagerDidUpdateState: ", central.state)
        if let centralStateSemaphore = self.centralStateSemaphore {
            centralStateSemaphore.signal()
        }
        
        if let restoreSemaphore = self.restoreSemaphore {
            restoreSemaphore.signal()
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.delegate = self
        peripheral.discoverServices(nil)
        connectCallback?(["success" : true, "message" : "didConnect"])
        print("============ didConnect peripheral: ", peripheral)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        connServices = [:]
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        connectCallback?(["sucess" : false, "message" : "didFailToConnect"])
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
            if central.state == CBManagerState.poweredOn {
                self.connectDevice(aDev, nil)
            } else {
                DispatchQueue.global().async {
                    self.restoreSemaphore = DispatchSemaphore(value: 0)
                    self.restoreSemaphore!.wait()
                    self.connectDevice(aDev)
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
        print("=========== didUpdateValueFor ======== : ", characteristic.uuid.uuidString, characteristic.value ?? "nil")
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
}
