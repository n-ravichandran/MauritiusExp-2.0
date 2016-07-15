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
    let userDefaults = UserDefaults.standard()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.languagePicker.delegate = self
        self.languagePicker.dataSource = self
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.languages.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return self.languages[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.languageLabel.text = languages[row]
        userDefaults.set(row + 1, forKey: "currentLanguage")
        
        APP_DEFAULT_LANGUAGE = Language(rawValue: row+1)!
        
        NotificationCenter.default().post(name: Notification.Name(rawValue: "languageChange"), object: nil)
    }
    
}
