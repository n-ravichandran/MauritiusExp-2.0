//
//  ParseFetcher.swift
//  Mauritius
//
//  Created by Niranjan Ravichandran on 21/12/15.
//  Copyright © 2015 adavers. All rights reserved.
//

import Foundation
import Parse

class ParseFetcher {
    
    
    //Fetching Categories
    class func fetchCategories(values: [Int], completion: (result: [Category])-> Void){
        var categories = [Category]()
        let query = PFQuery(className: "Category")
        query.whereKey("Level", containedIn: values)
        query.findObjectsInBackgroundWithBlock { (fetchedObjects, fetchError) -> Void in
            
            if fetchError == nil {
                if let objects = fetchedObjects{
                    for item in objects {
                        categories.append(Category(categoryObject: item))
                    }
                }
            }
            completion(result: categories)
        }
    }
    
    class func fetchBeaches(superParentId: String, completion: (result: [Beach]) -> Void) {
        var beaches = [Beach]()
        let query = PFQuery(className: "Beach")
        query.whereKey("SuperParentId", equalTo: superParentId)
        query.findObjectsInBackgroundWithBlock { (responseObjects, responseError) -> Void in
            
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
}