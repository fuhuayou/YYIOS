//
//  ViewController.swift
//  YYSwiftLearning
//
//  Created by zk-fuhuayou on 2021/8/25.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    //MARK: 指针的研究和学习
    @IBAction func onPointerTesting(_ sender: AnyObject) {
        SwiftPointer().structPointerTesting()
    }
    
    //MARK: GCD多线程的实现
    @IBAction func gcdThread(_ sender: AnyObject) {
        let gcd = GCD()
        gcd.testing()
    }
    
    @IBAction func metal(_ sender: AnyObject) {
        
        let vc = YYMetalVC()
        self.navigationController?.pushViewController(vc, animated: true)
        
    }

}

