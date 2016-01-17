//
//  SettingsTableViewCell.swift
//  Mauritius
//
//  Created by Niranjan Ravichandran on 28/12/15.
//  Copyright © 2015 adavers. All rights reserved.
//

import UIKit

class SettingsTableViewCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet var cellLable: UILabel!
    @IBOutlet var cellTextField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let paddingView = UIView(frame: CGRectMake(0, 0, 15, self.cellTextField.frame.height))
        self.cellTextField.rightView = paddingView
        self.cellTextField.rightViewMode = UITextFieldViewMode.Always
        self.cellTextField.delegate = self
        self.selectionStyle = .None
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
