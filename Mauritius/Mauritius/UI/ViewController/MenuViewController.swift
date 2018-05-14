//
//  MenuViewController.swift
//  Mauritius
//
//  Created by Niranjan Ravichandran on 11/25/17.
//  Copyright © 2017 Aviato. All rights reserved.
//

import UIKit

protocol MenuTableCellDelegate {
    func didSelectRow(objectId: String, title: String)
}

class MenuTableCell: UITableViewCell, UITableViewDataSource, UITableViewDelegate {
    
    private var cellIcon: UIImageView!
    var cellLabel: UILabel!
    var subTableView: UITableView?
    var isExpandable = false
    var objectId: String!
    var delegate: MenuTableCellDelegate?
    var data: Category?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = UIColor.mblack
        self.cellIcon = UIImageView(frame: CGRect(x: 12, y: 12.5, width: 25, height: 25))
        self.cellLabel = UILabel(frame: CGRect(x: 48, y: 0, width: self.contentView.frame.width - 30, height: 50))
        self.cellLabel.textColor = UIColor.white
        self.contentView.addSubview(cellIcon)
        self.contentView.addSubview(cellLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        self.cellLabel?.text = nil
        self.cellIcon?.image = UIImage(named: "placeholder")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        self.subTableView?.removeFromSuperview()
        self.subTableView = nil
        self.isExpandable = false
        self.data = nil
        self.selectionStyle = .default
    }
    
    func prepareView(with categroy: Category?) {
        self.data = categroy
        self.cellLabel?.text = categroy?.catgName
        self.cellIcon?.image = UIImage(named: "house")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        self.cellIcon?.tintColor = UIColor.white
        self.objectId = categroy?.objectId
        if (data?.subMenu?.count ?? 0) > 0 {
            self.isExpandable = true
            self.loadSubTable()
        }
    }
    
    func loadSubTable() {
        self.selectionStyle = .none
        let height: CGFloat = CGFloat(self.data?.subMenu?.count ?? 0) * 40
        subTableView = UITableView(frame: CGRect.init(x: 0, y: 50, width: self.frame.width, height: height))
        subTableView?.backgroundColor = UIColor.clear
        subTableView?.dataSource = self
        subTableView?.delegate = self
        subTableView?.separatorStyle = .none
        subTableView?.rowHeight = 40
        subTableView?.isScrollEnabled = false
        self.addSubview(subTableView!)
    }
    
    //MARK: SubTableView
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data?.subMenu?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "subCell")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "subCell")
        }
        cell?.textLabel?.textColor = .white
        cell?.backgroundColor = .clear
        if let name_ = self.data?.subMenu?[indexPath.row].catgName {
            cell?.textLabel?.text = "  " + name_
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let data_ = self.data?.subMenu?[indexPath.row] {
            self.delegate?.didSelectRow(objectId: data_.objectId, title: data_.catgName)
        }
    }
    
    
}

class MenuViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MenuTableCellDelegate {
    
    var tableView: UITableView!
    var categories: [Category]?
    private var cellSize = [String: CGFloat]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.mblack
        tableView = UITableView(frame: self.view.frame)
        tableView.backgroundColor = UIColor.mDarkBlack
        tableView.dataSource = self
        tableView.delegate = self
        tableView.frame.size.width = SlideMenuOptions.leftViewWidth
        tableView.allowsMultipleSelection = false
        tableView.separatorStyle = .none
        tableView.clipsToBounds = true
        self.view.addSubview(tableView)
        
        self.tableView.contentInset = UIEdgeInsetsMake(-20, 0, 0, 0)
        
        //Works only If there is a nav bar
        self.navigationController?.navigationBar.barTintColor = UIColor.mDarkBlack
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        self.fetchMenu()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fetchMenu() {
        APIManager.shared.getMenu { (categories, error) in
            if error == nil {
                
                self.categories = categories?.sorted { $0.position < $1.position }
            
                self.tableView.reloadData()
            }else {
                //Handle error
            }
        }
    }
    
    @objc func openFvorites() {
        self.slideMenuController()?.toggleLeft()
        self.slideMenuController()?.mainViewController?.show(FavoritesViewController(), sender: self)
    }
    
    //MARK: - UITableView
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.categories?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if categories != nil && categories!.count >= 0 {
            return  categories![section].subMenu?.count ?? 0
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: String(describing: MenuTableCell.self)) as? MenuTableCell
        
        if cell == nil {
            cell = MenuTableCell(style: .default, reuseIdentifier: String(describing: MenuTableCell.self))
        }
        cell?.delegate = self
        cell?.prepareView(with: self.categories?[indexPath.section].subMenu?[indexPath.row])
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIControl(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: 60))
        let titleLabel = UILabel(frame: headerView.bounds)
        titleLabel.frame.origin.x = 15
        titleLabel.textColor = UIColor.white
        titleLabel.text = self.categories?[section].catgName
        headerView.backgroundColor = UIColor.mDarkBlack
        headerView.addSubview(titleLabel)
        headerView.addTarget(self, action: #selector(self.openFvorites), for: .touchUpInside)
        return headerView
        
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let data = self.categories?[indexPath.section].subMenu?[indexPath.row] {
            if data.hasChild {
                return (40 * CGFloat(data.subMenu?.count ?? 0)) + 50
            }
        }
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? MenuTableCell {
            tableView.deselectRow(at: indexPath, animated: true)
            if !cell.isExpandable {
                self.toggleView(objectId: cell.objectId, title: cell.cellLabel?.text ?? "")
            }
        }
    }
    
    func didSelectRow(objectId: String, title: String) {
        self.toggleView(objectId: objectId, title: title)
    }
    
    func toggleView(objectId: String, title: String) {
        slideMenuController()?.toggleLeft()
        if let vc = (slideMenuController()?.mainViewController as? UINavigationController)?.viewControllers.first as? MainViewController {
            vc.reloadViewData(with: objectId, title: title)
        }
    }
}
