//
//  DeviceManagerVC.swift
//  YYBLEDemo1
//
//  Created by fuhuayou on 2021/4/8.
//

import UIKit

class DeviceManagerVC: UIViewController {
    
    var bleCenter: BLECenter?
    var connectState = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = self.bleCenter!.connectedDevice?.name
        let rightBarButtonItem = UIBarButtonItem(title: "connected", style: UIBarButtonItem.Style.done, target: self, action: #selector(connectOrDisconnect));
        self.navigationItem.rightBarButtonItem = rightBarButtonItem;
        connectState = 1
    }
    
    @objc func connectOrDisconnect() {
        if connectState == 1 {
            bleCenter?.disconnectDevice(callback: { _ in
                self.navigationItem.rightBarButtonItem?.title = "Disconnected"
                print("=========== Did disconnected")
                self.connectState = 0
            })
        } else {
            bleCenter?.connectDevice(self.bleCenter?.connectedDevice, { value in
                self.connectState = 1
                print("=========== connectDevice: ", value)
            })
        }
    }
    
    @IBAction func click (_ sender : UIButton) {
        let data = self.getBigData(count: 100)
        bleCenter?.sendData(data, "FFE0", "FFE1", { (success, messge) in
            print("================= send data message: ", messge)
        })
    }
}

// 固件测试数据
extension DeviceManagerVC {
    
    func getBigData(count: Int) -> Data {
        let mBytes: [UInt8]  =  [
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
        let data: Data = Data(bytes: mBytes, count:count);
        return data
    }
    
    
    
    func bigDataTesting() {
        let mBytes: [UInt8]  =  [
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
        bleCenter?.sendData(data, "6666", "7777")
    }
}
