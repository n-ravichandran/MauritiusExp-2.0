//
//  UIColor+MUIAlertController.swift
//  Mauritius
//
//  Created by Niranjan Ravichandran on 2/1/18.
//  Copyright © 2018 Aviato. All rights reserved.
//

import UIKit

extension UIColor {
    
    /// Default color of the EMAlertView
    static let muiAlertviewColor = alertViewColor()
    
    /// Default color of the EMAlertAction
    static let iosBlueColor = defaultBlueColor()
    
    /// Default color of the EMAlertView separator color
    static let muiSeparatorColor = buttonSepraratorColor()
    
    /// Default color of the EMAlertAction cancel style
    static let muiCancelColor = cancelRedColor()
    
    /// Default color of the EMAlertAction normal style
    static let muiActionColor = defaultGrayColor()
    
    internal static func alertViewColor() -> UIColor {
        return UIColor(red: 250/255, green: 250/255, blue: 250/255, alpha: 1.0)
    }
    
    internal static func defaultBlueColor() -> UIColor {
        return UIColor(red: 0/255, green: 118/255, blue: 255/255, alpha: 1.0)
    }
    
    internal static func buttonSepraratorColor() -> UIColor {
        return UIColor(red: 200/255, green: 199/255, blue: 204/255, alpha: 1.0)
    }
    
    internal static func cancelRedColor() -> UIColor {
        return UIColor(red: 230/255, green: 57/255, blue: 70/255, alpha: 1.0)
    }
    
    internal static func defaultGrayColor() -> UIColor {
        return UIColor(red: 53/255, green: 53/255, blue: 53/255, alpha: 1.0)
    }
}
