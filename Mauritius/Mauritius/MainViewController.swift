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
    var pid = "ahOcEDJQSr"

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
        }
        
        self.getImages()
    }
    
    
    func getImages() {
        ParseFetcher.fetchBeaches(pid) { (result) -> Void in
            print(result.count)
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
                self.collectionView.reloadData()
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
                cell.currentImage = result
            })
        }
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
    }

    

}
