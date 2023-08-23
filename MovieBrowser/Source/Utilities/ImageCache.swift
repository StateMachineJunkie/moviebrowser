//
//  ImageCache.swift
//  CombineAlamofireApp
//
//  Created by Michael A. Crawford on 5/28/21.
//  Copyright © 2021 CDE, LLC. All rights reserved.
//

import os.log
import UIKit

@objc protocol ImageCacheDelegate {
    func imageCache(_ imageCache: ImageCache, willEvictImage image: UIImage)
}

/// Implements UI image caching based on unique URL absolutes string values.
///
/// This utility is implemented on top of ``NSCache``. In the near future, I'd
/// like to make this an `actor` class but for now I'm delaying as I've heard
/// rumors of bugs in the release builds of Apple concurrency model for `async/await`.
/// I also have no idea what kind of performance overhead this might produce.
/// For now, the best practice is to always invoke the methods for this class
/// from the same thread context (usually main). If this practice is not followed,
/// you will have concurrency issues and undefined behavior.
class ImageCache: NSObject {

    /// Default initializer.
    /// - Parameter countLimit: The maximum number of objects the ache should hold
    ///                         A value of zero indicates that the cache should hold
    ///                         as many objects as it can until there is a memory
    ///                         crisis. Only then should it begin to evict objects.
    ///                         This behavior is controlled and determined by the
    ///                         underlying ``NSCache`` implementation.
    init(countLimit: Int = 0) {
        super.init()
        cache.countLimit = countLimit
        cache.delegate = self
    }

    private let cache = NSCache<NSString, UIImage>()
    weak var delegate: ImageCacheDelegate?

    /// Return the cached `UIImage` object associated with the given `URL` value.
    /// - Parameter url: Uniquely identifies the desired image.
    /// - Returns: Associated `UIImage` or `nil` if not found.
    func image(for url: URL) -> UIImage? {
        return cache.object(forKey: url.absoluteString as NSString)
    }

    /// Remove the cached `UIImage` object associated with the given `URL` value.
    ///
    /// If their is a matching cache entry for the given `URL` key, it will be
    /// removed from the cache and discarded. If not this call will silently fail.
    /// - Parameter url: Uniquely identifies the desired image.
    func removeImage(for url: URL) {
        cache.removeObject(forKey: url.absoluteString as NSString)
    }

    /// Store the given `URL`/`UIImage` key/value pair in the cache.
    /// - Parameters:
    ///   - image: The image object to be stored in the cache.
    ///   - url: The key to be associated with the image.
    /// - Note: If the given key is already existing, its associated value will be
    ///         overridden with the given image.
    func setImage(_ image: UIImage, for url: URL) {
        cache.setObject(image, forKey: url.absoluteString as NSString)
    }
}

extension ImageCache {
    subscript(_ url: URL) -> UIImage? {
        get {
            return image(for: url)
        }
        set {
            guard let image = newValue else {
                removeImage(for: url)
                return
            }
            return setImage(image, for: url)
        }
    }
}

extension ImageCache: NSCacheDelegate {
    func cache(_ cache: NSCache<AnyObject, AnyObject>, willEvictObject obj: Any) {
        delegate?.imageCache(self, willEvictImage: obj as! UIImage)
    }
}
