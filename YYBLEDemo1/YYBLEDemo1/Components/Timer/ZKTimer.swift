//
//  ZKTimer.swift
//  YYBLEDemo1
//
//  Created by fuhuayou on 2021/4/14.
//
import UIKit

class ZKTimer: NSObject {
    
    var timeout: Double?
    var isRepeat: Bool?
    var timer: Timer?
    init(interval:Double, repeats:Bool, block:((ZKTimer?) -> Void )? ) {
        super.init()
        DispatchQueue.global().async {
            self.timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: repeats, block: {[weak self] Timer in
                if let block = block {
                    block(self)
                }
                
                if self?.isRepeat == false {
                    self?.invalidate()
                }
            })
            
            if let timer = self.timer {
                RunLoop.current.add(timer, forMode: RunLoop.Mode.common) // make sure will not stuck by UI tracking.
                RunLoop.current.run()
            }
        }
        self.isRepeat = repeats
        self.timeout = interval
    }
    
    static func timer(interval:Double, repeats:Bool, block:((ZKTimer?) -> Void )? ) {
        _ =  ZKTimer(interval: interval, repeats: repeats, block: block)
    }
    
    func invalidate() {
        if let timer = self.timer {
            timer.invalidate()
            self.timer = nil
        }
    }

}
