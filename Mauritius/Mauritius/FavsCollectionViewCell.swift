//
//  FavsCollectionViewCell.swift
//  MauritiusAttraction
//
//  Created by Niranjan Ravichandran on 23/04/16.
//  Copyright © 2016 adavers. All rights reserved.
//

import UIKit

class FavsCollectionViewCell: UICollectionViewCell {
    
    let cellImageView: UIImageView = {
       let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
//    let favButton: UIButton = {
//        let button = UIButton(frame: CGRectMake(0, 0, 25, 25))
//        button.setImage(UIImage(named: "like-filled.png"), forState: .Normal)
//        return button
//    }()

    override func awakeFromNib() {
        super.awakeFromNib()
        setUpView()
    }
    
    func setUpView() {
        self.backgroundColor = UIColor(red: 237/255, green: 237/255, blue: 237/255, alpha: 1.0)
        self.addSubview(cellImageView)
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[v0]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0" : cellImageView]))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[v0]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0": cellImageView]))
    }
}
