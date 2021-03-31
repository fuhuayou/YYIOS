//
//  ViewController.swift
//  YYBLEDemo1
//
//  Created by yy.Fu on 2021/3/30.
//

import UIKit
import RxSwift
import RxCocoa
class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var iBleCenter : BLECenter? = nil;
    
    
    ///rxswift
    let disposeBag = DisposeBag();
    let vm = ViewControllerVM();
    
    let table = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.iBleCenter = BLECenter.init();
        self.iBleCenter?.scan(true , "zetime", 20);
        ///rxswift.
//        vm.data.bind(to: tableView.rx.items(cellIdentifier: "TestingCell")){_, music, cell in
//            cell.textLabel?.text = music["name"];
//            cell.detailTextLabel?.text = music["singer"];
//        }.disposed(by: disposeBag);
        
        vm.data.bind(to: tableView.rx.items) { (tb, row, model) -> UITableViewCell in
            let icell = tb.dequeueReusableCell(withIdentifier: "TestingCell")
            let cell = icell != nil ? icell : UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "TestingCell")
            cell?.textLabel?.text = model["name"];
            cell?.detailTextLabel?.text = model["singer"];
            return cell!
            }.disposed(by: disposeBag)
        
        //tableView点击响应
//        tableView.rx.modelSelected(Dictionary.Key).subscribe(onNext: { music in
//                    print("你选中的歌曲信息【\(value)】")
//                }).disposed(by: disposeBag)
        
    }
    
    @IBAction func click(_ sender : UIButton){
        sender.isSelected = !sender.isSelected;
        self.iBleCenter?.scan(!sender.isSelected , "zetime", 20);
    }
    

   


}

