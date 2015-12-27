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

class PhotosViewController: UIViewController {
    
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
        self.nextButton.addTarget(self, action: "loadNextImage", forControlEvents: UIControlEvents.TouchUpInside)
        self.previousButton.addTarget(self, action: "loadPreviousImage", forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    func loadImageView(imageFile: PFFile) {
        ParseFetcher.fetchImageData(imageFile) { (result) -> Void in
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.imageView.image = UIImage(data: result)
            })
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
            print(index)
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
        
        if let objects = currentObjects {
            for item in objects {
                if let image = item.imageFile {
                    ParseFetcher.fetchImageData(image, completion: { (result) -> Void in
                        
                        let photo = SKPhoto.photoWithImage(UIImage(data: result)!)
                        self.imageArray.append(photo)
                        
                        let photoBrowser = SKPhotoBrowser(photos: self.imageArray)
                        //photoBrowser.delegate = self
                        photoBrowser.initializePageIndex(self.index)
                        
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.presentViewController(photoBrowser, animated: true, completion: nil)
                        })
                    })
                }
            }
        }
    }
    
    

    
}
