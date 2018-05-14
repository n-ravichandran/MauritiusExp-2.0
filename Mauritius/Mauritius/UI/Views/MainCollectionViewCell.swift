//
//  MainCollectionViewCell.swift
//  Mauritius
//
//  Created by Niranjan Ravichandran on 2/6/18.
//  Copyright © 2018 Aviato. All rights reserved.
//

import UIKit

class MainCollectionViewCell: UICollectionViewCell {
    
    var data: Category?
    private var containerView: UIView!
    private var imageView: UIImageView!
    private var textLabel: UILabel!
    private var activityView: UIActivityIndicatorView!
    
    private var heightConstant: CGFloat = 120
    private var widthConstant: CGFloat = 0
    
    func prepareView(with data: Category?) {
        self.data = data
        
        if containerView == nil {
            containerView = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: 120))
            self.widthConstant = self.frame.width
            containerView.layer.cornerRadius = 6
            containerView.clipsToBounds = true
            containerView.backgroundColor = UIColor.lightBg
//            containerView.addTarget(self, action: #selector(self.onTouchDown(sender:)), for: .touchDown)
//            containerView.addTarget(self, action: #selector(self.onTouchCancel(sender:)), for: [.touchDragExit, .touchDragOutside, .touchUpInside, .touchUpOutside, .touchCancel])
            self.addSubview(containerView!)
            
            activityView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
            activityView?.center = CGPoint(x: self.containerView.frame.width/2, y: self.containerView.frame.height/2)
            self.startActivity()
            
            imageView = UIImageView(frame: self.containerView.bounds)
            imageView.layer.cornerRadius = 6
            imageView.clipsToBounds = true
            imageView.contentMode = .scaleAspectFill
            imageView.layer.borderWidth = 0.5
            imageView.layer.borderColor = UIColor.lightBg.cgColor
            containerView.addSubview(imageView)
            
            textLabel = UILabel(frame: CGRect(x: 10, y: 0, width: self.containerView.frame.width - 20, height: 20))
            textLabel.text = data?.catgName
            textLabel.textColor = UIColor.white
            textLabel.layer.shadowColor = UIColor.black.cgColor
            textLabel.layer.shadowRadius = 6
            textLabel.layer.shadowOpacity = 0.85
            textLabel.layer.shadowOffset = CGSize(width: -1, height: 1)
            textLabel.layer.masksToBounds = false
            textLabel.layer.rasterizationScale = UIScreen.main.scale
            textLabel.font = UIFont.systemFont(ofSize: 18)
            textLabel.frame.origin.y = self.containerView.frame.height - 30
            textLabel.layer.shouldRasterize = true
            imageView.addSubview(textLabel)
            return
        }
        textLabel?.text = data?.catgName
        self.startActivity()
    }
    
    func setImage(with imageData: Data) {
        self.containerView.backgroundColor = UIColor.white
        self.imageView.image = UIImage(data: imageData)
        self.stopActivity()
    }
    
    func startActivity() {
        self.containerView?.addSubview(activityView)
        self.activityView?.startAnimating()
    }
    
    func stopActivity() {
        self.activityView.stopAnimating()
        self.activityView.removeFromSuperview()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.containerView?.backgroundColor = UIColor.lightBg
        self.imageView?.image = nil
        self.textLabel?.text = nil
        
    }
    
    @objc func onTouchDown(sender: UIControl) {
        UIView.animate(withDuration: 0.2, animations: {
            self.imageView.frame.size.width = self.widthConstant - 5
            self.imageView.frame.size.height = self.heightConstant - 5
            self.imageView.center = CGPoint(x: sender.frame.width/2, y: sender.frame.height/2)
        }) { (_) in
//            self.onTouchCancel(sender: sender)
        }
    }
    
    @objc func onTouchCancel(sender: UIControl) {
        UIView.animate(withDuration: 0.2) {
            self.imageView.frame.size.width = self.widthConstant
            self.imageView.frame.size.height = self.heightConstant
            self.imageView.center = CGPoint(x: sender.frame.width/2, y: sender.frame.height/2)
        }
    }
}
