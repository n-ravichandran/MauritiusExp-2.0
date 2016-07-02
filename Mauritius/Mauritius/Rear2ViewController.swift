//
//  Rear2ViewController.swift
//  Mauritius
//
//  Created by Niranjan Ravichandran on 29/06/16.
//  Copyright © 2016 adavers. All rights reserved.
//

import UIKit

class Rear2ViewController: UITableViewController {
    
    var categories: [Category]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Beaches"
        self.clearsSelectionOnViewWillAppear = false
        self.navigationController?.navigationBarHidden = false
        self.tableView.separatorStyle = .None
        
        //Registering custom cell
        self.tableView.registerNib(UINib(nibName: "MenuTableCell", bundle: nil), forCellReuseIdentifier: "MenuCell")
        self.tableView.backgroundColor = UIColor(red: 45/255, green: 47/255, blue: 51/255, alpha: 1.0)
        
        if self.revealViewController() != nil {
            self.view.addGestureRecognizer(revealViewController().panGestureRecognizer())
            self.revealViewController().rearViewRevealWidth = 290
            let barButtonItem = UIBarButtonItem(image: UIImage(named: "menu.png"), style: .Plain, target: (self.revealViewController()).revealViewController(), action: #selector(SWRevealViewController.revealToggle(_:)))
            navigationItem.leftBarButtonItem = barButtonItem
            
        }
        
        self.getCategories()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getCategories() {
        ParseFetcher.sharedInstance.fetchCategories([3]) { (result, count1) in
            if result.count > 0 {
                self.categories = result.sort({$0.position < $1.position})
                self.tableView.reloadData()
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if categories != nil {
            return categories!.count
        }else {
            return 0
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MenuCell", forIndexPath: indexPath) as! MenuTableCell
        
        if categories != nil {
            cell.menuLabel.text = categories![indexPath.row].name
            
            switch APP_DEFAULT_LANGUAGE {
            case .English:
                cell.menuLabel.text = categories![indexPath.row].name
            case .Chinese:
                cell.menuLabel.text = categories![indexPath.row].chinese
            case .Italian:
                cell.menuLabel.text = categories![indexPath.row].italian
            case .German:
                cell.menuLabel.text = categories![indexPath.row].german
            case .French:
                cell.menuLabel.text = categories![indexPath.row].french
            }

            if let iconName = categories![indexPath.row].iconName {
                
                cell.menuIcon.image = UIImage(named: iconName)?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
                cell.menuIcon.tintColor = UIColor.grayColor()
            }
        }
        cell.backgroundColor = UIColor(red: 45/255, green: 47/255, blue: 50/255, alpha: 1.0)
        return cell
    }

    // MARK: - Table view data delegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let selectedCell = tableView.cellForRowAtIndexPath(indexPath) as? MenuTableCell
        selectedCell?.backgroundColor = UIColor(red: 255/255, green: 66/255, blue: 70/255, alpha: 1.0)
        selectedCell?.menuIcon.tintColor = UIColor.whiteColor()
        
        var newFrontViewController: UINavigationController?
        let mainVC = MainViewController()
        mainVC.currentObjectId = categories![indexPath.row].objectId
        mainVC.newTitle = categories![indexPath.row].name
        newFrontViewController = UINavigationController(rootViewController: mainVC)
        revealViewController().pushFrontViewController(newFrontViewController, animated: true)
    }

    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        let deselectedCell = tableView.cellForRowAtIndexPath(indexPath) as? MenuTableCell
        deselectedCell?.backgroundColor = UIColor(red: 45/255, green: 47/255, blue: 50/255, alpha: 1.0)
        deselectedCell?.menuIcon.tintColor = UIColor.grayColor()
    }
}
