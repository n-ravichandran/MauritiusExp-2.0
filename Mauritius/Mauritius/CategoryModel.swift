//
//  CategoryModel.swift
//  Mauritius
//
//  Created by Niranjan Ravichandran on 21/12/15.
//  Copyright © 2015 adavers. All rights reserved.
//

import Foundation

struct Category {
    
    let objectId: String?
    let name: String?
    let position: Int?
    let lattitude: String?
    let longitude: String?
    let webLink: String?
    let iconName: String?
    let level: Int! // Explicitly unwrapped since level is never nil
    let parentID: String?
    let isActive: Bool?
    let directChild: Bool?
    let hasChild: Bool?
    
    init(categoryObject: PFObject) {
        
        self.objectId = categoryObject.objectId
        self.name = categoryObject["CategoryName"] as? String
        self.position = categoryObject["position"] as? Int
        self.lattitude = categoryObject["lattitude"] as? String
        self.longitude = categoryObject["longitude"] as? String
        self.webLink = categoryObject["webLink"] as? String
        self.iconName = categoryObject["iconName"] as? String
        self.level = categoryObject["Level"] as! Int
        self.parentID = categoryObject["ParentId"] as? String
        self.isActive = categoryObject["IsActive"] as? Bool
        self.hasChild = categoryObject["hasChild"] as? Bool
        self.directChild = categoryObject["directchild"] as? Bool
    }
    
}