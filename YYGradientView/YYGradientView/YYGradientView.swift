//
//  YYGradientView.swift
//  YYGradientView
//
//  Created by HarrisonFu on 2022/6/22.
//

import Foundation
import UIKit


class YYGradientView: UIView {
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.drawPathGradient()
    }
    
    func drawPathGradient() {
        
        UIGraphicsBeginImageContext(self.bounds.size);
        _ = UIGraphicsGetCurrentContext();
        
        let path = CGMutablePath()
        let rect = CGRect(x:0, y:0, width:300, height:300)
        path.move(to: CGPoint(x: rect.minX, y:  rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y:  rect.maxY))
        path.addLine(to: CGPoint(x: rect.width, y:  rect.maxY))
        path.addLine(to: CGPoint(x: rect.width, y:  rect.minY))
        path.closeSubpath()
        
        let context = UIGraphicsGetCurrentContext()   // 上下文
        self.drawRadialGradient(context: context!,
                              path: path,
                                startColor: UIColor(hex: 0xD9D9D9, alpha: 0.2).cgColor,
                              endColor: UIColor(hex: 0xD9D9D9).cgColor)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        let imgView = UIImageView(image: img)
        addSubview(imgView)
    }
    
    
    func drawGradientRect(context: CGContext, path:CGPath, startColor:CGColor, endColor:CGColor) {
        let colors = [startColor, endColor] // 渐变色数组
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        //CGFloat locations[] = { 0.0, 0.3, 1.0 }; // 颜色位置设置,要跟颜色数量相等，否则无效
        let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: nil)// 渐变颜色效果设置
        
        //获取到起止点
        let pathRect = path.boundingBox
        let startPoint = CGPoint(x:pathRect.midX, y:pathRect.midY)
        let endPoint = CGPoint(x:pathRect.maxX, y:pathRect.maxY)
        context.saveGState()
        context.addPath(path); // 上下文添加路径
        context.clip();
        // 绘制线性渐变
        context.drawLinearGradient(gradient!, start: startPoint, end: endPoint, options: CGGradientDrawingOptions.drawsBeforeStartLocation)
        context.restoreGState()
        
    }
    
    
    //圆半径方向渐变
    func drawRadialGradient(context: CGContext, path:CGPath, startColor:CGColor, endColor:CGColor)
    {
        let colors = [startColor, endColor] // 渐变色数组
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let locations = [0.5, 1.0].map { val in
            return UnsafePointer<Double>(val)
        }
        let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: locations)// 渐变颜色效果设置
        
        let pathRect = path.boundingBox
        let center = CGPoint(x: pathRect.midX, y: pathRect.midY)
        let radius = pathRect.size.height / 2.0
        context.saveGState()
        context.addPath(path); // 上下文添加路径
        context.clip(using: .evenOdd)
        context.drawRadialGradient(gradient!, startCenter: center, startRadius: 0, endCenter: center, endRadius: radius, options: CGGradientDrawingOptions.drawsAfterEndLocation)
        context.restoreGState()
        self.layer.cornerRadius = radius
        self.clipsToBounds = true
    }
    
    
    
    
    
}


extension UIColor {
    public convenience init(_ hex:String, alpha: CGFloat = 1.0){
        var cString: String = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
        
        if cString.hasPrefix("#") {
            cString = String(cString[cString.index(cString.startIndex, offsetBy: 1)...])
        }
        if cString.count != 6 {
            cString = "000000"
        }
        var rgbValue: UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        self.init(red:CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                  green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                  blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                  alpha: alpha)
    }
    
    public convenience init(hex: Int, alpha: CGFloat = 1) {
        let components = (
                R: CGFloat((hex >> 16) & 0xff) / 255,
                G: CGFloat((hex >> 08) & 0xff) / 255,
                B: CGFloat((hex >> 00) & 0xff) / 255
        )
        self.init(red: components.R, green: components.G, blue: components.B, alpha: alpha)
    }

}
