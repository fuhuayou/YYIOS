//
//  DeviceManagerVC.swift
//  YYBLEDemo1
//
//  Created by fuhuayou on 2021/4/8.
//

import UIKit

class DeviceManagerVC: UIViewController {
    
    var bleCenter: BLECenter?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func click (_ sender : UIButton) {
        bleCenter?.sendData("", "FFE0", "FFE1")
    }
    

    

    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
