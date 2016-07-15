//
//  SettingsViewController.swift
//  Mauritius
//
//  Created by Niranjan Ravichandran on 27/12/15.
//  Copyright © 2015 adavers. All rights reserved.
//

import UIKit
import Parse
import UNAlertView

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    @IBOutlet var tableView: UITableView!
    var isPushed: Bool = false
    var cellData: NSMutableArray?
    var isExpanded: Bool = false
    let userDefaults = UserDefaults.standard()
    var isEditable = false
    let aboutContent = "Mauritius Explored is the only app where you can browse through 100+ beautiful beaches, mountain tracks and exotic places and plan your trip. \nThis unique app is designed to showcase Mauritius's best assets and guide you where you want to explore through a live map.\nHave you wondered where are the best beaches in Mauritius, where are the places of interest everyone talks about, do you have a guide? Now you can explore all the beaches around the island and much more, from north to south and everything in between. \nMauritius Explored will be your personal tour guide  without any hidden secrets."
    let version = "Version 2.0"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Settings"
        
        //setting up table view
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.register(UINib(nibName: "SettingsTableViewCell", bundle: nil), forCellReuseIdentifier: "SettingsCell")
        self.tableView.register(UINib(nibName: "LanguageCell", bundle: nil), forCellReuseIdentifier: "LanguageCell")
        
        if !isPushed {
            if self.revealViewController() != nil {
                self.view.addGestureRecognizer(revealViewController().panGestureRecognizer())
                let barButton = UIBarButtonItem(image: UIImage(named: "menu.png"), style: .plain, target: self.revealViewController(), action: #selector(SWRevealViewController.revealToggle(_:)))
                self.navigationItem.leftBarButtonItem = barButton
            }
        }
        //Loading cell data from plist
        self.loadCellData()
        
        let editButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(self.enableEdit(_:)))
        self.navigationItem.rightBarButtonItem = editButton
    }
    
    func loadCellData() {
        if let path = Bundle.main().pathForResource("SettingsPage", ofType: "plist") {
            cellData = NSMutableArray(contentsOfFile: path)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if let data = cellData {
            return data.count
        }else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let data = cellData![section] as? NSDictionary {
            return data["cellItems"]!.count
        }else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let data = cellData![(indexPath as NSIndexPath).section] as? NSDictionary {
            if data["type"] as! Int == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath) as! SettingsTableViewCell
                cell.cellTextField.tag = (indexPath as NSIndexPath).row
                if let cellText = (data["cellItems"] as! NSArray)[(indexPath as NSIndexPath).row] as? String {
                    cell.cellLable.text = cellText
                    cell.cellTextField.placeholder = cellText
                    //populating textfields
                    if cellText == "Full Name" {
                        //Add name from defualts
                    }else if cellText == "Email" {
                        //Add email from defaults
                        if let email = userDefaults.object(forKey: "username") as? String {
                            cell.cellTextField.text = email
                        }
                    }else {
                        //Add phone number from defaults
                    }
                    
                    cell.cellTextField.delegate = self
                    if !isEditable{
                        //Disable user interaction when edit not enabled
                        cell.cellTextField.isUserInteractionEnabled = false
                    }else {
                        //Allow user interaction when edit is enabled
                        cell.cellTextField.isUserInteractionEnabled = true
                    }
                }
                return cell
            } else if data["type"] as! Int == 2 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "LanguageCell", for: indexPath) as! LanguageCell
                //Setting language
                if let lang = userDefaults.object(forKey: "currentLanguage") as? String{
                    //Setting from user prefernece saved
                    cell.languageLabel.text = lang
                } else {
                    //Setting default language
                    cell.languageLabel.text = "\(APP_DEFAULT_LANGUAGE)"
                }
                if isExpanded {
                    cell.languagePicker.alpha = 1
                } else {
                    cell.languagePicker.alpha = 0
                }
                return cell
            } else {
                let cell = UITableViewCell()
                if let cellText = (data["cellItems"] as? NSArray)![(indexPath as NSIndexPath).row] as? String {
                    cell.textLabel?.text = cellText
                    cell.accessoryType = .disclosureIndicator
                }
                return cell
            }
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let data = cellData![(indexPath as NSIndexPath).section] as? NSDictionary {
            if data["type"] as! Int == 2 {
                if isExpanded {
                    isExpanded = false
                }else {
                    isExpanded = true
                }
                tableView.reloadRows(at: [indexPath], with: .fade)
            }
        }
        if (indexPath as NSIndexPath).section == 2 {
            let alert = UNAlertView(title: version, message: aboutContent)
            alert.addButton("Dismiss", backgroundColor: UIColor(red: 55/255, green: 55/255, blue: 55/255, alpha: 1.0), action: {
                //Deselect tableViewCell
                tableView.deselectRow(at: indexPath, animated: true)
            })
            alert.show()
            
        }else if (indexPath as NSIndexPath).section == 3 {
            let alert = UNAlertView(title: "mailTo:", message: "info@planetexplored.com")
            alert.addButton("Dismiss", backgroundColor: UIColor(red: 55/255, green: 55/255, blue: 55/255, alpha: 1.0), action: {
                //Deselect tableViewCell
                tableView.deselectRow(at: indexPath, animated: true)
                
            })
            alert.show()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var cellHeight: CGFloat = 44
        if let data = cellData![(indexPath as NSIndexPath).section] as? NSDictionary {
            if data["type"] as! Int == 2 {
                if self.isExpanded {
                    //Height for expanded cell
                    cellHeight = 240
                }else {
                    //Height for closed cell
                    cellHeight = 44
                }
            }
        }
        return cellHeight
    }
    
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        if let data = cellData {
            if section == data.count - 1 {
                let footerView = UITableViewHeaderFooterView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 55))
                let contentLabel = UILabel(frame: footerView.bounds)
                contentLabel.center = footerView.center
                contentLabel.font = UIFont(name: "Helvetica", size: 13)
                contentLabel.textAlignment = NSTextAlignment.center
                
                let footerText = "Designed and Developed by Niranjan Ravichandran" as NSString
                contentLabel.textColor = UIColor.lightGray()
                //Creating attributed String
                let attributedText = NSMutableAttributedString(string: footerText as String)
                attributedText.addAttributes([NSUnderlineStyleAttributeName: 1], range: footerText.range(of: "Niranjan Ravichandran"))
                attributedText.addAttributes([NSForegroundColorAttributeName: UIColor.gray()], range: footerText.range(of: "Niranjan Ravichandran"))
                contentLabel.attributedText = attributedText
                
                footerView.addSubview(contentLabel)
                contentLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.openInSafari)))
                contentLabel.isUserInteractionEnabled = true
                return footerView
            }else {
                return nil
            }
        }else {
            return nil
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if let data = cellData {
            if section == data.count - 1 {
                return 55
            }else {
                return 0
            }
        }else {
            return 0
        }
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        var name: String?
        var email: String?
        var phone: String?
        switch textField.tag {
        case 0:
            if let _ = textField.text {
                name = textField.text!
            }
        case 1:
            if let _ = textField.text {
                email = textField.text!
            }
        case 2:
            if let _ = textField.text {
                phone = textField.text!
            }
            
        default:
            print("Handle textfield with no tags")
        }
        
        if email != nil {
            
            ParseFetcher.sharedInstance.checkUser(email!) { (userExists) in
                if userExists {
                    self.userDefaults.set(email, forKey: "username")
                }else {
                    //Signup User
                    self.signUpUser(email!, name: name, phone: phone)
                }
            }
        }
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        self.tableView.endEditing(true)
        
    }
    
    func enableEdit(_ sender: UIBarButtonItem) {
        if !isEditable {
            isEditable = true
            sender.title = "Save"
            tableView.reloadData()
        }else {
            isEditable = false
            sender.title = "Edit"
            self.tableView.endEditing(true)
        }
    }
    
    func openInSafari() {
        let url = URL(string: "http://nravichan.paperplane.io")
        UIApplication.shared().openURL(url!)
    }
    
    //Sign up new user
    func signUpUser(_ email: String, name: String?, phone: String?) {
        let newUser = PFUser()
        newUser.email = email
        newUser.username = email
        newUser.password = "password"
        if let _ = name {
            newUser.setObject(name!, forKey: "Name")
        }
        
        if let _ = phone {
            newUser.setObject(phone!, forKey: "Phone")
        }
        
        ParseFetcher.sharedInstance.createUser(newUser, completion: { (status) in
            if status{
                //Persist user email after signup
                self.userDefaults.set(newUser.email, forKey: "username")
            }
        })
    }
    
}
