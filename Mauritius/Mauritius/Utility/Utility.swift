//
//  Utility.swift
//  Mauritius
//
//  Created by Niranjan Ravichandran on 11/25/17.
//  Copyright © 2017 Aviato. All rights reserved.
//

import UIKit

//Notification names
let mOpenSettingsNotification = "mOpenSettingsNotification"

typealias JSON = [String: AnyObject]

extension UIColor {
    
    public convenience init?(hexString: String) {
        let r, g, b, a: CGFloat
        
        if hexString.hasPrefix("#") {
            let start = hexString.index(hexString.startIndex, offsetBy: 1)
            let hexColor = String(hexString[start...])
            
            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0
                
                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255
                    
                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }
        
        return nil
    }
    
    class var mblack: UIColor {
        return UIColor(hexString: "#3D3D46ff")!
    }
    
    class var mDarkBlack: UIColor {
        return UIColor(hexString: "#33333Bff")!
    }
    
    class var mGreen: UIColor {
        return UIColor(hexString: "#13c26bff")!
    }
    
    class var mRed: UIColor {
        return UIColor(hexString: "#E96164ff")!
    }
    
    class var lightBg: UIColor {
        return UIColor(hexString: "#E6E7EAff")!
    }
    
}

extension UIImage {
    func tintWithColor(_ color:UIColor)->UIImage {
        
        UIGraphicsBeginImageContext(self.size)
        let context = UIGraphicsGetCurrentContext()
        
        // flip the image
        context!.scaleBy(x: 1.0, y: -1.0)
        context!.translateBy(x: 0.0, y: -self.size.height)
        
        // multiply blend mode
        context!.setBlendMode(CGBlendMode.multiply)
        
        let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        context!.clip(to: rect, mask: self.cgImage!)
        color.setFill()
        context!.fill(rect)
        
        // create uiimage
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
        
    }
}

extension UIApplication {
    class func topViewController(_ base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(presented)
        }
        return base
    }
}

enum AlertType {
    case error
    case info
    case success
}

class Utility {
    
    class func alert(with title: String, message: String?, type: AlertType = .success) {
        var alert: MUIAlertController!
        if type == .success {
            alert = MUIAlertController(icon: #imageLiteral(resourceName: "ok").withRenderingMode(.alwaysTemplate).tintWithColor(UIColor.mGreen), title: title, message: message)
        }else if type == .info {
            alert = MUIAlertController(icon: #imageLiteral(resourceName: "icons-warning"), title: title, message: message)
        }else {
            alert = MUIAlertController(icon: #imageLiteral(resourceName: "icons-error").withRenderingMode(.alwaysTemplate).tintWithColor(UIColor.red.withAlphaComponent(0.6)), title: title, message: message)
        }
        
        alert.addAction(action: MUIAlertAction(title: "Ok", style: .cancel))
        UIApplication.topViewController()?.present(alert, animated: true, completion: nil)
    }
}

func delay(_ delay:Double, closure:@escaping ()->()) {
    DispatchQueue.main.asyncAfter(
        deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
}
