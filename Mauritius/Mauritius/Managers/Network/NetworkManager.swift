//
//  NetworkManager.swift
//  Mauritius
//
//  Created by Niranjan Ravichandran on 1/30/18.
//  Copyright © 2018 Aviato. All rights reserved.
//

import UIKit

class NetworkManager {
    
    static let shared = NetworkManager()
    static var httpRequestCount = 0
    
    /**
     A HTTP GET method. Build over default URLSession Configuration
     */
    func get(url: URL, success: @escaping (_ data: Data) -> (), error: @escaping (_ code: Int, _ reason: String) -> ()) {
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.allowsCellularAccess = true
        
        self.increaseHttpRequestCount()
        
        let session = URLSession(configuration: .default)
        session.dataTask(with: request) { (responseData, response, err) in
            
            self.decreaseHttpRequestCount()
            
            if let _ = err {
                error(000 , "DataTask error: " + err!.localizedDescription)
                return
            }
            
            guard let data = responseData, let urlResponse = response as? HTTPURLResponse else {
                error(000 , "DataTask error: No response from server!")
                return
            }
            
            if urlResponse.statusCode == 200 {
                success(data)
            }else {
                error(urlResponse.statusCode, HTTPURLResponse.localizedString(forStatusCode: urlResponse.statusCode))
            }
            
            
        }.resume()
    }
    
    /**
     A HTTP POST method. Build over default URLSession Configuration
     */
    func post(with json: [String: Any], url: URL, success: @escaping (_ data: Data) -> (), error: @escaping (_ code: Int, _ reason: String) -> ()) {
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allowsCellularAccess = true
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        var paramString: String? = ""
        
        for (key, value) in json {
            paramString! += "\(key)=\(value)&"
        }
        
        request.httpBody = paramString?.data(using: .ascii, allowLossyConversion: false)
        
        self.increaseHttpRequestCount()
        
        let session = URLSession(configuration: .default)
        session.dataTask(with: request) { (responseData, response, err) in
            
            self.decreaseHttpRequestCount()
            
            if let _ = err {
                error(000 , "DataTask error: " + err!.localizedDescription)
                return
            }
            
            guard let data = responseData, let urlResponse = response as? HTTPURLResponse else {
                error(000 , "DataTask error: No response from server!")
                return
            }
            
            if urlResponse.statusCode == 200 {
                success(data)
            }else {
                error(urlResponse.statusCode, HTTPURLResponse.localizedString(forStatusCode: urlResponse.statusCode))
            }
            
            
            }.resume()
    }
    
    
    //MARK: - NetworkActivityIndicator - visiblity control
    
    func increaseHttpRequestCount() {
        NetworkManager.httpRequestCount += 1
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
    }
    
    func decreaseHttpRequestCount() {
        NetworkManager.httpRequestCount -= 1
        if NetworkManager.httpRequestCount <= 0 {
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
            NetworkManager.httpRequestCount = 0
        }
    }
}
