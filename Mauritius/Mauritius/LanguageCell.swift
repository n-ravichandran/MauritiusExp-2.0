//
//  LanguageCell.swift
//  Mauritius
//
//  Created by Niranjan Ravichandran on 15/01/16.
//  Copyright © 2016 adavers. All rights reserved.
//

import UIKit

class LanguageCell: UITableViewCell, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet var languageLabel: LanguageLabel!
    @IBOutlet var languagePicker: UIPickerView!
    
    let languages: [String] = ["Chinese", "English", "French", "German", "Italian"]
    let userDefaults = NSUserDefaults.standardUserDefaults()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.languagePicker.delegate = self
        self.languagePicker.dataSource = self
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.languages.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return self.languages[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.languageLabel.text = languages[row]
        userDefaults.setObject(languages[row], forKey: "currentLanguage")
    }
    
}
