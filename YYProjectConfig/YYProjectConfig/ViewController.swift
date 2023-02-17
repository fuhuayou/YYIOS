//
//  ViewController.swift
//  YYProjectConfig
//
//  Created by HarrisonFu on 2023/2/15.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            let version: String? = try? Configuration.value(for: "API_BASE_URL")
            debugPrint("========\(version ?? "error")")
        }
    }


}

