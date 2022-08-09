//
//  ViewController.swift
//  YYGradientView
//
//  Created by HarrisonFu on 2022/6/22.
//

import UIKit
import SwiftUI
class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
       
        
        let view = YYGradientView1(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height))
        self.view.addSubview(view)
    }


}

