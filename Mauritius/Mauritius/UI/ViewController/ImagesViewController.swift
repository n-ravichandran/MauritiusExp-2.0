//
//  ImagesViewController.swift
//  Mauritius
//
//  Created by Niranjan Ravichandran on 2/9/18.
//  Copyright © 2018 Aviato. All rights reserved.
//

import UIKit
import SafariServices

class ImagesViewController: SKPhotoBrowser, SKPhotoBrowserDelegate {
    
    private var category: Category!
    private var toolbar: UIView!
    private var currentIndex: Int = 0
    private var favButton: FaveButton!
    private var directionButton: UIButton!
    private var isFromFavorites = false
    private var favorites: [Favorite]?

    convenience init(with object: Category?) {
        var images = [SKPhoto]()
        
        if let imageItems = object?.images {
            for item in imageItems {
                let image = SKPhoto.photoWithImageURL(item.url)
                image.shouldCachePhotoURLImage = true
                images.append(image)
            }
        }
        
        ImagesViewController.setUpImageBrowserOptions(webLink: object?.webLink)
        
        self.init(photos: images)
        
        self.category = object
    }
    
    convenience init(favorites: [Favorite], startIndex: Int) {
        var images = [SKPhoto]()
        
        for item in favorites {
            if let url = item.imgUrl {
                let image = SKPhoto.photoWithImageURL(url)
                image.shouldCachePhotoURLImage = true
                images.append(image)
            }
        }
        
        ImagesViewController.setUpImageBrowserOptions(webLink: favorites.first?.weblink)
        
        self.init(photos: images, initialPageIndex: startIndex)
        self.isFromFavorites = true
        self.favorites = favorites
    }
    
    class func setUpImageBrowserOptions(webLink: String?) {
        SKPhotoBrowserOptions.displayDeleteButton = webLink == nil ? false : true
        SKPhotoBrowserOptions.bounceAnimation = true
        SKPhotoBrowserOptions.displayStatusbar = false
        SKPhotoBrowserOptions.displayCounterLabel = false
        SKPhotoBrowserOptions.displayBackAndForwardButton = false
        SKPhotoBrowserOptions.displayAction = false
        SKPhotoBrowserOptions.displayHorizontalScrollIndicator = false
        SKPhotoBrowserOptions.displayVerticalScrollIndicator = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.toolbar = UIView(frame: self.frameForToolbarAtOrientation())
        toolbar.backgroundColor = UIColor.clear
        
        favButton = FaveButton(frame: CGRect.init(x: 15, y: 0, width: 40, height: 40), faveIconNormal: #imageLiteral(resourceName: "heart-filled"))
        favButton.center.y = toolbar.frame.height/2
        favButton.addTarget(self, action: #selector(self.favbuttonAction(sender:)), for: .touchUpInside)
        toolbar.addSubview(favButton)
        
        directionButton = UIButton(frame: CGRect(x: toolbar.frame.width - 40, y: 0, width: 25, height: 25))
        directionButton.setImage(#imageLiteral(resourceName: "route").withRenderingMode(.alwaysTemplate).tintWithColor(UIColor.white), for: .normal)
        directionButton.center.y = toolbar.frame.height/2
        directionButton.addTarget(self, action: #selector(self.openDirections(sender:)), for: .touchUpInside)
        toolbar.addSubview(directionButton)
        
//        let link = UIButton(frame: CGRect(x: 15, y: 0, width: 25, height: 25))
//        link.setImage(#imageLiteral(resourceName: "web").withRenderingMode(.alwaysTemplate).tintWithColor(UIColor.white), for: .normal)
//        link.center.y = toolbar.frame.height/2
//        link.addTarget(self, action: #selector(self.openURL(sender:)), for: .touchUpInside)
//        toolbar.addSubview(link)
        
        self.view.addSubview(toolbar)
        self.paginationView.frame.origin.y -= 15
        
        self.updateDeleteButton(#imageLiteral(resourceName: "web").withRenderingMode(.alwaysTemplate).tintWithColor(UIColor.white), size: CGSize(width: 50, height: 50))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    @objc func favbuttonAction(sender: FaveButton) {
        //To animate the favButton
        sender.isSelectedWithAnimation = sender.isSelected
        guard let userID = UserManager.shared.currentUser?.id else {
            self.showUserError()
            return
        }
        var objID = ""
        if !isFromFavorites {
            guard let objId_ = self.category?.images?[currentIndex].objectId else {
                return
            }
            objID = objId_
        }else {
            guard let objId_ = self.favorites?[currentIndex].objId else {
                return
            }
            objID = objId_
        }
        
        
        var favFlag = 0
        if sender.isSelected {
            favFlag = 1
            //Add to user favorites
            UserManager.shared.currentUser?.favorites.append(objID)
        }else {
            //Remove from user favorites
            UserManager.shared.currentUser?.removeFavorite(object: objID)
        }
        
        UserManager.shared.setFavorite(with: favFlag, objId: objID, userId: userID, completion: { (success) in
            if !success {
                //Reset fav action if the saving to server failed
                UserManager.shared.currentUser?.removeFavorite(object: objID)
            }
        })
    }
    
    func showUserError() {
        let alert = MUIAlertController(icon: #imageLiteral(resourceName: "icons-about"), title: "Oops!", message: "Please enter your email to add favorites. You can enter your email in the settings page.")
        alert.addAction(action: MUIAlertAction.init(title: "Cancel", style: .cancel, action: {
            self.favButton.isSelectedWithAnimation = false
        }))
        alert.addAction(action: MUIAlertAction.init(title: "Settings", style: .normal, action: {
            delay(0.4, closure: {
                self.dismiss(animated: true, completion: {
                    NotificationCenter.default.post(name: NSNotification.Name.init(mOpenSettingsNotification), object: nil)
                })
            })
            self.favButton.isSelectedWithAnimation = false
        }))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    //Open lat and long in maps
    @objc func openDirections(sender: AnyObject) {
        
    }
    
    @objc func openURL() {
        var urlStr_ = ""
        if let urlString = self.category?.webLink {
            urlStr_ = urlString
        }
        
        if let urlString = self.favorites?.first?.weblink {
            urlStr_ = urlString
        }
        
        if let url = URL(string: urlStr_) {
            let safariVc = SFSafariViewController(url: url, entersReaderIfAvailable: true)
            self.present(safariVc, animated: true, completion: nil)
        }
    }
    
    override func viewDidLayoutSubviews() {
        if self.toolbar != nil {
            self.toolbar.frame = self.frameForToolbarAtOrientation()
            self.directionButton.frame.origin.x = self.toolbar.frame.width - self.directionButton.frame.width - 15
        }
    }
    
    //MARK: - Delegate
    
    func controlsVisibilityToggled(_ browser: SKPhotoBrowser, hidden: Bool) {
        if hidden {
            UIView.animate(withDuration: 0.4, animations: {
                self.toolbar.frame.origin.y = self.view.frame.height
            }, completion: { (_) in
                
            })
        }else {
            UIView.animate(withDuration: 0.3, animations: {
                self.toolbar.frame.origin.y = self.view.frame.height - self.toolbar.frame.height
            })
        }
    }
    
    func didShowPhotoAtIndex(_ browser: SKPhotoBrowser, index: Int) {
        self.currentIndex = index
        var objectID = ""
        if let objectID_ = self.category?.images?[index].objectId {
            objectID = objectID_
        }
        
        if let objeectID_ = self.favorites?[index].objId {
            objectID = objeectID_
        }
        
        if let contains = UserManager.shared.currentUser?.favorites.contains(objectID) {
            if contains { self.favButton.isSelected = true } else {
                self.favButton.isSelected = false
            }
        }
        
    }
    
    func willDismissAtPageIndex(_ index: Int) {
        
    }
    
    //Replaced delete button with weblink. So Handle web link button pressed here
    func removePhoto(_ browser: SKPhotoBrowser, index: Int, reload: @escaping (() -> Void)) {
        self.openURL()
    }
    
    func openLocaitonsOnMap() {
        var lattitude = ""
        var longitude = ""
        
        UIApplication.shared.canOpenURL(NSURL(string:"comgooglemaps://")! as URL)
        
    }
    
    
}

