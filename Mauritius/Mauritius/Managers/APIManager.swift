//
//  APIManager.swift
//  Mauritius
//
//  Created by Niranjan Ravichandran on 1/30/18.
//  Copyright © 2018 Aviato. All rights reserved.
//

import Foundation

/**
 
 enum with all the app endpoints. To be modified only when there is a backend change.
 
 */
enum APIEndPoint: String {
    case getMenu = "getMenuList/1"
    case getDetails = "getDetails/"
    case userDetails = "userDetails/"
    case favorite = "setFavourite/"
    
    var description: String {
        return "http://54.71.21.154:3000/" + self.rawValue
    }
}

/**
 
 Wrapper over Swift.Error to customise error.
 
 */
enum ErrorKind: Swift.Error {
    case network(String)
    case server(String)
    case nodata(String)
    case noparse(String)
    case badRequest(String)
}

class APIManager {
    
    static let shared = APIManager()
   
    /**
     Local image cache to prevent refetching of images.
    */
    
    static var cache = NSCache<NSString, AnyObject>()
    
    private func getData(with url: URL, completion handler: @escaping ([Category]?, ErrorKind?) -> Void) {
        NetworkManager.shared.get(url: url, success: { data in
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: AnyObject] {
                    if let error = json["error"] as? Bool {
                        if error {
                            DispatchQueue.main.async {
                                handler(nil, ErrorKind.server("Encountered an unexpected server error."))
                            }
                        }
                    }
                    
                    if let categories = json["data"] as? [[String: AnyObject]] {
                        var menu = [Category]()
                        for item in categories {
                            let menuItem = Category(json: item)
                            if menuItem.isActive {
                                menu.append(menuItem)
                            }
                        }
                        DispatchQueue.main.async {
                            handler(menu, nil)
                        }
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    handler(nil, ErrorKind.noparse("Encountered an unexpected server error."))
                }
            }
        }) { (errCode, desc) in
            DispatchQueue.main.async {
                handler(nil, ErrorKind.server(desc))
            }
        }
    }
    
    func getMenu(completion handler: @escaping ([Category]?, ErrorKind?) -> Void) {
        let url = URL(string: APIEndPoint.getMenu.description)!
        self.getData(with: url) { (categories, error) in
            handler(categories, error)
        }
    }
    
    func getObjectDetails(with objectId: String, completion handler: @escaping ([Category]?, ErrorKind?) -> Void) {
        if let url = URL(string: APIEndPoint.getDetails.description + objectId) {
            self.getData(with: url) { (categories, error) in
                DispatchQueue.main.async {
                    handler(categories, error)
                }
            }
        }else {
            DispatchQueue.main.async {
                handler(nil, ErrorKind.badRequest("Something went wrong!"))
            }
        }
    }
    
    /**
     
     Image fetcher and objectId is used as the key to cache fetched image.
     Returns image in Data format.
     
     */
    
    func fetchImage(with urlString: String, for objectId: String, completion: @escaping (_ imageData: Data?) -> Void) {
        if let imageData = APIManager.cache.object(forKey: objectId as NSString) as? Data {
            DispatchQueue.main.async {
                completion(imageData)
            }
            return
        }
        if let url = URL(string: urlString) {
            NetworkManager.shared.get(url: url, success: { (data) in
                APIManager.cache.setObject(data as AnyObject , forKey: objectId as NSString)
                DispatchQueue.main.async {
                    completion(data)
                }
            }, error: { (errCode, err) in
                DispatchQueue.main.async {
                    completion(nil)
                }
            })
        }
    }
}
