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
import MessageUI

class PhotosViewController: UIViewController, MFMailComposeViewControllerDelegate {
    
    @IBOutlet var containerView: UIView!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var favouriteButton: UIButton!
    @IBOutlet var nextButton: UIButton!
    @IBOutlet var previousButton: UIButton!
    @IBOutlet var shareButton: UIButton!
    @IBOutlet var directionsButton: UIButton!
    @IBOutlet var enquireNow: UIButton!
    @IBOutlet var indexLabel: UILabel!
    
    
    var currentObjects: [Beach]?
//    var imageArray = [SKPhoto]()
    var index: Int = 0
    var lattitude: String?
    var longitude: String?
    var weblink: String?
    
    var leftSwipe = UISwipeGestureRecognizer()
    var rightSwipe = UISwipeGestureRecognizer()
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    var currentFavs: [String]?
    
    
    override func viewDidLoad() {

        super.viewDidLoad()
        //Setting up view
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "MauritiusBG.png")!)
        self.containerView.alpha = 0.8
        self.containerView.layer.cornerRadius = 4
        self.imageView.layer.cornerRadius = 4
        self.imageView.clipsToBounds = true
        self.imageView.isUserInteractionEnabled = true
//        self.imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(PhotosViewController.photoViewer)))
        self.leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(PhotosViewController.loadNextImage))
        self.leftSwipe.direction = UISwipeGestureRecognizerDirection.left
        self.rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(PhotosViewController.loadPreviousImage))
        self.rightSwipe.direction = UISwipeGestureRecognizerDirection.right
        self.imageView.addGestureRecognizer(leftSwipe)
        self.imageView.addGestureRecognizer(rightSwipe)
        self.enquireNow.layer.cornerRadius = 4
        
        //Activity indicator
        self.activityIndicator.center = self.view.center
        self.activityIndicator.startAnimating()
        self.view.addSubview(activityIndicator)
        
        if let imageFile = currentObjects?.first?.imageFile {
            if Reachability.isConnectedToNetwork() {
                //Setting initial image on view load
                self.loadImageView(imageFile)
            }else {
                Reachability.networkErrorView(self.view)
            }
        }
        
        //Title for the view
        if let object = currentObjects?.first {
            if let newTitle = object.description {
                if let index = newTitle.range(of: "-")?.lowerBound {
                    if let value = title?.index(after: index) {
                        self.title = newTitle.substring(from: value)
                    }else {
                        self.title = newTitle
                    }
                }
            }
        }
        
        //Adding actions to buttons
        self.nextButton.addTarget(self, action: #selector(PhotosViewController.loadNextImage), for: .touchUpInside)
        self.previousButton.addTarget(self, action: #selector(PhotosViewController.loadPreviousImage), for: .touchUpInside)
        self.favouriteButton.addTarget(self, action: #selector(PhotosViewController.favouriteAction), for: .touchUpInside)
        self.directionsButton.addTarget(self, action: #selector(PhotosViewController.showDirections), for: .touchUpInside)
        self.shareButton.addTarget(self, action: #selector(PhotosViewController.shareImage), for: .touchUpInside)
        
        if let count = currentObjects?.count {
            self.indexLabel.text = "\(index+1)/\(count)"
        }
        
        //Enquire now button
        enquireNow.addTarget(self, action: #selector(self.sendEnquireMail(_:)), for: .touchUpInside)
        
        //Get lat & long for directions
        self.getGeopoints()
        
        //Get user favs
        self.fetchAllUserFavs()

        
    }
    
    //Fetching geopoints and weblink for current category
    func getGeopoints() {
        if let category = currentObjects?.first {
            if let object: String = category.linkId {
                let query = PFQuery(className: "Categories")
                query.getObjectInBackground(withId: object, block: { (response, error) -> Void in
                    
                    if error == nil {
                        let cat:Category = Category(categoryObject: response!)
                        if let link = cat.webLink {
                            self.weblink = link
                            self.directionsButton.setImage(UIImage(named: "open.png"), for: [])
                        }
                        self.lattitude = cat.lattitude
                        self.longitude = cat.longitude
                    } else if error?.code == 100 {
                        Reachability.networkErrorView(self.view)
                    }
                })
            }
        }
    }
    
    //Loading image
    func loadImageView(_ imageFile: PFFile) {
        
        imageFile.getDataInBackground { (imageData, responseError) -> Void in
            
            if responseError == nil {
                if let result = imageData {
                    DispatchQueue.main.async {
                        self.imageView.image = UIImage(data: result)
                        self.activityIndicator.stopAnimating()
                        self.imageView.alpha = 1.0
                    }
                }
            } else if responseError?.code == 100 {
                DispatchQueue.main.async { () -> Void in
                    //Call to Error connection view
                }
            }
        }
    }
    
    func loadNextImage() {
        self.index += 1
        guard let count = currentObjects?.count else {
            return
        }
        if index < count {
            self.markFavorites()
            self.activityIndicator.startAnimating()
            self.imageView.alpha = 0.6
            self.previousButton.isUserInteractionEnabled = true
            self.previousButton.alpha = 1.0
            self.imageView.addGestureRecognizer(rightSwipe)
            self.indexLabel.text = "\(index+1)/\(count)"
            if let imageFile = currentObjects?[index].imageFile {
                self.loadImageView(imageFile)
            } else {
                //Implement error image **TBU**
            }
        }
        
        if index == count - 1 {
            self.imageView.removeGestureRecognizer(leftSwipe)
            self.nextButton.isUserInteractionEnabled = false
            self.nextButton.alpha = 0.8
        }
        
    }
    
    func loadPreviousImage() {
        index -= 1
        if index >= 0 {
            self.markFavorites()
            self.activityIndicator.startAnimating()
            self.imageView.alpha = 0.6
            self.nextButton.isUserInteractionEnabled = true
            self.nextButton.alpha = 1.0
            self.imageView.addGestureRecognizer(leftSwipe)
            if let count = currentObjects?.count {
                self.indexLabel.text = "\(index+1)/\(count)"
            }
            if let imageFile = currentObjects?[index].imageFile{
                self.loadImageView(imageFile)
            } else {
                //Implement error image **TBU**
            }
        }
        
        if index == 0 {
            self.previousButton.isUserInteractionEnabled = false
            self.previousButton.alpha = 0.8
            self.imageView.removeGestureRecognizer(rightSwipe)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func markFavorites() {
        if currentFavs != nil {
            if currentFavs!.contains(currentObjects![index].objectId!) {
                self.favouriteButton.setImage(UIImage(named: "like-filled.png"), for: UIControlState())
            }else {
                self.favouriteButton.setImage(UIImage(named: "like.png"), for: UIControlState())
            }
        }
    }
    
    //Setting up photo browser
//    func photoViewer() {
//        //Calling Activitty Indicator
//        var config : SwiftLoader.Config = SwiftLoader.Config()
//        config.size = 150
//        config.spinnerColor =  UIColor.whiteColor()
//        config.foregroundColor = .blackColor()
//        config.foregroundAlpha = 0.5
//        config.speed = 2
//        SwiftLoader.show("Loading...", animated: true)
//        
//        if imageArray.isEmpty {
//            if let objects = currentObjects {
//                for item in objects {
//                    if let image = item.imageFile {
//                        image.getDataInBackgroundWithBlock({ (imageData, responseError) -> Void in
//                            
//                            if responseError == nil {
//                                
//                                if let result = imageData {
//                                    let photo = SKPhoto.photoWithImage(UIImage(data: result)!)
//                                    self.imageArray.append(photo)
//                                    
//                                    if (item.objectId == objects.last?.objectId) {
//                                        let photoBrowser = SKPhotoBrowser(photos: self.imageArray)
//                                        photoBrowser.delegate = self
//                                        photoBrowser.initializePageIndex(self.index)
//                                        
//                                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                                            SwiftLoader.hide()
//                                            self.presentViewController(photoBrowser, animated: true, completion: nil)
//                                        })
//                                        
//                                    }
//                                }
//                            } else {
//                                SwiftLoader.hide()
//                                if let error = responseError{
//                                    if error.code == 100 {
//                                        let alertView = UNAlertView(title: "Oops!", message: "Please check you internet connection and try again")
//                                        alertView.addButton("Ok", backgroundColor: UIColor(red: 243/255, green: 57/255, blue: 57/255, alpha: 1.0), action: {})
//                                        alertView.show()
//                                    } else {
//                                        let alertView = UNAlertView(title: "Oops!", message: "Some thing went wrong!. Please try again")
//                                        alertView.addButton("Ok", backgroundColor: UIColor(red: 243/255, green: 57/255, blue: 57/255, alpha: 1.0), action: {})
//                                        alertView.show()
//                                    }
//                                }
//                                
//                            }
//                            
//                        })
//                    }
//                }
//            }
//            
//        } else {
//            presentPhotoBrowser()
//        }
//    }
    
//    func presentPhotoBrowser() {
//        SwiftLoader.hide()
//        let photoBrowser = SKPhotoBrowser(photos: self.imageArray)
//        photoBrowser.delegate = self
//        photoBrowser.initializePageIndex(self.index)
//        
//        dispatch_async(dispatch_get_main_queue(), { () -> Void in
//            self.presentViewController(photoBrowser, animated: true, completion: nil)
//        })
//    }
    
    
    //Adding favourites
    func favouriteAction() {
        favouriteButton.setImage(UIImage(named: "like-filled.png"), for: UIControlState())
        let userDefaults = UserDefaults.standard()
        guard let email = userDefaults.object(forKey: "username") as? String else {
            let alertView = UNAlertView(title: "Alert", message: "Please add your email to add favourites")
            favouriteButton.setImage(UIImage(named: "like.png"), for: UIControlState())
            alertView.addButton("Cancel", backgroundColor: UIColor(red: 55/255, green: 55/255, blue: 55/255, alpha: 1.0), action: {})
            alertView.addButton("Add Email", backgroundColor: UIColor(red: 55/255, green: 55/255, blue: 55/255, alpha: 1.0), action: { () -> Void in
                let settingsVC: SettingsViewController = SettingsViewController()
                settingsVC.isPushed = true
                self.navigationController?.pushViewController(settingsVC, animated: true)
            })
            alertView.show()
            return
        }
        
        if currentFavs != nil {
            if let imageId = currentObjects?[index].objectId {
                currentFavs?.append(imageId)
                //Save existing favorites
                ParseFetcher.sharedInstance.saveFavorites(email, favs: currentFavs!, completion: { (saveSuccess, error) in
                    if saveSuccess {
                        ParseFetcher.sharedInstance.DLog(message:"Favs saved to server")
                    }else {
                        ParseFetcher.sharedInstance.DLog(message: error)
                    }
                })
            }
        }else {
            currentFavs = [String]()
            if let imageId = currentObjects?[index].objectId {
                currentFavs?.append(imageId)
                ParseFetcher.sharedInstance.setFavorites(email, favs: currentFavs!, completion: { (saveSuccess, error) in
                    if saveSuccess{
                        ParseFetcher.sharedInstance.DLog(message:"Favs saved to server **")
                    }else {
                        ParseFetcher.sharedInstance.DLog(message:error)
                    }
                })
            }
        }
        
    }
    
    //Activity view controller
    func shareImage() {
        let actitvityVC = UIActivityViewController(activityItems: [""], applicationActivities: nil)
        
        navigationController?.present(actitvityVC, animated: true, completion: nil)
    }
    
    //Opening maps to show directions
    func showDirections() {
        if self.weblink == nil {
            let alertView = UNAlertView(title: "Open Maps", message: "")
            alertView.addButton("Google Maps", backgroundColor: UIColor(red: 55/255, green: 55/255, blue: 55/255, alpha: 1.0)) { () -> Void in
                
                //Google Maps
                UIApplication.shared().openURL(URL(string:"comgooglemaps://?saddr=&daddr=\(self.lattitude!),\(self.longitude!)&directionsmode=driving")!)
            }
            alertView.addButton("Apple Maps", backgroundColor: UIColor(red: 55/255, green: 55/255, blue: 55/255, alpha: 1.0)) { () -> Void in
                
                //Apple Maps
                UIApplication.shared().openURL(URL(string:"http://maps.apple.com/?daddr=\(self.lattitude!),\(self.longitude!)&saddr=")!)
            }

            alertView.addButton("Cancel", backgroundColor: UIColor(red: 55/255, green: 55/255, blue: 55/255, alpha: 1.0), action: {})
            alertView.buttonAlignment = UNButtonAlignment.vertical
            alertView.show()
        } else {
            let alertView = UNAlertView(title: "Open in Safari", message: "")
            alertView.addButton("Open", backgroundColor: UIColor(red: 55/255, green: 55/255, blue: 55/255, alpha: 1.0)) { () -> Void in
                //Open url in browser
                UIApplication.shared().openURL(URL(string: self.weblink!)!)
            }

            alertView.addButton("Cancel", backgroundColor: UIColor(red: 55/255, green: 55/255, blue: 55/255, alpha: 1.0), action: {})
            alertView.show()
        }
    }
    
    //Send mail function
    func sendEnquireMail(_ sender: UIButton) {
        
        let mailPicker = MFMailComposeViewController()
        mailPicker.mailComposeDelegate = self
        mailPicker.setToRecipients(["info@planetexplored.com"])
        mailPicker.setSubject("Mauritius Attractions - Enquiry")
        mailPicker.setMessageBody("I'm interested in this place. I would love to hear more about this.", isHTML: false)
        self.present(mailPicker, animated: true, completion: nil)
    }
    
    func fetchAllUserFavs() {
        let userDefaults = UserDefaults.standard()
        if let email = userDefaults.object(forKey: "username") as? String {
            ParseFetcher.sharedInstance.getFavorites(email, completion: { (favroites) in
                if favroites != nil {
                    if let favs = favroites?.first?["ImageId"] as? [String] {
                        self.currentFavs = favs
                        self.markFavorites()
                    }
                }
            })
        }
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
    
}

