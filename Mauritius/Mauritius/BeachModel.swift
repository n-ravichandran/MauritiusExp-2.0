//
//  BeachModel.swift
//  Mauritius
//
//  Created by Niranjan Ravichandran on 24/12/15.
//  Copyright © 2015 adavers. All rights reserved.
//

import Foundation
import Parse

struct Beach {
    
    let objectId: String?
    let linkId: String?
    let superParentId: String?
    let imageFile: PFFile?
    let thumnail: PFFile?
    let description: String?
    
    
    init(parseObject: PFObject) {
        
        self.objectId = parseObject.objectId
        self.linkId = parseObject["LinkId"] as? String
        self.superParentId = parseObject["SuperParentId"] as? String
        self.imageFile = parseObject["imageFile"] as? PFFile
        self.thumnail = parseObject["thumbnail"] as? PFFile
        self.description = parseObject["Description"] as? String
    }
    
}

//For Object comparision
protocol Equatable {
    func ==(a: Beach, b: Beach) -> Bool
}

extension Beach: Equatable {}

func ==(a: Beach, b: Beach) -> Bool {
    
        return a == b
}

