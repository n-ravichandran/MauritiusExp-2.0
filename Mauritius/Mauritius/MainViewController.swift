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
    var pid = "ahOcEDJQSr" // default place to be loaded
    var currentObjectId: String? // Current place for view
    var selectedObject: [Beach]? // Beach that is currently viewed

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Setting up collection view
        let layout = UltravisualLayout()
        collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        
        //Registering custom Cell
        self.collectionView.registerNib(UINib(nibName: "ImageCollectionCell", bundle: nil), forCellWithReuseIdentifier: "Cell")
        self.view.addSubview(collectionView)
        collectionView!.decelerationRate = UIScrollViewDecelerationRateFast
        
        if self.revealViewController() != nil {
            self.view.addGestureRecognizer(revealViewController().panGestureRecognizer())
            self.revealViewController().rearViewRevealWidth = 290
            let barButtonItem = UIBarButtonItem(image: UIImage(named: "menu.png"), style: .Plain, target: self.revealViewController(), action: "revealToggle:")
            navigationItem.leftBarButtonItem = barButtonItem

        }
        
        if let id = currentObjectId {
            pid = id
        }
        
        //Load images from parse
        self.getImages()
    }
    
    
    func getImages() {
        ParseFetcher.fetchBeaches(pid) { (result) -> Void in
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
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.collectionView.reloadData()
                })
                if let firstItem = self.beachArray.first {
                    self.selectedObject = self.beachDict[firstItem]
                }
            }
            
        }
    }
    
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return beachDict.count
  }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! ImageCollectionCell
        if let currentItem = beachDict[beachArray[indexPath.item]] {
            let title = currentItem.first?.description
            let index = title!.rangeOfString("-")?.startIndex
            if let value = index {
                cell.cellTitle.text = title?.substringFromIndex(value.successor())
            }else {
                cell.cellTitle.text = currentItem.first?.description
            }
            //Fetch image from parse
            ParseFetcher.fetchImageData((currentItem.first?.imageFile)!, completion: { (result) -> Void in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    cell.currentImage = result
                })
                
            })
        }
        cell.viewMoreButton.addTarget(self, action: "pushPhotosView", forControlEvents: .TouchUpInside)
        return cell
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let layout = self.collectionView.collectionViewLayout as! UltravisualLayout
        let offset = layout.dragOffset * CGFloat(indexPath.item)
        if collectionView.contentOffset.y != offset {
            collectionView.setContentOffset(CGPoint(x: 0, y: offset), animated: true)
        }
        selectedObject = beachDict[beachArray[indexPath.item]]
        
    }
    
    func pushPhotosView() {
        let photosVC = PhotosViewController()
        if let objects = selectedObject {
            photosVC.currentObjects = objects
        }
        self.navigationController?.pushViewController(photosVC, animated: true)
    }

    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return [UIInterfaceOrientationMask.Portrait, .PortraitUpsideDown]
    }

}
