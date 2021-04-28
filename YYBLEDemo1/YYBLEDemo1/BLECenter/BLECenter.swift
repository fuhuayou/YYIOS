//
//  BLECenter.swift
//  YYBLEDemo
//
//  Created by fuhuayou on 2021/3/16.
//

import UIKit
import CoreBluetooth

class BLECenter: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    // type
    typealias BLECallback = (Any) -> Void
    
    let BLEQUEUE = "BLEQUEUE"
    let BLEIDENTIFIER = "BLEIDENTIFIER"
    var filter: String?
    var bleCenter: CBCentralManager?
    //scan
    var scanDevices: [BLEDevice]?
    var centralStateSemaphore: DispatchSemaphore?;
    var scanDevicesCallback:((_ devices:[BLEDevice]?) -> Void)?;
    
    //connect
    var connectedDevice: BLEDevice?
    var connectingDevice: BLEDevice?
    var connectCallback : BLECallback?
    
    //connected services
    var connServices: [String: [CBCharacteristic]]?//"service: [特征值数组]"
    
    override init() {
        super.init();
        self.initBLE();
        print("=========BLECenter FINISED INIT==============")
    }
    
    /*
     init the ble center.
     */
    func initBLE() -> Void {
        self.centralStateSemaphore = DispatchSemaphore.init(value: 0);
        self.bleCenter = CBCentralManager.init(
            delegate: self as CBCentralManagerDelegate,
            queue: DispatchQueue.init(label: "BLEQUEUE"),
            options:[CBCentralManagerOptionShowPowerAlertKey: 0,
                     CBCentralManagerOptionRestoreIdentifierKey: BLEIDENTIFIER]);
        print("========= BLECenter BEGAIN TO INIT CENTRAL ==========")
    }
    
    /**
     Scan devices.
     */
    func scan(_ isEnable: Bool, _ filter: String?, _ durarion: Int, _ scanCallback: @escaping (_ devices:[BLEDevice]?) -> Void) {
        scanDevicesCallback = scanCallback
        DispatchQueue.global().async {
            if self.centralStateSemaphore != nil {
                self.centralStateSemaphore!.wait();
                self.centralStateSemaphore = nil;
            }

            if isEnable {
                self.filter = filter;
                self.scanDevices = [];
                if self.bleCenter!.isScanning {
                    self.bleCenter?.stopScan()
                }
                
                self.bleCenter?.scanForPeripherals(withServices: nil, options: nil);
                print("========= BLECenter DID SCAN ==============");
            } else {
                self.bleCenter?.stopScan();
                print("========= BLECenter DID STOP SCAN ==============")
            }
            self.bleCenter?.retrievePeripherals(withIdentifiers:[])
        }
    }
    
    
    func scanTimer(isEnable : Bool) -> Void {
        
        
    }
    
    /**
     connect device.
     */
    func connectDevice(_ device: BLEDevice?, _ callback: BLECallback?) {
        connectCallback = callback;
        if device == nil || device?.blePeripheral == nil {
            connectCallback?(["sucess" : false, "message" : "device nil"])
            return;
        }
        self.connectedDevice = device
        self.bleCenter?.connect((device?.blePeripheral)!, options: nil)
    }
    
    /**
     send data.
     */
    func sendData(_ data: String, _ service: String, _ characteristic: String) {
        
        //get characteristic
        let characteristics = connServices?[service];
        if characteristics == nil || characteristics!.count == 0 {
            return
        }
        var tCha:CBCharacteristic?
        for cha in characteristics! where cha.uuid.uuidString == characteristic {
           tCha = cha
        }
        if tCha == nil {
            return
        }
//        let mBytes: [UInt8]  =  [10, 10, 10, 0xa1, 0xa2, 33, 10, 0, 0, 0xa1, 0xa2, 33, 10, 10, 10, 0xa1, 0xa2, 33, 0xa2, 33]
        let mBytes: [UInt8]  =  [
//                                 10, 10, 10, 0xa1, 0xa2, 33, 10, 0, 0, 0xa1, 0xa2, 33, 10, 0, 0, 0xa1, 0xa2, 33, 0xa2, 33,
//                                 10, 10, 10, 0xa1, 0xa2, 33, 10, 0, 0, 0xa1, 0xa2, 33, 10, 0, 0, 0xa1, 0xa2, 33, 0xa2, 33,
            
                                 10, 10, 10, 0xa1, 0xa2, 33, 10, 0, 0, 0xa1, 0xa2, 33, 10, 0, 0, 0xa1, 0xa2, 33, 0xa2, 33,
                                 10, 10, 10, 0xa1, 0xa2, 33, 10, 0, 0, 0xa1, 0xa2, 33, 10, 0, 0, 0xa1, 0xa2, 33, 0xa2, 33,
                                 10, 10, 10, 0xa1, 0xa2, 33, 10, 0, 0, 0xa1, 0xa2, 33, 10, 0, 0, 0xa1, 0xa2, 33, 0xa2, 33,
                                 10, 10, 10, 0xa1, 0xa2, 33, 10, 0, 0, 0xa1, 0xa2, 33, 10, 0, 0, 0xa1, 0xa2, 33, 0xa2, 33,
                                 10, 10, 10, 0xa1, 0xa2, 33, 10, 0, 0, 0xa1, 0xa2, 33, 10, 0, 0, 0xa1, 0xa2, 33, 0xa2, 33,
                                 10, 10, 10, 0xa1, 0xa2, 33, 10, 0, 0, 0xa1, 0xa2, 33, 10, 0, 0, 0xa1, 0xa2, 33, 0xa2, 33,
                                 10, 10, 10, 0xa1, 0xa2, 33, 10, 0, 0, 0xa1, 0xa2, 33, 10, 0, 0, 0xa1, 0xa2, 33, 0xa2, 33,
                                 10, 10, 10, 0xa1, 0xa2, 33, 10, 0, 0, 0xa1, 0xa2, 33, 10, 0, 0, 0xa1, 0xa2, 33, 0xa2, 33,
                                 10, 10, 10, 0xa1, 0xa2, 33, 10, 0, 0, 0xa1, 0xa2, 33, 10, 0, 0, 0xa1, 0xa2, 33, 0xa2, 33,
                                 10, 10, 10, 0xa1, 0xa2, 33, 10, 0, 0, 0xa1, 0xa2, 33, 10, 0, 0, 0xa1, 0xa2, 0xff, 0xff, 0xff];
        let data: Data = Data(bytes: mBytes, count:mBytes.count);
        self.connectedDevice?.blePeripheral?.writeValue(data as Data, for: tCha!, type: CBCharacteristicWriteType.withoutResponse)
//        for index in 1...50 {
//            Thread.sleep(forTimeInterval: 0.01)
//            print("=============== index: ", index)
//            self.connectedDevice?.blePeripheral?.writeValue(data as Data, for: tCha!, type: CBCharacteristicWriteType.withoutResponse)
//        }
//        
        if let blePeripheral = self.connectedDevice?.blePeripheral {
            self.bleCenter?.cancelPeripheralConnection(blePeripheral)
        }
    
       
    }
    
    /**
     ================ Delegate methods. ================
     */
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if (peripheral.name != nil && ((self.filter == nil) || peripheral.name!.lowercased().contains(self.filter!))) {
            
            if self.scanDevices == nil {
                self.scanDevices = Array();
            }
            
            var exist = false;
            for per in self.scanDevices! where per.name == peripheral.name {
                exist = true;
            }
            
            if !exist {
                print("================" + peripheral.name!);
                let aDev = BLEDevice(peripheral.name, peripheral.identifier.uuidString, peripheral);
                self.scanDevices?.append(aDev);
                scanDevicesCallback?(scanDevices!)
            }
        }
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if self.centralStateSemaphore != nil {
            self.centralStateSemaphore!.signal();
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.delegate = self;
        peripheral.discoverServices(nil)
        connectCallback?(["sucess" : true, "message" : "didConnect"]);
        print("============ didConnect peripheral: ", peripheral)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        connServices = Dictionary();
    }
    
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        connectCallback?(["sucess" : false, "message" : "didFailToConnect"]);
    }

    func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
        
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
        // 判断是否已经发现所有的服务和对应服务的特征值。
        
        // 全部打开。
        for characteristic in service.characteristics! {
            peripheral .setNotifyValue(true, for: characteristic)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if peripheral.services == nil {
            return;
        }
        
        if connServices == nil {
            connServices = Dictionary();
        }
        print("=========services: ", peripheral.services!)
//        for server in  peripheral.services! {
//            print("=========services: ", server.uuid.uuidString)
//        }
//
        for service in peripheral.services! {
            connServices?[service.uuid.uuidString] = [CBCharacteristic]();
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }

    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        print("=========== didWriteValueFor ======== : ")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        print("=========== didUpdateValueFor ======== : ", characteristic.uuid.uuidString)
    }
    
}
