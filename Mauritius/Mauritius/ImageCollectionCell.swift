//
//  ImageCollectionCell.swift
//  Mauritius
//
//  Created by Niranjan Ravichandran on 21/12/15.
//  Copyright © 2015 adavers. All rights reserved.
//

import UIKit

class ImageCollectionCell: UICollectionViewCell {

    @IBOutlet var coverImageView: UIImageView!
    @IBOutlet var cellTitle: UILabel!
    
    var currentImage: NSData? {
        didSet {
            if let name = currentImage {
            self.coverImageView.image = UIImage(data: name)
            }
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
        //Focus for the current cell
        override func applyLayoutAttributes(layoutAttributes: UICollectionViewLayoutAttributes) {
            super.applyLayoutAttributes(layoutAttributes)
    
            let standardHeight = UltravisualLayoutConstants.Cell.standardHeight
            let featuredHeight = UltravisualLayoutConstants.Cell.featuredHeight
            let delta = 1 - ((featuredHeight - CGRectGetHeight(frame)) / (featuredHeight - standardHeight))
            let minAlpha: CGFloat = 0.8
            let maxAlpha: CGFloat = 0.3
            coverImageView.alpha = maxAlpha - (delta * (maxAlpha - minAlpha))
        }

}
