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
        self.navigationController?.isNavigationBarHidden = false
        self.tableView.separatorStyle = .none
        
        //Registering custom cell
        self.tableView.register(UINib(nibName: "MenuTableCell", bundle: nil), forCellReuseIdentifier: "MenuCell")
        self.tableView.backgroundColor = UIColor(red: 45/255, green: 47/255, blue: 51/255, alpha: 1.0)
        
        if self.revealViewController() != nil {
            self.view.addGestureRecognizer(revealViewController().panGestureRecognizer())
            self.revealViewController().rearViewRevealWidth = 290
            let barButtonItem = UIBarButtonItem(image: UIImage(named: "menu.png"), style: .plain, target: (self.revealViewController()).revealViewController(), action: #selector(SWRevealViewController.revealToggle(_:)))
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
                self.categories = result.sorted(isOrderedBefore: {$0.position < $1.position})
                self.tableView.reloadData()
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if categories != nil {
            return categories!.count
        }else {
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuCell", for: indexPath) as! MenuTableCell
        
        if categories != nil {
            cell.menuLabel.text = categories![(indexPath as NSIndexPath).row].name
            
            switch APP_DEFAULT_LANGUAGE {
            case .english:
                cell.menuLabel.text = categories![(indexPath as NSIndexPath).row].name
            case .chinese:
                cell.menuLabel.text = categories![(indexPath as NSIndexPath).row].chinese
            case .italian:
                cell.menuLabel.text = categories![(indexPath as NSIndexPath).row].italian
            case .german:
                cell.menuLabel.text = categories![(indexPath as NSIndexPath).row].german
            case .french:
                cell.menuLabel.text = categories![(indexPath as NSIndexPath).row].french
            }

            if let iconName = categories![(indexPath as NSIndexPath).row].iconName {
                
                cell.menuIcon.image = UIImage(named: iconName)?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
                cell.menuIcon.tintColor = UIColor.gray()
            }
        }
        cell.backgroundColor = UIColor(red: 45/255, green: 47/255, blue: 50/255, alpha: 1.0)
        return cell
    }

    // MARK: - Table view data delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedCell = tableView.cellForRow(at: indexPath) as? MenuTableCell
        selectedCell?.backgroundColor = UIColor(red: 255/255, green: 66/255, blue: 70/255, alpha: 1.0)
        selectedCell?.menuIcon.tintColor = UIColor.white()
        
        var newFrontViewController: UINavigationController?
        let mainVC = MainViewController()
        mainVC.currentObjectId = categories![(indexPath as NSIndexPath).row].objectId
        mainVC.newTitle = categories![(indexPath as NSIndexPath).row].name
        newFrontViewController = UINavigationController(rootViewController: mainVC)
        revealViewController().pushFrontViewController(newFrontViewController, animated: true)
    }

    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let deselectedCell = tableView.cellForRow(at: indexPath) as? MenuTableCell
        deselectedCell?.backgroundColor = UIColor(red: 45/255, green: 47/255, blue: 50/255, alpha: 1.0)
        deselectedCell?.menuIcon.tintColor = UIColor.gray()
    }
}
