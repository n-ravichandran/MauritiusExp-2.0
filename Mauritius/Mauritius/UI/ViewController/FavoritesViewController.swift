//
//  FavoritesViewController.swift
//  Mauritius
//
//  Created by Niranjan Ravichandran on 2/8/18.
//  Copyright © 2018 Aviato. All rights reserved.
//

import UIKit

class FavoritesViewController: MBaseViewController {
    
    var collectionView: UICollectionView!
    var user: User?
    var errorView: UIView?
    var favButton: FaveButton?
    var timer: Timer!
    var favorites: [Favorite]?
    var activity: UIActivityIndicatorView?
    var refreshControl: UIRefreshControl?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        self.title = "Favorites"
        self.user = UserManager.shared.currentUser
        
        if user?.favorites != nil {
            self.setUpView()
            self.activity = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
            self.activity?.color = UIColor.gray
            self.activity?.center = CGPoint(x: self.view.frame.width/2, y: (self.view.frame.height/2) - (self.navigationController?.navigationBar.frame.maxY ?? 0))
            self.view.addSubview(activity!)
            self.view.bringSubview(toFront: activity!)
            self.loadData()
            
        }else {
            self.showError()
            timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(self.strtAnimating), userInfo: nil, repeats: true)
        }
    }
    
    @objc func loadData() {
        self.activity?.startAnimating()
        UserManager.shared.loadUser {
            self.activity?.stopAnimating()
            self.activity?.removeFromSuperview()
            self.favorites = UserManager.shared.currentUser?.favObjects
            self.collectionView.reloadData()
            if #available(iOS 10.0, *) {
                self.collectionView.refreshControl?.endRefreshing()
            } else {
                self.refreshControl?.endRefreshing()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showError() {
        errorView = UIView(frame: self.view.bounds)
        let info = UILabel(frame: CGRect.init(x: 0, y: 0, width: self.errorView!.frame.width - 40, height: 20))
        info.text = "Your favorite photos/places go here. \n Tap on the heart button to add it to favorites."
        info.numberOfLines = 0
        info.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.light)
        info.textAlignment = .center
        info.sizeToFit()
        info.frame.size.width = self.errorView!.frame.width - 40
        info.textColor = UIColor.gray
        info.center.x = errorView!.frame.width/2
        info.frame.origin.y = (self.errorView!.frame.height/2) + info.frame.height
        errorView?.addSubview(info)
        
        favButton = FaveButton(frame: CGRect.init(x: 0, y: 0, width: 100, height: 100), faveIconNormal: #imageLiteral(resourceName: "heart-filled"))
        favButton?.center.x = self.errorView!.frame.width/2
        favButton?.frame.origin.y = (self.errorView!.frame.height/2) - (favButton!.frame.height/2) - 10
        errorView?.addSubview(favButton!)
        
        errorView?.center = CGPoint(x: self.view.frame.width/2, y: (self.view.frame.height/2) - (self.navigationController?.navigationBar.frame.maxY ?? 0))
        self.view.addSubview(errorView!)
    }
    
    @objc func strtAnimating() {
        if favButton != nil {
            favButton!.isSelectedWithAnimation = !favButton!.isSelected
        }else {
            timer?.invalidate()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.timer?.invalidate()
    }

}

//MARK: - UICollectionView

extension FavoritesViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func setUpView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 3
        layout.minimumLineSpacing = 3
        collectionView = UICollectionView.init(frame: self.view.bounds, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.contentInset = UIEdgeInsetsMake(3, 3, 3, 3)
        collectionView.alwaysBounceVertical = true
        collectionView.register(FavoritesCollectionCell.self, forCellWithReuseIdentifier: String(describing: FavoritesCollectionCell.self))
        collectionView.backgroundColor = UIColor.white
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(self.loadData), for: .valueChanged)
        if #available(iOS 10.0, *) {
            collectionView.refreshControl = refreshControl
        } else {
            collectionView.addSubview(refreshControl!)
        }
        self.view.addSubview(collectionView)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.favorites?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: FavoritesCollectionCell.self), for: indexPath) as? FavoritesCollectionCell
        let img = self.favorites?[indexPath.item]
        cell?.prepareView(with: img?.imgUrl, objectID: img?.objId)
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = (collectionView.frame.width - (3 * 5)) / 4
        return CGSize(width: size, height: size)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.favorites != nil {
            let imagesVC = ImagesViewController.init(favorites: favorites!, startIndex: indexPath.item)
            self.present(imagesVC, animated: true, completion: nil)
        }
    }
}

//MARK: - UICollectionViewCell

class FavoritesCollectionCell: UICollectionViewCell {
    
    private var containerView: UIView!
    private var imageView: UIImageView!
    private var cellWidth: CGFloat = 0
    private var cellHeight: CGFloat = 0
    
    func prepareView(with imageURL: String?, objectID: String?) {
        if containerView == nil {
            containerView = UIView(frame: self.bounds)
            containerView.backgroundColor = UIColor.lightBg
            containerView.layer.cornerRadius = 4
            containerView.clipsToBounds = true
//            containerView.addTarget(self, action: #selector(self.onTouchDown(sender:)), for: .touchDown)
//            containerView.addTarget(self, action: #selector(self.onTouchCancel(sender:)), for: [.touchDragExit, .touchDragOutside, .touchUpInside, .touchUpOutside, .touchCancel])
            self.addSubview(containerView)
            
            imageView = UIImageView(frame: containerView.bounds)
            imageView.contentMode = .scaleAspectFill
            imageView.layer.cornerRadius = 4
            imageView.clipsToBounds = true
            containerView.addSubview(imageView)
            if imageURL != nil && objectID != nil {
                self.setImage(url: imageURL!, objectId: objectID!)
            }
        }
        cellWidth = self.frame.width
        cellHeight = self.frame.height
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.containerView?.backgroundColor = UIColor.lightBg
        self.imageView?.image = nil
    }
    
    func setImage(url: String, objectId: String) {
        APIManager.shared.fetchImage(with: url, for: objectId) { (imageData) in
            if let data_ = imageData {
                self.imageView.image = UIImage(data: data_)
            }
        }
    }
    
    @objc func onTouchDown(sender: UIControl) {
        UIView.animate(withDuration: 0.2, animations: {
            self.imageView.frame.size.width = self.cellWidth - 5
            self.imageView.frame.size.height = self.cellHeight - 5
            self.imageView.center = CGPoint(x: sender.frame.width/2, y: sender.frame.height/2)
        }) { (_) in
            //            self.onTouchCancel(sender: sender)
        }
    }
    
    @objc func onTouchCancel(sender: UIControl) {
        UIView.animate(withDuration: 0.2) {
            self.imageView.frame.size.width = self.cellWidth
            self.imageView.frame.size.height = self.cellHeight
            self.imageView.center = CGPoint(x: sender.frame.width/2, y: sender.frame.height/2)
        }
    }
}
