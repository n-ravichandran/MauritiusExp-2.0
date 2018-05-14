//
//  FaveIcon.swift
//  Mauritius
//
//  Created by Niranjan Ravichandran on 2/11/18.
//  Copyright © 2018 Aviato. All rights reserved.
//

import UIKit

class FaveIcon: UIView {
    
    var iconColor: UIColor = .gray
    var iconImage: UIImage!
    var iconLayer: CAShapeLayer!
    var iconMask:  CALayer!
    var contentRegion: CGRect!
    var tweenValues: [CGFloat]?
    
    init(region: CGRect, icon: UIImage, color: UIColor) {
        self.iconColor      = color
        self.iconImage      = icon
        self.contentRegion  = region
        super.init(frame: CGRect.zero)
        
        applyInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


// MARK: create
extension FaveIcon{
    
    class func createFaveIcon(_ onView: UIView, icon: UIImage, color: UIColor) -> FaveIcon{
        let faveIcon = Init(FaveIcon(region:onView.bounds, icon: icon, color: color)){
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.backgroundColor                           = .clear
        }
        onView.addSubview(faveIcon)
        
        (faveIcon, onView) >>- [.centerX,.centerY]
        
        faveIcon >>- [.width,.height]
        
        return faveIcon
    }
    
    func applyInit(){
        let maskRegion  = contentRegion.size.scaleBy(0.7).rectCentered(at: contentRegion.center)
        let shapeOrigin = CGPoint(x: -contentRegion.center.x, y: -contentRegion.center.y)
        
        
        iconMask = Init(CALayer()){
            $0.contents      = iconImage.cgImage
            $0.contentsScale = UIScreen.main.scale
            $0.bounds        = maskRegion
        }
        
        iconLayer = Init(CAShapeLayer()){
            $0.fillColor = iconColor.cgColor
            $0.path      = UIBezierPath(rect: CGRect(origin: shapeOrigin, size: contentRegion.size)).cgPath
            $0.mask      = iconMask
        }
        
        self.layer.addSublayer(iconLayer)
    }
}


// MARK : animation
extension FaveIcon{
    
    func animateSelect(_ isSelected: Bool = false, fillColor: UIColor, duration: Double = 0.5, delay: Double = 0){
        if nil == tweenValues{
            tweenValues = generateTweenValues(from: 0, to: 1.0, duration: CGFloat(duration))
        }
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        iconLayer.fillColor = fillColor.cgColor
        CATransaction.commit()
        
        let selectedDelay = isSelected ? delay : 0
        
        if isSelected{
            self.alpha = 0
            UIView.animate(
                withDuration: 0,
                delay: selectedDelay,
                options: .curveLinear,
                animations: {
                    self.alpha = 1
            }, completion: nil)
        }
        
        let scaleAnimation = Init(CAKeyframeAnimation(keyPath: "transform.scale")){
            $0.values    = tweenValues!
            $0.duration  = duration
            $0.beginTime = CACurrentMediaTime()+selectedDelay
        }
        iconMask.add(scaleAnimation, forKey: nil)
    }
    
    
    
    func generateTweenValues(from: CGFloat, to: CGFloat, duration: CGFloat) -> [CGFloat]{
        var values         = [CGFloat]()
        let fps            = CGFloat(60.0)
        let tpf            = duration/fps
        let c              = to-from
        let d              = duration
        var t              = CGFloat(0.0)
        let tweenFunction  = Elastic.ExtendedEaseOut
        
        while(t < d){
            let scale = tweenFunction(t, from, c, d, c+0.001, 0.39988)  // p=oscillations, c=amplitude(velocity)
            values.append(scale)
            t += tpf
        }
        return values
    }
    
    func setFillWithoutAnimation(fillColor: UIColor) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        iconLayer.fillColor = fillColor.cgColor
        CATransaction.commit()
    }
}

