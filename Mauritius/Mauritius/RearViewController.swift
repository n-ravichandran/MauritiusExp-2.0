//
//  RearViewController.swift
//  Mauritius
//
//  Created by Niranjan Ravichandran on 20/12/15.
//  Copyright © 2015 adavers. All rights reserved.
//

import UIKit

class RearViewController: UITableViewController {
    
    var categories: [Category]?
    var levelOne = [Category]()
    var levelTwo = [String : [Category]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.clearsSelectionOnViewWillAppear = false
        self.navigationController?.navigationBarHidden = true
        self.tableView.separatorStyle = .None
        
        //Registering custom cell
        self.tableView.registerNib(UINib(nibName: "MenuTableCell", bundle: nil), forCellReuseIdentifier: "MenuCell")
        
        self.getCategories()
    }
    
    //Fetching level one and two menu items
    func getCategories() {
        var levelOneObjects = [String]()
        ParseFetcher.fetchCategories([1, 2]) { (result) -> Void in
            if result.count > 0 {
                self.categories = result
                
                for item in self.categories! {
                    if item.level == 1 {
                        self.levelOne.append(item)
                        levelOneObjects.append(item.objectId!)
                    }
                }
                
                for item in self.categories! {
                    if levelOneObjects.contains(item.parentID!) {
                        if var existingArray = self.levelTwo[item.parentID!] {
                            existingArray.append(item)
                            self.levelTwo[item.parentID!] = existingArray
                        }else {
                            let newArray: [Category] = [item]
                            self.levelTwo[item.parentID!] = newArray
                        }
                    }
                }
                
            }
            self.tableView.reloadData()
        }
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return levelOne.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let objects = levelTwo[levelOne[section].objectId!] {
            return objects.count
        }else {
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return levelOne[section].name
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        let header = view as! UITableViewHeaderFooterView
        header.contentView.backgroundColor = UIColor(red: 38/255, green: 40/255, blue: 43/255, alpha: 1.0)
        header.textLabel?.textColor = UIColor.whiteColor()
        header.textLabel?.font = UIFont(name: "HelveticaNeue", size: (header.textLabel?.font?.pointSize)!)
        if section == 2 {
            header.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "favouritesPage"))
        }else if section == 3 {
            header.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "settingsPage"))
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MenuCell", forIndexPath: indexPath) as! MenuTableCell
        let objects = levelTwo[levelOne[indexPath.section].objectId!]
        cell.menuLabel.text = objects![indexPath.row].name
        cell.menuIcon.image = UIImage(named: objects![indexPath.row].iconName!)
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var newFrontViewController: UINavigationController?
        let mainVC = MainViewController()
        if ((indexPath.section == 0) && (indexPath.row == 0)) {
            
        }else {
            let objects = levelTwo[levelOne[indexPath.section].objectId!]
            mainVC.currentObjectId = objects![indexPath.row].objectId
            newFrontViewController = UINavigationController(rootViewController: mainVC)
            revealViewController().pushFrontViewController(newFrontViewController, animated: true)
        }
        
        
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return [UIInterfaceOrientationMask.Portrait, .PortraitUpsideDown]
    }
    
    //Settings Page
    func settingsPage() {
        
        let settingsVC = SettingsViewController()
        revealViewController().pushFrontViewController(UINavigationController(rootViewController: settingsVC), animated: true)
    }
    
    //Favourites page
    func favouritesPage() {
        let mainVC = MainViewController()
        mainVC.title = "Favourites"
        mainVC.currentObjectId = " "
        let newFrontViewController = UINavigationController(rootViewController: mainVC)
        revealViewController().pushFrontViewController(newFrontViewController, animated: true)
    }

    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
}
