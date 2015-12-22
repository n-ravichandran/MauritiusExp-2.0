//
//  ParseFetcher.swift
//  Mauritius
//
//  Created by Niranjan Ravichandran on 21/12/15.
//  Copyright © 2015 adavers. All rights reserved.
//

import Foundation

class ParseFetcher {
    
    class func fetchCategories(completion: (result: [Category])-> Void){
        var categories = [Category]()
        let query = PFQuery(className: "Category")
        query.whereKey("Level", containedIn: [1, 2])
        query.findObjectsInBackgroundWithBlock { (fetchedObjects, fetchError) -> Void in
            
            if fetchError == nil {
                if let objects = fetchedObjects{
                    for item in objects {
                        categories.append(Category(categoryObject: item))
                    }
                }
                completion(result: categories)
            }
        }
    }
}