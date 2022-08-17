//
//  YYGridentView2.swift
//  YYGradientView
//
//  Created by HarrisonFu on 2022/8/17.
//

import UIKit

class YYGridentView2: UIView {
    
    var points = (L:CGPoint.zero, T:CGPoint.zero, R:CGPoint.zero)
    var rCenter = CGPoint.zero
    var raduis = 0.0
    var path = UIBezierPath()
    var shape = CAShapeLayer()
    convenience init(frame: CGRect, points:(L:CGPoint, T:CGPoint, R:CGPoint)) {
        self.init(frame: frame)
        self.points = points
        drawCircle1()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    override func draw(_ rect: CGRect) {
//
//        guard let context = UIGraphicsGetCurrentContext() else { return }   // 上下文
//        // 渐变颜色效果设置
//        let colors = [UIColor.clear.cgColor, UIColor(hex: 0xf1f1f1, alpha: 0.55).cgColor] // 渐变色数组
//        let colorSpace = CGColorSpaceCreateDeviceRGB()
//        let locations: [CGFloat] = [0.8, 1.0]
//        let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: locations)
//        context.saveGState()
//
//
//        // 上下文添加路径
//        context.addPath(self.path.cgPath)
//        context.clip(using: .evenOdd)
//        context.drawRadialGradient(gradient!, startCenter: self.rCenter, startRadius: 0, endCenter: self.rCenter, endRadius:  self.raduis, options: CGGradientDrawingOptions.drawsAfterEndLocation)
//        context.restoreGState()
//
////        UIGraphicsGetImageFromCurrentImageContext()
////        UIGraphicsEndImageContext()
////        let imgView = UIImageView(image: img)
////        addSubview(imgView)
//    }
    
    
    func drawCircle() {
        shape.removeFromSuperlayer()
        calculateCircleInfo(p0:points.T, p1: points.L, p2: points.R)
        let tPath = UIBezierPath(arcCenter:self.rCenter, radius: self.raduis, startAngle: 0, endAngle: 2.0 * .pi, clockwise:true)
        shape.lineWidth = 0.0
        shape.path = tPath.cgPath
        shape.fillColor = UIColor.clear.cgColor
        shape.strokeColor = UIColor.red.cgColor
        shape.shadowRadius = 15.0
        shape.shadowOpacity = 0.55//0.35
        shape.shadowOffset = CGSize.zero
        shape.shadowColor = UIColor(hex:0xd71921).cgColor //f1f1f1
        shape.shadowPath = tPath.cgPath.copy(strokingWithWidth: 12.0, lineCap: .round, lineJoin: .round, miterLimit: 0)
        self.layer.addSublayer(shape)
    
        let maskLayer = CAShapeLayer()
        maskLayer.path = UIBezierPath(arcCenter:self.rCenter, radius: self.raduis + 20, startAngle: 0, endAngle: 2.0 * .pi, clockwise:true).cgPath
        maskLayer.fillColor = UIColor.clear.cgColor
        maskLayer.strokeColor = UIColor(hex: 0x06080a).cgColor
        maskLayer.lineWidth = 60
        self.layer.addSublayer(maskLayer)
    }
    
    func drawCircle1() {
        shape.removeFromSuperlayer()
        calculateCircleInfo(p0:points.T, p1: points.L, p2: points.R)
        let tPath = UIBezierPath(arcCenter:self.rCenter, radius: self.raduis, startAngle: 0, endAngle: 2.0 * .pi, clockwise:true)
        shape.lineWidth = 0.0
        shape.path = tPath.cgPath
        shape.fillColor = UIColor.clear.cgColor
        shape.strokeColor = UIColor.red.cgColor
        shape.shadowRadius = 15.0
        shape.shadowOpacity = 0.90
        shape.shadowOffset = CGSize.zero
        shape.shadowColor = UIColor(hex:0xBC0F0F).cgColor //f1f1f1
        shape.shadowPath = tPath.cgPath.copy(strokingWithWidth: 12.0, lineCap: .round, lineJoin: .round, miterLimit: 0)
        self.layer.addSublayer(shape)
    
        let maskLayer = CAShapeLayer()
        maskLayer.path = UIBezierPath(arcCenter:self.rCenter, radius: self.raduis + 20, startAngle: 0, endAngle: 2.0 * .pi, clockwise:true).cgPath
        maskLayer.fillColor = UIColor.clear.cgColor
        maskLayer.strokeColor = UIColor(hex: 0xd7d8d8).cgColor
        maskLayer.lineWidth = 60
        self.layer.addSublayer(maskLayer)
    }

    func calculateCircleInfo(p0: CGPoint, p1: CGPoint, p2:CGPoint) {
        //-(x2-x1/(y2-y1) * [x-(x1+x2)/2]+(y1+y2)/2
        //-(x2-x1/(y2-y1)
        let A = -(p1.x - p0.x)/(p1.y - p0.y)
        let D = -(p2.x - p0.x)/(p2.y - p0.y)
        
        //(x1+x2)/2
        let B = (p1.x + p0.x)/2.0
        let E = (p2.x + p0.x)/2.0
        
        //(y1+y2)/2
        let C = (p1.y + p0.y)/2.0
        let F = (p2.y + p0.y)/2.0
        
        let x = (D*E - A*B - F + C)/(D-A)
        let y = A*x - A*B + C
        let center = CGPoint(x: x, y: y)
        let R = sqrt(pow(x - p0.x, 2.0) + pow(y - p0.y, 2.0))
        self.rCenter = center
        self.raduis = R
        self.path = UIBezierPath(arcCenter: rCenter, radius: R, startAngle: 0, endAngle: 2.0 * .pi, clockwise: true)
    }
}
