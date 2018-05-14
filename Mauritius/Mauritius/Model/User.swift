//
//  User.swift
//  Mauritius
//
//  Created by Niranjan Ravichandran on 2/9/18.
//  Copyright © 2018 Aviato. All rights reserved.
//

import Foundation

class User: Codable {
    var id : Int64!
    var username: String?
    var email: String?
    var phone: String?
    var laguage: String?
    var favorites = [String]()
    var favObjects = [Favorite]()
    
    init(json: [String: AnyObject]) {
        self.id = json["user_id"] as? Int64 ?? 0
        self.username = json["username"] as? String
        self.email = json["email_id"] as? String
        self.phone = json["contact"] as? String
        self.laguage = json["lang"] as? String
        if let favs = json["favourite_images"] as? [[String: AnyObject]] {
            for fav in favs {
                let fav_ = Favorite(json: fav)
                self.favObjects.append(fav_)
                self.favorites.append(fav_.objId!)
            }
        }
    }
    
    func removeFavorite(object objectId: String) {
        let contains = self.favorites.contains(objectId)
        if contains {
            if let index_ =  self.favorites.index(of: objectId) {
                self.favorites.remove(at: index_)
            }
        }
    }
}


struct Favorite: Codable {
    let userId: Int64!
    var objId: String!
    let imageId: Int64!
    let imgUrl: String?
    var latitude: Double?
    var longitude: Double?
    var weblink: String?
    
    init(json: [String: AnyObject]) {
        self.userId = json["user_id"] as? Int64 ?? 0
        self.objId = json["obj_id"] as? String ?? ""
        self.imageId = json["image_id"] as? Int64 ?? 0
        self.imgUrl = json["image_url"] as? String ?? ""
        self.latitude = json["latitude"] as? Double
        self.longitude = json["longitude"] as? Double
        self.weblink = json["weblink"] as? String
    }
}
