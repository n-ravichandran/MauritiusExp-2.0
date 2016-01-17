//
//  LanguageLabel.swift
//  Mauritius
//
//  Created by Niranjan Ravichandran on 15/01/16.
//  Copyright © 2016 adavers. All rights reserved.
//

import UIKit

class LanguageLabel: UILabel {


    override func drawTextInRect(rect: CGRect) {
        super.drawTextInRect(UIEdgeInsetsInsetRect(rect, UIEdgeInsetsMake(0, 0, 0, 15)))
    }
}
