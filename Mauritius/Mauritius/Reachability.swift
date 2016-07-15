//
//  Reachability.swift
//  Mauritius
//
//  Created by Niranjan Ravichandran on 16/01/16.
//  Copyright © 2016 adavers. All rights reserved.
//  Thanks to http://www.brianjcoleman.com

import Foundation
import SystemConfiguration

public class Reachability: NSObject {
    
    class func isConnectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(&zeroAddress) {
            SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, UnsafePointer($0))
        }
        
        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
            return false
        }
        
        let isReachable = flags == .reachable
        let needsConnection = flags == .connectionRequired
        
        return isReachable && !needsConnection
        
    }
    
    class func networkErrorView(_ view: UIView) {
        
        let blurredView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        let errorMessage: UILabel = UILabel(frame: CGRect(x:0, y:0, width:320, height:50))
        let errorImage = UIImageView(image: UIImage(named: "error.png"))
        let tryAgain = UIButton(frame: CGRect(x:0, y:0, width:100, height:30))
        UIView.animate(withDuration: 0.8, delay: 0.2, usingSpringWithDamping: 0.5, initialSpringVelocity: 1.0, options: .curveEaseOut, animations: { () -> Void in
            
            blurredView.bounds = UIScreen.main().bounds
            blurredView.center = view.center
            blurredView.backgroundColor = UIColor.red()
            blurredView.tag = 100
            
            errorMessage.numberOfLines = 2
            errorMessage.text = "Oops! Please check your internet connection and try again."
            errorMessage.textColor = UIColor.white()
            errorMessage.textAlignment = NSTextAlignment.center
            errorMessage.center = blurredView.center
            errorImage.center = blurredView.center
            errorImage.center.y = blurredView.center.y - 80
            errorImage.alpha = 0
            
            tryAgain.setTitle("Try Again", for: [])
            tryAgain.center = blurredView.center
            tryAgain.center.y = blurredView.center.y + 50
            tryAgain.backgroundColor = UIColor.white()
            tryAgain.setTitleColor(UIColor.red(), for: [])
            tryAgain.layer.cornerRadius = 15
            tryAgain.addTarget(MainViewController(), action: #selector(MainViewController.tryAgainAction), for: .touchUpInside)
            view.addSubview(blurredView)
            blurredView.addSubview(tryAgain)
            blurredView.addSubview(errorMessage)
            
            }) { (Bool) -> Void in
                UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: { () -> Void in
                    blurredView.addSubview(errorImage)
                    errorImage.alpha = 1
                    }, completion: nil)
        }
    }
    
}
