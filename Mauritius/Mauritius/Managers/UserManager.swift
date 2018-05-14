//
//  UserManager.swift
//  Mauritius
//
//  Created by Niranjan Ravichandran on 2/12/18.
//  Copyright © 2018 Aviato. All rights reserved.
//

import Foundation

class UserManager {
    
    static let shared = UserManager()
    
    var currentUser: User?
    
    func loadUser(callback: (() -> ())? = nil) {
        let userDefault = UserDefaults.standard
        if let userData = userDefault.object(forKey: "user") as? Data {
            currentUser = try? JSONDecoder().decode(User.self, from: userData)
            if currentUser != nil {
                self.getUser(with: self.currentUser!.id, email: self.currentUser!.email!, completion: { (user, error) in
                    if let user_ = user {
                        self.persistUser(user: user_)
                        callback?()
                    }
                })
            }
        }
    }
    
    func createUser(name: String?, email: String, contact: String?, lang: String = "en", completion: @escaping (User?, ErrorKind?) -> ()) {
        let data: [String: Any] = ["username": name ?? "", "email_id": email, "contact": contact ?? "", "lang": lang]
        NetworkManager.shared.post(with: data, url: URL(string: APIEndPoint.userDetails.description)!, success: { (response) in
            do {
                if let json = try JSONSerialization.jsonObject(with: response, options: JSONSerialization.ReadingOptions.allowFragments) as? JSON {
                    DispatchQueue.main.async {
                        if let userData = json["data"] as? JSON {
                            let user = User(json: userData)
                            self.persistUser(user: user)
                            completion(user, nil)
                            return
                        }
                        completion(nil, ErrorKind.nodata("Encountered an unexpected server error."))
                    }
                }
            }catch {
                DispatchQueue.main.async {
                    completion(nil, ErrorKind.noparse("Encountered an unexpected server error."))
                }
            }
        }) { (errCode, errDesc) in
            DispatchQueue.main.async {
                completion(nil, ErrorKind.network("Encountered an unexpected server error."))
            }
        }
    }
    
    /**
     A POST method. Fetches user details for the given user id and email
    */
    func getUser(with id: Int64, email: String, completion: @escaping (User?, ErrorKind?) -> ()) {
        let data: [String: Any] = ["email_id": email, "user_id": id]
        NetworkManager.shared.post(with: data, url: URL(string: APIEndPoint.userDetails.description)!, success: { (responseData) in
            do {
                if let json = try JSONSerialization.jsonObject(with: responseData, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: AnyObject] {
                    if let error = json["error"] as? Bool {
                        if error {
                            DispatchQueue.main.async {
                                completion(nil, ErrorKind.server("Encountered an unexpected server error."))
                            }
                        }
                    }
                    
                    if let userData = json["data"] as? [String: AnyObject] {
                        let user = User.init(json: userData)
                        DispatchQueue.main.async {
                            completion(user, nil)
                        }
                    }
                }
            } catch {
                completion(nil, ErrorKind.noparse("Encountered an unexpected server error."))
            }
        }) { (errCode, desc) in
            DispatchQueue.main.async {
                completion(nil, ErrorKind.server(desc))
            }
        }
    }
    
    /**
     Persists the passed User object to UserDefaults. Use only for persisting required objects.
     */
    func persistUser(user: User) {
        UserManager.shared.currentUser = user
        let defaults = UserDefaults.standard
        if let encodedData = try? JSONEncoder().encode(user) {
            defaults.set(encodedData, forKey: "user")
            defaults.synchronize()
        }
    }
    
    func setFavorite(with flag: Int, objId: String, userId: Int64, completion: @escaping (Bool) -> ()) {
        let data: [String: Any] = ["flag": flag, "object_id": objId, "user_id": userId]
        NetworkManager.shared.post(with: data, url: URL(string: APIEndPoint.favorite.description)!, success: { (response) in
            do {
                if let json = try JSONSerialization.jsonObject(with: response, options: .allowFragments) as? JSON {
                    DispatchQueue.main.async {
                        if let error = json["error"] as? Bool, error {
                            completion(false)
                            
                        }else {
                            completion(true)
                        }
                    }
                }
            }catch {
                DispatchQueue.main.async {
                    completion(false)
                }
            }
        }) { (errCode, err) in
            DispatchQueue.main.async {
                completion(false)
            }
        }
    }
}
