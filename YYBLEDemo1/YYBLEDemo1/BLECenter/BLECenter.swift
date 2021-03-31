//
//  BLECenter.swift
//  YYBLEDemo
//
//  Created by fuhuayou on 2021/3/16.
//

import UIKit
import CoreBluetooth

class BLECenter: NSObject, CBCentralManagerDelegate {
    
    let BLEQUEUE = "BLEQUEUE";
    let BLEIDENTIFIER = "BLEIDENTIFIER";
    var filter: String?;
    var iBleCenter: CBCentralManager?;
    
    //scan
    var scanDevices : Array<CBPeripheral>?;
    var centralStateSemaphore : DispatchSemaphore?;
    
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
        self.iBleCenter = CBCentralManager.init(delegate: self as CBCentralManagerDelegate, queue: DispatchQueue.init(label: "BLEQUEUE"), options:[CBCentralManagerOptionShowPowerAlertKey: 0, CBCentralManagerOptionRestoreIdentifierKey: BLEIDENTIFIER]);
        print("========= BLECenter BEGAIN TO INIT CENTRAL ==========")
    }
    
    /**
     Scan devices.
     */
    func scan(_ isEnable: Bool, _ filter: String, _ durarion: Int) -> Void {
        
        DispatchQueue.global().async {
            if self.centralStateSemaphore != nil {
                self.centralStateSemaphore!.wait();
                self.centralStateSemaphore = nil;
            }
            
            if isEnable {
                self.filter = filter;
                self.iBleCenter?.scanForPeripherals(withServices: nil, options: nil);
                print("========= BLECenter DID SCAN ==============")
            }
            else{
                self.iBleCenter?.stopScan();
                print("========= BLECenter DID STOP SCAN ==============")
            }
        }
    }
    
    
    func scanTimer(isEnable : Bool) -> Void {
        
        
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
            for per in self.scanDevices! {
                if( per.name == peripheral.name){
                    exist = true;
                }
            }
            
            if !exist {
                self.scanDevices?.append(peripheral);
            }
            print("================devices: ",  self.scanDevices!);
            print("================" + peripheral.name!);
        }

    }
    
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if self.centralStateSemaphore != nil {
            self.centralStateSemaphore!.signal();
        }
    }
    
    
    func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
        
    }

}
