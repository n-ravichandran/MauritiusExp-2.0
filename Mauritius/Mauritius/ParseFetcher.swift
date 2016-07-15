//
//  ParseFetcher.swift
//  Mauritius
//
//  Created by Niranjan Ravichandran on 21/12/15.
//  Copyright © 2015 adavers. All rights reserved.
//  Sort of like the connection manager class for the app

import Foundation
import Parse

class ParseFetcher {
    
    static let sharedInstance = ParseFetcher()
    
    //Fetching Categories
    func fetchCategories(_ values: [Int], completion: (result: [Category], count1: Int)-> Void){
        var levelOneCount: Int = 0
        var categories = [Category]()
        let query = PFQuery(className: "Categories")
        query.whereKey("Level", containedIn: values)
        query.findObjectsInBackground { (fetchedObjects, fetchError) -> Void in
            
            if fetchError == nil {
                if let objects = fetchedObjects {
                    for item in objects {
                        if item["Level"] as! Int == 1 {
                            levelOneCount += 1
                        }
                        categories.append(Category(categoryObject: item))
                    }
                }
            }
            completion(result: categories, count1: levelOneCount)
        }
    }
    
    func fetchBeaches(_ superParentId: String, completion: (result: [Beach]) -> Void) {
        var beaches = [Beach]()
        let query = PFQuery(className: "Beaches")
        query.whereKey("SuperParentId", equalTo: superParentId)
        query.findObjectsInBackground { (responseObjects, responseError) -> Void in
            
            if responseError == nil {
                
                if let objects = responseObjects {
                    for item in objects {
                        beaches.append(Beach(parseObject: item))
                    }
                }
            }
            completion(result: beaches)
        }
        
    }
    
    //Check if user exists
    func checkUser(_ username: String, completion: (userExists: Bool)-> Void) {
        let query = PFQuery(className: "_User")
        query.whereKey("username", equalTo: username)
        query.findObjectsInBackground { (parseObject, responseError) in
            
            if responseError == nil {
//                print(parseObject?.first?.objectId, "######")
                if parseObject?.first?.objectId != nil {
                    completion(userExists: true)
                }else {
                    completion(userExists: false)
                }
            }else {
                //Handle error from parse
            }
        }
        
    }
    
    //Create a new user
    func createUser(_ userObject: PFUser, completion: (status: Bool)-> Void) {
        userObject.signUpInBackground { (signUpsuccess, signupError) in
            if signUpsuccess{
                completion(status: true)
            }else {
                completion(status: false)
            }
        }
    }
    
    //Get favorites for username
    func getFavorites(_ username: String, completion: (favroites: [PFObject]?)-> Void) {
        let query = PFQuery(className: "Favourites")
        query.whereKey("UserId", equalTo: username)
        query.findObjectsInBackground { (favs, fetchError) in
            if fetchError == nil {
                completion(favroites: favs)
            }else {
                completion(favroites: nil)
            }
        }
    }
    
    //Save favorites to server
    func saveFavorites(_ username: String, favs: [String], completion: (saveSuccess: Bool, error: String?) -> Void){
        let query = PFQuery(className: "Favourites")
        query.whereKey("UserId", equalTo: username)
        query.findObjectsInBackground { (favObjects, fetchError) in
            if fetchError == nil {
                if let currentFav = favObjects?.first {
                    currentFav["ImageId"] = favs
                    currentFav.saveInBackground({ (saveStatus, saveError) in
                        if saveStatus {
                            completion(saveSuccess: true, error: nil)
                        }else {
                            completion(saveSuccess: false, error: saveError?.localizedDescription)
                        }
                    })
                }
            }
        }
    }
    
    //Save favorites for first time
    func setFavorites(_ username: String, favs: [String], completion: (saveSuccess: Bool, error: String?)-> Void) {
        let favObject = PFObject(className: "Favourites")
        favObject["UserId"] = username
        favObject["ImageId"] = favs
        favObject.saveInBackground { (saveStatus, saveError) in
            if saveStatus {
                completion(saveSuccess: true, error: nil)
            }else {
                completion(saveSuccess: false, error: saveError?.localizedDescription)
            }
        }
    }
    
    //Fetch object by id
    func getObjectByID(_ objectID: String, className: String, completion: (status: Bool, rseponse: Beach)-> Void){
        
        let query = PFQuery(className: className)
        query.getObjectInBackground(withId: objectID) { (responseObject, responseError) in
            if let response = responseObject {
                completion(status: true, rseponse: Beach(parseObject: response))
            }
        }
    }
    
    //Logging functions
    func DLog(message: String?, filename: String = #file, function: String = #function, line: Int = #line) {
        #if DEBUG
            print("[\(filename.lastPathComponent):\(line)] \(function) - \(message)")
        #else
            print("Not in debug mode :p")
        #endif
    }

}
