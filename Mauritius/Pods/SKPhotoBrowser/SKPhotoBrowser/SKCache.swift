//
//  SKCache.swift
//  SKPhotoBrowser
//
//  Created by Kevin Wolkober on 6/13/16.
//  Copyright © 2016 suzuki_keishi. All rights reserved.
//

import UIKit

public class SKCache {

    public static let sharedCache = SKCache()
    public var imageCache: SKCacheable

    init() {
        self.imageCache = SKDefaultImageCache()
    }

    public func imageForKey(_ key: String) -> UIImage? {
        return (self.imageCache as! SKImageCacheable).imageForKey(key)
    }

    public func setImage(_ image: UIImage, forKey key: String) {
        (self.imageCache as! SKImageCacheable).setImage(image, forKey: key)
    }

    public func removeImageForKey(_ key: String) {
        (self.imageCache as! SKImageCacheable).removeImageForKey(key)
    }

    public func imageForRequest(_ request: URLRequest) -> UIImage? {
        if let response = (self.imageCache as! SKRequestResponseCacheable).cachedResponseForRequest(request) {
            let data = response.data

            return UIImage(data: data)
        }

        return nil
    }

    public func setImageData(_ data: Data, response: URLResponse, request: URLRequest) {
        let cachedResponse = CachedURLResponse(response: response, data: data)
        (self.imageCache as! SKRequestResponseCacheable).storeCachedResponse(cachedResponse, forRequest: request)
    }
}

class SKDefaultImageCache: SKImageCacheable {
    var cache: Cache<AnyObject, AnyObject>

    init() {
        self.cache = Cache()
    }

    func imageForKey(_ key: String) -> UIImage? {
        return self.cache.object(forKey: key) as? UIImage
    }

    func setImage(_ image: UIImage, forKey key: String) {
        self.cache.setObject(image, forKey: key)
    }

    func removeImageForKey(_ key: String) {
        self.cache.removeObject(forKey: key)
    }
}
