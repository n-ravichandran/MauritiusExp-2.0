//
//  SettingsViewController.swift
//  Mauritius
//
//  Created by Niranjan Ravichandran on 27/12/15.
//  Copyright © 2015 adavers. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var tableView: UITableView!
    var isPushed: Bool = false
    var cellData: NSMutableArray?
    var isExpanded: Bool = false
    let userDefaults = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Settings"
        
        //setting up table view
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.registerNib(UINib(nibName: "SettingsTableViewCell", bundle: nil), forCellReuseIdentifier: "SettingsCell")
        self.tableView.registerNib(UINib(nibName: "LanguageCell", bundle: nil), forCellReuseIdentifier: "LanguageCell")
        
        if !isPushed {
            if self.revealViewController() != nil {
                self.view.addGestureRecognizer(revealViewController().panGestureRecognizer())
                let barButton = UIBarButtonItem(image: UIImage(named: "menu.png"), style: .Plain, target: self.revealViewController(), action: "revealToggle:")
                self.navigationItem.leftBarButtonItem = barButton
            }
        }
        //Loading cell data from plist
        self.loadCellData()
        
    }
    
    func loadCellData() {
        if let path = NSBundle.mainBundle().pathForResource("SettingsPage", ofType: "plist") {
            cellData = NSMutableArray(contentsOfFile: path)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if let data = cellData {
            return data.count
        }else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let data = cellData![section] as? NSDictionary {
           return data["cellItems"]!.count
        }else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let data = cellData![indexPath.section] as? NSDictionary {
            if data["type"] as! Int == 0 {
                let cell = tableView.dequeueReusableCellWithIdentifier("SettingsCell", forIndexPath: indexPath) as! SettingsTableViewCell
                cell.cellTextField.tag = indexPath.row
                if let cellText = data["cellItems"]![indexPath.row] as? String {
                    cell.cellLable.text = cellText
                    cell.cellTextField.placeholder = cellText
                }
                return cell
            } else if data["type"] as! Int == 2 {
                let cell = tableView.dequeueReusableCellWithIdentifier("LanguageCell", forIndexPath: indexPath) as! LanguageCell
                //Setting language
                if let lang = userDefaults.objectForKey("currentLanguage") as? String{
                    //Setting from user prefernece saved
                    cell.languageLabel.text = lang
                } else {
                    //Setting default language
                    cell.languageLabel.text = "English"
                }
                if isExpanded {
                    cell.languagePicker.alpha = 1
                } else {
                    cell.languagePicker.alpha = 0
                }
                return cell
            } else {
                let cell = UITableViewCell()
                if let cellText = data["cellItems"]![indexPath.row] as? String {
                    cell.textLabel?.text = cellText
                    cell.accessoryType = .DisclosureIndicator
                }
                return cell
            }
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let data = cellData![indexPath.section] as? NSDictionary {
            if data["type"] as! Int == 2 {
                if isExpanded {
                    isExpanded = false
                }else {
                    isExpanded = true
                }
                tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            }
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if let data = cellData![indexPath.section] as? NSDictionary {
            if data["type"] as! Int == 2 {
                if self.isExpanded {
                    //Height for expanded cell
                    return 240
                }else {
                    //Height for closed cell
                    return 44
                }
            } else {
                //Height for other cells
                return 44
            }
        } else {
            return 44
        }

    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        self.tableView.endEditing(true)
    }

}
