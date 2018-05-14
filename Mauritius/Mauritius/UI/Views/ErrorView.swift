//
//  ErrorView.swift
//  Mauritius
//
//  Created by Niranjan Ravichandran on 2/8/18.
//  Copyright © 2018 Aviato. All rights reserved.
//

import UIKit

class ErrorView: UIView {
    var imageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        
        imageView = UIImageView(frame: CGRect.init(x: 0, y: 0, width: self.frame.width, height: 200))
        imageView.contentMode = .scaleAspectFit
        imageView.image = #imageLiteral(resourceName: "comingsoon")
        imageView.center.x = self.frame.width/2
        imageView.frame.origin.y = (self.frame.height/2) - (imageView.frame.height - 40)
        self.addSubview(imageView)
        
        let infoLabel = UILabel(frame: CGRect.init(x: 0, y: 0, width: self.frame.width, height: 20))
        infoLabel.text = "No content yet"
        infoLabel.font = UIFont.systemFont(ofSize: 16)
        infoLabel.textColor = UIColor.darkGray
        infoLabel.textAlignment = .center
        infoLabel.center = CGPoint(x: self.frame.width/2, y: (self.frame.height/2))
        self.addSubview(infoLabel)
        
        let comingSoon = UILabel(frame: CGRect.init(x: 0, y: 0, width: self.frame.width, height: 50))
        comingSoon.text = "Coming Soon!"
        comingSoon.textColor = UIColor.mblack
        comingSoon.font = UIFont.boldSystemFont(ofSize: 25)
        comingSoon.center = CGPoint(x: self.frame.width/2, y: (self.frame.height/2) + 30)
        comingSoon.textAlignment = .center
        self.addSubview(comingSoon)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

