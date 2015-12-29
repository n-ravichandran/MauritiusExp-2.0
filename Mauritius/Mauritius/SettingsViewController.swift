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
    
    let cellData: [String] = ["First Name", "Last Name", "Email", "Phone"]
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Settings"
        
        //setting up table view
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.registerNib(UINib(nibName: "SettingsTableViewCell", bundle: nil), forCellReuseIdentifier: "SettingsCell")
        
        if !isPushed {
            if self.revealViewController() != nil {
                self.view.addGestureRecognizer(revealViewController().panGestureRecognizer())
                let barButton = UIBarButtonItem(image: UIImage(named: "menu.png"), style: .Plain, target: self.revealViewController(), action: "revealToggle:")
                self.navigationItem.leftBarButtonItem = barButton
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return cellData.count
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SettingsCell", forIndexPath: indexPath) as! SettingsTableViewCell
        cell.cellLable.text = cellData[indexPath.row]
        cell.cellTextField.tag = indexPath.row
        cell.cellTextField.placeholder = cellData[indexPath.row]
        cell.selectionStyle = .None
        return cell
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        self.tableView.endEditing(true)
    }

}
