//
//  FavsViewController.swift
//  MauritiusAttraction
//
//  Created by Niranjan Ravichandran on 23/04/16.
//  Copyright © 2016 adavers. All rights reserved.
//

import UIKit
import SKPhotoBrowser

class FavsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIViewControllerPreviewingDelegate, SKPhotoBrowserDelegate {
    
    var collectionView: UICollectionView?
    var favs: [String]?
    var imageData = [Int: NSData]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //View title
        self.title = "Favorites"
        self.view.backgroundColor = UIColor.whiteColor()
        self.fetchFavs { (favsLoaded) in
            if favsLoaded {
                //Setting up collection view
                let layout = UICollectionViewFlowLayout()
                layout.minimumInteritemSpacing = 2
                layout.minimumLineSpacing = 2
                layout.sectionInset = UIEdgeInsets(top: 67, left: 2, bottom: 10, right: 2)
                self.collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
                self.collectionView?.delegate = self
                self.collectionView?.dataSource = self
                self.collectionView?.backgroundColor = UIColor.whiteColor()
                self.collectionView?.registerNib(UINib(nibName: "FavsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "FavsCollectionCell")
                self.view.addSubview(self.collectionView!)
                
                //Register for 3D touch if available
                if #available(iOS 9.0, *) {
                    if self.traitCollection.forceTouchCapability == .Available {
                        self.registerForPreviewingWithDelegate(self, sourceView: self.collectionView!)
                    }
                } else {
                    // Fallback on earlier versions
                }
                
            }else {
                self.errorMessageView()
            }
        }
        
        //Burger menu button
        if self.revealViewController() != nil {
            if collectionView != nil {
                self.collectionView?.addGestureRecognizer(revealViewController().panGestureRecognizer())
            }else {
                self.view.addGestureRecognizer(revealViewController().panGestureRecognizer())
            }
            let menuButton = UIBarButtonItem(image: UIImage(named: "menu.png"), style: .Plain, target: self.revealViewController(), action: #selector(SWRevealViewController.revealToggle(_:)))
            self.navigationItem.leftBarButtonItem = menuButton
        }

    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let _ = favs {
           return favs!.count
        }else{
            return 4
        }
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("FavsCollectionCell", forIndexPath: indexPath) as! FavsCollectionViewCell
        if favs?.count > 0 {
            if let id = favs?[indexPath.row] {
                ParseFetcher.sharedInstance.getObjectByID(id, className: "Beaches", completion: { (status, rseponse) in
                    if status {
                        rseponse.imageFile?.getDataInBackgroundWithBlock({ (imageData, fetchError) in
                            if let _ = imageData {
                                cell.cellImageView.image = UIImage(data: imageData!)
                                //Adding imagefile url
                                self.imageData[indexPath.row] = imageData!
                            }
                        })
                    }
                })
            }
        }
        return cell
    }
    
    //Collection view cell size
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let size: CGFloat = (UIScreen.mainScreen().bounds.width - 10)/4
        return CGSizeMake(size, size)
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        //Trigger only when not a force touch
            let cell = collectionView.cellForItemAtIndexPath(indexPath) as! FavsCollectionViewCell
            let originImage = cell.cellImageView.image
            //Presenting photo browser
            let browser = self.createPhotoBrowser(originImage!, cellIndex: indexPath.row, cellView: cell)
            if let _ = browser {
                presentViewController(browser!, animated: true, completion: {})
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createPhotoBrowser(originImage: UIImage, cellIndex: Int, cellView: UIView) -> UIViewController? {
        if imageData.count > 0 {
            //Preparig for image browser view
            var images = [AnyObject]()
            //creatig array of SKphoto
            for i in 0..<imageData.count {
                images.append(SKPhoto.photoWithImage(UIImage(data: imageData[i]!)!))
            }
            //Creating browser object
            let browser = SKPhotoBrowser(originImage: originImage, photos: images, animatedFromView: cellView)
            browser.statusBarStyle = UIStatusBarStyle.LightContent
            browser.initializePageIndex(cellIndex)
            browser.delegate = self
            return browser
        }else {
            return nil
        }
    }
    
    func fetchFavs(completion: (favsLoaded: Bool) -> Void) {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if let email = userDefaults.objectForKey("username") as? String {
            ParseFetcher.sharedInstance.getFavorites(email, completion: { (favroites) in
                if favroites != nil {
                    if let favs = favroites?.first?["ImageId"] as? [String] {
                        self.favs = favs
                        completion(favsLoaded: true)
                    }
                }else {
                    completion(favsLoaded: false)
                }
            })
        }else {
            completion(favsLoaded: false)
        }
    }
    
    
    override func viewDidLayoutSubviews() {
        if collectionView != nil {
            collectionView?.frame.size.width = UIScreen.mainScreen().bounds.width
        }
    }
    
    func didDismissAtPageIndex(index: Int) {
        collectionView?.reloadInputViews()
    }
    
    //Rendering Error view
    func errorMessageView() {
        let messageView = UIView(frame: UIScreen.mainScreen().bounds)
        messageView.backgroundColor = UIColor(red: 234/255, green: 234/255, blue: 234/255, alpha: 1.0)
        let messageLabel = UILabel(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, 21))
        messageLabel.center = messageView.center
        messageLabel.text = "You do not have any favourites yet!"
        messageLabel.textColor = UIColor.darkGrayColor()
        messageLabel.textAlignment = .Center
        messageLabel.numberOfLines = 0
        messageLabel.lineBreakMode = .ByWordWrapping
        let icon = UIImageView(frame: CGRectMake(0, 0, 45, 45))
        icon.image = UIImage(named: "like-filled.png")
        icon.center.x = messageView.center.x
        icon.center.y = messageView.center.y - 40
        messageView.addSubview(icon)
        messageView.addSubview(messageLabel)
        
        self.view.addSubview(messageView)
        
    }
    
    //MARK: - 3D touch implementation
    func previewingContext(previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        if collectionView != nil {
            guard let indexPath = collectionView?.indexPathForItemAtPoint(location) else {
                return nil
            }
            
            guard let cell = collectionView?.cellForItemAtIndexPath(indexPath) as? FavsCollectionViewCell else {
                return nil
            }
            let browser = self.createPhotoBrowser(cell.cellImageView.image!, cellIndex: indexPath.row, cellView: cell)
            browser?.preferredContentSize = CGSize(width: 0.0, height: 400)
            if #available(iOS 9.0, *) {
                previewingContext.sourceRect = cell.frame
            } else {
                // Fallback on earlier versions
            }
            return browser
        }else {
            return nil
        }
    }
    
    func previewingContext(previewingContext: UIViewControllerPreviewing, commitViewController viewControllerToCommit: UIViewController) {
        //showViewController(viewControllerToCommit, sender: self)
        presentViewController(viewControllerToCommit, animated: true, completion: nil)
    }

}
