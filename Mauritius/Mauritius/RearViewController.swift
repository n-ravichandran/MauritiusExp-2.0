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
        self.navigationController?.navigationBarHidden = false
        self.title = "Mauritius Explored"
        self.tableView.separatorStyle = .None
        //Registering custom cell
        self.tableView.registerNib(UINib(nibName: "MenuTableCell", bundle: nil), forCellReuseIdentifier: "MenuCell")
        
        self.getCategories()
    }
    
    //Fetching level one and level two menu items
    func getCategories() {
        var levelOneObjects = [String]()
        ParseFetcher.sharedInstance.fetchCategories([1, 2]) { (result, count1) -> Void in
            if result.count > 0 {
                self.categories = result
                self.levelOne = [Category](count: count1, repeatedValue: Category())
                
                for item in self.categories! {
                    if item.level == 1 {
                        if let position = item.position{
                            self.levelOne[position-1] = item
                        }
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
            //Reordering the level two menu based on position
            for (key, item) in self.levelTwo {
                let sortedArray = item.sort({$0.position < $1.position})
                self.levelTwo[key] = sortedArray
            }
            self.tableView.reloadData()
        }
        //Adding language change notification observer
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.languageChange), name: "languageChange", object: nil)
    }
    
    func languageChange() {
        self.tableView.reloadData()
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {

        return levelOne.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if levelOne[section].isAvailable {
            if let objects = levelTwo[levelOne[section].objectId!]{
                return objects.count
            }else {
                return 0
            }
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
        if header.textLabel?.text == "Favourites" {
            header.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(RearViewController.favouritesPage)))
        }else if header.textLabel?.text == "Settings"{
            header.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(RearViewController.settingsPage)))
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MenuCell", forIndexPath: indexPath) as! MenuTableCell
        let objects = levelTwo[levelOne[indexPath.section].objectId!]
        cell.menuLabel.text = objects![indexPath.row].name
        
        switch APP_DEFAULT_LANGUAGE {
            case .English:
                cell.menuLabel.text = objects![indexPath.row].name
            case .Chinese:
                cell.menuLabel.text = objects![indexPath.row].chinese
            case .Italian:
                cell.menuLabel.text = objects![indexPath.row].italian
            case .German:
                cell.menuLabel.text = objects![indexPath.row].german
            case .French:
                cell.menuLabel.text = objects![indexPath.row].french
        }
        
        if let iconName = objects![indexPath.row].iconName {
            cell.menuIcon.image = UIImage(named: iconName)?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
            cell.menuIcon.tintColor = UIColor.grayColor()
        }
        cell.backgroundColor = UIColor(red: 45/255, green: 47/255, blue: 50/255, alpha: 1.0)

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedCell = tableView.cellForRowAtIndexPath(indexPath) as? MenuTableCell
        selectedCell?.backgroundColor = UIColor(red: 255/255, green: 66/255, blue: 70/255, alpha: 1.0)
        selectedCell?.menuIcon.tintColor = UIColor.whiteColor()
        
        var newFrontViewController: UINavigationController?
        let mainVC = MainViewController()
        if ((indexPath.section == 0) && (indexPath.row == 0)) {
            mainVC.title = "Beaches"
            let frontVC = UINavigationController(rootViewController: mainVC)
            let rearVC = UINavigationController(rootViewController: Rear2ViewController())
            let childVC = SWRevealViewController(rearViewController: rearVC, frontViewController: frontVC)
            childVC.rearViewRevealDisplacement = 20
            childVC.setFrontViewPosition(FrontViewPosition.Right, animated: true)
            revealViewController().pushFrontViewController(childVC, animated: true)
        }else {
            if let objects = levelTwo[levelOne[indexPath.section].objectId!] {
                mainVC.currentObjectId = objects[indexPath.row].objectId
                mainVC.newTitle = objects[indexPath.row].name
                newFrontViewController = UINavigationController(rootViewController: mainVC)
                revealViewController().pushFrontViewController(newFrontViewController, animated: true)
            }
        }
        
    }
    
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        let deselectedCell = tableView.cellForRowAtIndexPath(indexPath) as? MenuTableCell
        deselectedCell?.backgroundColor = UIColor(red: 45/255, green: 47/255, blue: 50/255, alpha: 1.0)
        deselectedCell?.menuIcon.tintColor = UIColor.grayColor()
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
        let favsVC = FavsViewController()
        let newFrontViewController = UINavigationController(rootViewController: favsVC)
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
