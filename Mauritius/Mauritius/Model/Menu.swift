//
//  Menu.swift
//  Mauritius
//
//  Created by Niranjan Ravichandran on 1/31/18.
//  Copyright © 2018 Aviato. All rights reserved.
//

import Foundation

struct Category: Codable {
    var masterId: Int64!
    var objectId: String!
    /**
     Sometimes the value is wrong. Use with caution.
     */
    var hasChild: Bool = false
    var iconName: String!
    var catgLevel: Int!
    var parentId: String!
    var catgName: String!
    var position: Int!
    var isActive: Bool = false
    var directChild: Int?
    var latitude: Double?
    var longitude: Double?
    var webLink: String?
    var subMenu: [Category]?
    var images: [ImageDetails]?
    
    init(json: [String: AnyObject]) {
        self.masterId = json["master_id"] as? Int64 ?? 0
        self.objectId = json["obj_id"] as? String ?? ""
        if let val = json["has_child"] as? Int {
            self.hasChild = val == 1 ? true : false
        }
        self.iconName = json["icon_name"] as? String ?? ""
        self.catgLevel = json["catg_level"] as? Int ?? 0
        self.parentId = json["parent_id"] as? String ?? ""
        self.catgName = json["catg_name"] as? String ?? ""
        self.position = json["position"] as? Int ?? 0
        if let val = json["is_active"] as? Int {
            self.isActive = val == 1 ? true : false
            if catgName == "Settings" {
                self.isActive = false
            }
        }
        self.directChild = json["direct_child"] as? Int ?? 0
        self.latitude = json["latitude"] as? Double
        self.longitude = json["longtitude"] as? Double
        self.webLink = json["weblink"] as? String
        
        if let subs = json["sub-menu"] as? [[String: AnyObject]] {
            subMenu = [Category]()
            for item in subs {
                let subMenuItem = Category.init(json: item)
                if subMenuItem.isActive { subMenu?.append(subMenuItem) }
            }
            subMenu = subMenu?.sorted{ $0.position < $1.position }
        }
        if let imageData = json["image"] as? [[String: AnyObject]] {
             self.images = [ImageDetails]()
            for data in imageData {
                images?.append(ImageDetails(json: data))
            }
        }
    }
}

struct ImageDetails: Codable {
    
    let id: Int64!
    let objectId: String!
    let parentId: String!
    var filename: String?
    var url: String!
    
    init(json: [String: AnyObject]) {
        self.id = json["image_id"] as? Int64 ?? 0
        self.objectId = json["obj_id"] as? String ?? ""
        self.parentId = json["parent_id"] as? String ?? ""
        if let file = json["file_name"] as? String {
            self.filename = file
        }
        self.url = json["image_url"] as? String ?? ""
    }
}
