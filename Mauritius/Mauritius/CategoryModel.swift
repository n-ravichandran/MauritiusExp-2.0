//
//  CategoryModel.swift
//  Mauritius
//
//  Created by Niranjan Ravichandran on 21/12/15.
//  Copyright © 2015 adavers. All rights reserved.
//

import Foundation
import Parse

enum Language: Int{
    case chinese = 1
    case english
    case french
    case german
    case italian
}

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
    var isAvailable: Bool = false
    var french: String?
    var german: String?
    var chinese: String?
    var italian: String?
    
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
        self.isAvailable = true
        self.french = categoryObject["french"] as? String
        self.german = categoryObject["german"] as? String
        self.chinese = categoryObject["chinese"] as? String
        self.italian = categoryObject["italian"] as? String
    }
    
    init() {
        
        self.objectId = nil
        self.name = nil
        self.position = nil
        self.lattitude = nil
        self.longitude = nil
        self.webLink = nil
        self.iconName = nil
        self.level = 0
        self.parentID = nil
        self.isActive = nil
        self.hasChild = nil
        self.directChild = nil
    }
    
}
