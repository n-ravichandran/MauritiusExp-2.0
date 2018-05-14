//
//  MainViewController.swift
//  Mauritius
//
//  Created by Niranjan Ravichandran on 11/21/17.
//  Copyright © 2017 Aviato. All rights reserved.
//

import UIKit

class MainViewController: MBaseViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    private var collectionView: UICollectionView!
    private var objectId: String = "wic0lLoZcs"
    private var categories: [Category]?
    private var errorView: ErrorView?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addLeftBarButtonWithImage(#imageLiteral(resourceName: "menu"))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "settings"), style: .plain, target: self, action: #selector(self.openSettings))
        
       //CollectionView set up
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 6
        collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = UIColor.white
        collectionView.contentInset = UIEdgeInsetsMake(4, 0, 8, 0)
        if #available(iOS 11.0, *) {
            if !self.navigationController!.navigationBar.prefersLargeTitles {
                self.collectionView.contentInset.top = 8
            }
        }
        collectionView.register(MainCollectionViewCell.self, forCellWithReuseIdentifier: String(describing: MainCollectionViewCell.self))
        self.view.addSubview(collectionView)
        
        self.title = "Beaches"
        self.loadData()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.openSettings), name: NSNotification.Name.init(mOpenSettingsNotification), object: nil)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func openMenu() {
        self.slideMenuController()?.openLeft()
    }
    
    @objc func openSettings() {
        self.show(SettingsViewController(), sender: self)
    }
    
    private func loadData() {
        self.categories = nil
        APIManager.shared.getObjectDetails(with: self.objectId) { (categories_, error) in
            if categories_ != nil {
                self.errorView?.removeFromSuperview()
                self.categories = categories_
                self.collectionView.reloadData()
            }else {
                //Show error view
                if self.errorView == nil {
                    self.errorView = ErrorView(frame: self.view.bounds)
                }
                self.collectionView.reloadData()
                self.view.addSubview(self.errorView!)
            }
        }
    }
    
    func reloadViewData(with id: String, title: String?) {
        self.objectId = id
        self.categories?.removeAll()
        self.title = title
        self.loadData()
    }
    
    //MARK: - UICollectionView DataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.categories?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: MainCollectionViewCell.self), for: indexPath) as? MainCollectionViewCell
        cell?.prepareView(with: self.categories?[indexPath.row])
        if let image = self.categories?[indexPath.row].images?.first {
            APIManager.shared.fetchImage(with: image.url, for: image.objectId, completion: { (imageData) in
                if imageData != nil {
                    cell?.setImage(with: imageData!)
                }
            })
        }
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.bounds.width - 16, height: 120)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? MainCollectionViewCell {
            self.present(ImagesViewController(with: cell.data), animated: true, completion: nil)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.collectionView.frame = self.view.bounds
        self.collectionView.collectionViewLayout.invalidateLayout()
    }
    
    deinit {
        //Remove all notification observers
        NotificationCenter.default.removeObserver(self)
    }
    
}

