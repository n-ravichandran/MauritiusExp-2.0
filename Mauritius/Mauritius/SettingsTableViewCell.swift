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
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: self.cellTextField.frame.height))
        self.cellTextField.rightView = paddingView
        self.cellTextField.rightViewMode = UITextFieldViewMode.always
        self.cellTextField.delegate = self
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
