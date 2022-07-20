//
//  ViewController.swift
//  YYGradientView
//
//  Created by HarrisonFu on 2022/6/22.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
       
        
        let view = YYGradientView(frame: CGRect(x: 0, y: 100, width: 300, height: 300))
        self.view.addSubview(view)
    }


}

