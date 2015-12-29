//
//  PhotosViewController.swift
//  Mauritius
//
//  Created by Niranjan Ravichandran on 26/12/15.
//  Copyright © 2015 adavers. All rights reserved.
//

import UIKit
import SKPhotoBrowser
import Parse

class PhotosViewController: UIViewController, SKPhotoBrowserDelegate {
    
    @IBOutlet var containerView: UIView!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var favouriteButton: UIButton!
    @IBOutlet var nextButton: UIButton!
    @IBOutlet var previousButton: UIButton!
    @IBOutlet var shareButton: UIButton!
    @IBOutlet var directionsButton: UIButton!
    
    
    var currentObjects: [Beach]?
    var imageArray = [SKPhoto]()
    var index: Int = 0
    var lattitude: String?
    var longitude: String?
    var weblink: String?

    override func viewDidLoad() {

        super.viewDidLoad()
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "MauritiusBG.png")!)

        self.containerView.alpha = 0.8
        self.containerView.layer.cornerRadius = 4
        self.imageView.layer.cornerRadius = 4
        self.imageView.clipsToBounds = true
        self.imageView.userInteractionEnabled = true
        self.imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "photoViewer"))
        
        if let imageFile = currentObjects?.first?.imageFile {
            //Setting initial image on view load
            self.loadImageView(imageFile)
        }
        
        //Adding actions to buttons
        self.nextButton.addTarget(self, action: "loadNextImage", forControlEvents: .TouchUpInside)
        self.previousButton.addTarget(self, action: "loadPreviousImage", forControlEvents: .TouchUpInside)
        self.favouriteButton.addTarget(self, action: "favouriteAction", forControlEvents: .TouchUpInside)
        self.directionsButton.addTarget(self, action: "showDirections", forControlEvents: .TouchUpInside)
        self.shareButton.addTarget(self, action: "shareImage", forControlEvents: .TouchUpInside)
        
        self.getGeopoints()
    }
    
    //Fetching geopoints and weblink for current category
    func getGeopoints() {
        if let category = currentObjects?.first {
            if let object: String = category.linkId {
                let query = PFQuery(className: "Category")
                query.getObjectInBackgroundWithId(object, block: { (response, error) -> Void in
                    
                    if error == nil {
                        let cat:Category = Category(categoryObject: response!)
                        if let link = cat.webLink {
                            self.weblink = link
                            self.directionsButton.setImage(UIImage(named: "open.png"), forState: .Normal)
                        }
                        self.lattitude = cat.lattitude
                        self.longitude = cat.longitude
                    }
                })
            }
        }
    }
    
    func loadImageView(imageFile: PFFile) {
        
        imageFile.getDataInBackgroundWithBlock { (imageData, responseError) -> Void in
            
            if responseError == nil {
                if let result = imageData {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.imageView.image = UIImage(data: result)
                    })
                }
            }
        }
    }
    
    func loadNextImage() {
        self.index++
        guard let count = currentObjects?.count else {
            return
        }
        if index < count {
            self.previousButton.userInteractionEnabled = true
            if let imageFile = currentObjects?[index].imageFile {
                self.loadImageView(imageFile)
            } else {
                //Implement error image **TBU**
            }
        }
        
        if index == count - 1 {
            self.nextButton.userInteractionEnabled = false
        }
        
    }
    
    func loadPreviousImage() {
        index--
        if index >= 0 {
            self.nextButton.userInteractionEnabled = true
            if let imageFile = currentObjects?[index].imageFile{
                self.loadImageView(imageFile)
            } else {
                //Implement error image **TBU**
            }
        }
        
        if index == 0 {
            self.previousButton.userInteractionEnabled = false
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func photoViewer() {
        //Calling Activitty Indicator
        var config : SwiftLoader.Config = SwiftLoader.Config()
        config.size = 150
        config.spinnerColor =  UIColor.whiteColor()
        config.foregroundColor = .blackColor()
        config.foregroundAlpha = 0.5
        config.speed = 2
        SwiftLoader.show("Loading...", animated: true)
        
        if imageArray.isEmpty {
            if let objects = currentObjects {
                for item in objects {
                    if let image = item.imageFile {
                        image.getDataInBackgroundWithBlock({ (imageData, responseError) -> Void in
                            
                            if responseError == nil {
                                
                                if let result = imageData {
                                    let photo = SKPhoto.photoWithImage(UIImage(data: result)!)
                                    self.imageArray.append(photo)
                                    
                                    if (item.objectId == objects.last?.objectId) {
                                        let photoBrowser = SKPhotoBrowser(photos: self.imageArray)
                                        photoBrowser.delegate = self
                                        photoBrowser.initializePageIndex(self.index)
                                        
                                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                            SwiftLoader.hide()
                                            self.presentViewController(photoBrowser, animated: true, completion: nil)
                                        })
                                        
                                    }
                                }
                            } else {
                                SwiftLoader.hide()
                                if let error = responseError{
                                    if error.code == 100 {
                                        let alertView = UNAlertView(title: "Oops!", message: "Please check you internet connection and try again")
                                        alertView.addButton("Ok", backgroundColor: UIColor(red: 243/255, green: 57/255, blue: 57/255, alpha: 1.0), action: {})
                                        alertView.show()
                                    } else {
                                        let alertView = UNAlertView(title: "Oops!", message: "Some thing went wrong!. Please try again")
                                        alertView.addButton("Ok", backgroundColor: UIColor(red: 243/255, green: 57/255, blue: 57/255, alpha: 1.0), action: {})
                                        alertView.show()
                                    }
                                }
                                
                            }
                            
                        })
                    }
                }
            }
            
        } else {
            presentPhotoBrowser()
        }
    }
    
    func presentPhotoBrowser() {
        SwiftLoader.hide()
        let photoBrowser = SKPhotoBrowser(photos: self.imageArray)
        photoBrowser.delegate = self
        photoBrowser.initializePageIndex(self.index)
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.presentViewController(photoBrowser, animated: true, completion: nil)
        })
    }
    
    func didShowPhotoAtIndex(index: Int) {
        //**TBU**
    }
    
    func willDismissAtPageIndex(index: Int) {
        //**TBU**
    }
    
    func favouriteAction() {
        if PFUser.currentUser() == nil {
            let alertView = UNAlertView(title: "Alert", message: "Please add your email to add favourites")
            alertView.addButton("Cancel", backgroundColor: UIColor(red: 55/255, green: 55/255, blue: 55/255, alpha: 1.0), action: {})
            alertView.addButton("Add Email", backgroundColor: UIColor(red: 55/255, green: 55/255, blue: 55/255, alpha: 1.0), action: { () -> Void in
                let settingsVC: SettingsViewController = SettingsViewController()
                settingsVC.isPushed = true
                self.navigationController?.pushViewController(settingsVC, animated: true)
            })
            alertView.show()
        }
    }
    
    func shareImage() {
        
    }
    
    func showDirections() {
        if self.weblink == nil {
            let alertView = UNAlertView(title: "Open Maps", message: "")
            alertView.addButton("Google Maps", backgroundColor: UIColor(red: 55/255, green: 55/255, blue: 55/255, alpha: 1.0)) { () -> Void in
                
                UIApplication.sharedApplication().openURL(NSURL(string:"comgooglemaps://?saddr=&daddr=\(self.lattitude!),\(self.longitude!)&directionsmode=driving")!)
            }
            alertView.addButton("Apple Maps", backgroundColor: UIColor(red: 55/255, green: 55/255, blue: 55/255, alpha: 1.0)) { () -> Void in
                
                UIApplication.sharedApplication().openURL(NSURL(string:"http://maps.apple.com/?daddr=\(self.lattitude!),\(self.longitude!)&saddr=")!)
            }

            alertView.addButton("Cancel", backgroundColor: UIColor(red: 55/255, green: 55/255, blue: 55/255, alpha: 1.0), action: {})
            alertView.buttonAlignment = UNButtonAlignment.Vertical
            alertView.show()
        } else {
            let alertView = UNAlertView(title: "Open in Safari", message: "")
            alertView.addButton("Open", backgroundColor: UIColor(red: 55/255, green: 55/255, blue: 55/255, alpha: 1.0)) { () -> Void in
                UIApplication.sharedApplication().openURL(NSURL(string: self.weblink!)!)
            }

            alertView.addButton("Cancel", backgroundColor: UIColor(red: 55/255, green: 55/255, blue: 55/255, alpha: 1.0), action: {})
            alertView.show()
        }
    }
    
}

