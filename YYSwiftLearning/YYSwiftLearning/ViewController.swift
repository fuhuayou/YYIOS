//
//  ViewController.swift
//  YYSwiftLearning
//
//  Created by zk-fuhuayou on 2021/8/25.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var longpressBtn: UIButton?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let copyLabel = UICopyLabel()
        copyLabel.frame = CGRect(x: 100, y: (self.longpressBtn?.frame.minY ?? 0) + 100, width: 200, height: 100)
        copyLabel.backgroundColor = .red
        self.view.addSubview(copyLabel)
        copyLabel.text = "GOGOOGOG0"
//        self.setupLongpress()
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
    
    func setupLongpress() {
        guard let longpressBtn = longpressBtn else { return }
        longpressBtn.addTarget(self, action: #selector(onLongPress(_:)), for: .touchUpInside)
    }
    
    @objc func onLongPress(_ sender: UIButton) {
        let menu = UIMenuController.shared
        if !menu.isMenuVisible {
            menu.showMenu(from: sender, rect: sender.bounds)
        }
    }

}

class UICopyLabel: UILabel {
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }
    
    func sharedInit() {
        isUserInteractionEnabled = true
        addGestureRecognizer(UILongPressGestureRecognizer(target: self,
                                                          action: #selector(showMenu(_:))))
    }
    
    @objc func showMenu(_ sender: UILongPressGestureRecognizer) {
        becomeFirstResponder()
        let menu = UIMenuController.shared
        if !menu.isMenuVisible {
            menu.showMenu(from: self, rect: self.bounds)
        }
        
    }
    
    override func copy(_ sender: Any?) {
        let board = UIPasteboard.general
        board.string = text
        let menu = UIMenuController.shared
        menu.hideMenu()
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(UIResponderStandardEditActions.copy(_:)) {
            return true
        }
        return false
    }
    
}
