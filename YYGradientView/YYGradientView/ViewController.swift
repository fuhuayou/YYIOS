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
        self.view.backgroundColor = .white
        let point0 = CGPoint(x: 150, y: 300)
        let point1 = CGPoint(x: 100, y: 550)
        let point2 = CGPoint(x: 300, y: 550)
        
        let view = YYGridentView2(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height), points: (L: point1, T: point0, R: point2))
        self.view.addSubview(view)
//        view.backgroundColor = UIColor(hex: 0x06080a, alpha: 1.0)
        view.backgroundColor = UIColor(hex: 0xd7d8d8, alpha: 1.0)
    }


}

