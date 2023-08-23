//
//  ImageLoader.swift
//  MovieBrowser
//
//  Created by Michael A. Crawford on 12/14/21.
//  Copyright © 2021 Lowe's Home Improvement. All rights reserved.
//

import Combine
import os.log
import UIKit

/// Based on https://medium.com/flawless-app-stories/reusable-image-cache-in-swift-9b90eb338e8d
/// This class handles the loading and caching of images for `MovieBrowser`.
class ImageLoader: NSObject {
    private let cache = ImageCache(countLimit: 20)
    private let logger = Logger(subsystem: "\(Bundle.main.loggingId)", category: "ImageLoader")

    /// Load images for display in our UI
    ///
    /// This method utilizes and internal instance of ``ImageCache`` to satisfy image requests from callers. If the
    /// image is in the cache, it is returned immediately. If not, the requested image is be fetched from the internet.
    /// The key used for cache lookup is the given URL. In the case of a miss, said URL is used to fetch the image.
    ///
    /// - Parameter url: Used as a key for the internal cache. If there is a cache miss, this parameter is used to fetch
    ///                  the image from the internet.
    /// - Returns: Publisher of type ``UIImage?``. If the image is available in cache or from the URL, the publisher will
    ///            publish the image. If not the publisher will publish `nil`.
    func loadImage(from url: URL) -> AnyPublisher<UIImage?, Never> {
        if let image = cache[url] {
            return Just(image).eraseToAnyPublisher()
        } else {
            logger.debug("Cache miss for \(url.absoluteString)")
            return URLSession.shared.dataTaskPublisher(for: url)
                .receive(on: RunLoop.main)
                .map { (data, /* response */_) -> UIImage? in return UIImage(data: data) }
                .catch { /* error */_ in return Just(nil) }
                .handleEvents(receiveOutput: { [unowned self] image in
                    guard let image = image else { return }
                    self.cache[url] = image
                })
                .eraseToAnyPublisher()
        }
    }

    static let shared = ImageLoader()
}
