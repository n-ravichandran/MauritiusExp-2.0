//
//  LanguageLabel.swift
//  Mauritius
//
//  Created by Niranjan Ravichandran on 15/01/16.
//  Copyright © 2016 adavers. All rights reserved.
//

import UIKit

class LanguageLabel: UILabel {


    override func drawText(in rect: CGRect) {
        super.drawText(in: UIEdgeInsetsInsetRect(rect, UIEdgeInsetsMake(0, 0, 0, 15)))
    }
}
