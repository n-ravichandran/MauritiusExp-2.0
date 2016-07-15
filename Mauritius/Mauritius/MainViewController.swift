//
//  MainViewController.swift
//  Mauritius
//
//  Created by Niranjan Ravichandran on 21/12/15.
//  Copyright © 2015 adavers. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    var beachDict = [String: [Beach]]()
    var beachArray = [String]()
    
    var collectionView: UICollectionView!
    var pid = "wic0lLoZcs" // default place to be loaded
    var currentObjectId: String? // Current place for view
    var selectedObject: [Beach]? // Beach that is currently viewed
    var newTitle: String? //Title for view controller

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Setting up collection view
        let layout = UltravisualLayout()
        collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.contentInset = UIEdgeInsets(top: 55, left: 0, bottom: 0, right: 0)
        
        //Registering custom Cell
        self.collectionView.register(UINib(nibName: "ImageCollectionCell", bundle: nil), forCellWithReuseIdentifier: "Cell")
        self.view.addSubview(collectionView)
        collectionView!.decelerationRate = UIScrollViewDecelerationRateFast
        
        if self.revealViewController() != nil {
            self.view.addGestureRecognizer(revealViewController().panGestureRecognizer())
            self.revealViewController().rearViewRevealWidth = 290
            let barButtonItem = UIBarButtonItem(image: UIImage(named: "menu.png"), style: .plain, target: self.revealViewController(), action: #selector(SWRevealViewController.revealToggle(_:)))
            navigationItem.leftBarButtonItem = barButtonItem

        }
        
        //Title for view controller
//        if let str = newTitle {
//            self.title = str
//        }else {
//            self.title = "Beaches"
//        }
        
        if let id = currentObjectId {
            pid = id
        }
        
        if pid == " " {
            self.errorMessageView()
        }else {
            //Load images from parse
            if Reachability.isConnectedToNetwork() {
                self.getImages()
            }else {
                Reachability.networkErrorView(self.view)
            }
        }
        
    }
    
    
    func getImages() {
        ParseFetcher.sharedInstance.fetchBeaches(pid) { (result) -> Void in
            if result.count > 0 {
                for item in result {
                    if var existingArray = self.beachDict[item.linkId!] {
                        existingArray.append(item)
                        self.beachDict[item.linkId!] = existingArray
                    } else {
                        let newArray: [Beach] = [item]
                        self.beachDict[item.linkId!] = newArray
                        self.beachArray.append(item.linkId!)
                    }
                }
                DispatchQueue.main.async(execute: { () -> Void in
                    self.collectionView.reloadData()
                })
                if let firstItem = self.beachArray.first {
                    self.selectedObject = self.beachDict[firstItem]
                }
            }
            
        }
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return beachDict.count
  }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ImageCollectionCell
        if let currentItem = beachDict[beachArray[(indexPath as NSIndexPath).item]] {
            //Setting title for the images from description
            //All this mess up due to junk sent from server
            let title = currentItem.first?.description
            if let index = title?.range(of: "-")?.lowerBound {
                if let value = title?.index(after: index) {
                    cell.cellTitle.text = title?.substring(from: value)
                }else {
                    cell.cellTitle.text = currentItem.first?.description
                }
            }
            
            //Fetch image from parse
            if let imageFile = currentItem.first?.imageFile {
                imageFile.getDataInBackground({ (imageData, error) -> Void in
                    if error == nil {
                        if let result = imageData {
                            DispatchQueue.main.async {
                                cell.currentImage = result
                            }
                        }
                    }
                })
            }
        }
        return cell
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            
            let layout = self.collectionView.collectionViewLayout as! UltravisualLayout
            let offset = layout.dragOffset * CGFloat((indexPath as NSIndexPath).item)
            if collectionView.contentOffset.y != offset {
                collectionView.setContentOffset(CGPoint(x: 0, y: offset), animated: true)
            }
            self.selectedObject = self.beachDict[self.beachArray[(indexPath as NSIndexPath).item]]
            
            }) { (isComplete) -> Void in
                if isComplete {
                    //Push Detailed view
                    let photosVC = PhotosViewController()
                    if let objects = self.selectedObject {
                        photosVC.currentObjects = objects
                    }
                    self.navigationController?.pushViewController(photosVC, animated: true)
                }
        }
        
    }


    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return [UIInterfaceOrientationMask.portrait, .portraitUpsideDown]
    }
    
    func errorMessageView() {
        let messageView = UIView(frame: UIScreen.main().bounds)
        messageView.backgroundColor = UIColor(red: 234/255, green: 234/255, blue: 234/255, alpha: 1.0)
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main().bounds.width, height: 25))
        messageLabel.center = messageView.center
        messageLabel.font = UIFont(name: "Helvetica", size: 18)
        messageLabel.text = "Coming Soon... Stay Tuned!"
        messageLabel.textColor = UIColor.darkGray()
        messageLabel.textAlignment = .center
        let icon = UIImageView(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        icon.image = UIImage(named: "coming_soon.png")
        icon.center.x = messageView.center.x
        icon.center.y = messageView.center.y - 60
        messageView.addSubview(icon)
        messageView.addSubview(messageLabel)
        self.view.addSubview(messageView)
        
    }
    
    //Try again action for network error
    func tryAgainAction() {
        for subview in self.view.subviews{
            if subview.tag == 100{
                subview.removeFromSuperview()
                self.viewDidLoad()
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        collectionView.frame.size.width = UIScreen.main().bounds.width
    }

}
