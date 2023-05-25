//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation
import SwiftUI

/// Service is storing orginal image sizes.
/// Very often images doesn't have size in metadataa (especially for services other then Pixelfed).
/// After download image from server we can check his size and remember in the cache.
///
/// When we want to prepare placeholder for specfic image and container witdh we have to use special method.
public class ImageSizeService {
    public static let shared = ImageSizeService()
    private init() { }

    /// Cache with orginal image sizes.
    private var memoryCacheData = MemoryCache<URL, CGSize>(entryLifetime: 3600)

    public func get(for url: URL) -> CGSize? {
        return self.memoryCacheData[url]
    }

    public func save(for url: URL, width: Int32, height: Int32) {
        save(for: url, width: Double(width), height: Double(height))
    }

    public func save(for url: URL, width: Int, height: Int) {
        save(for: url, width: Double(width), height: Double(height))
    }

    public func save(for url: URL, width: Double, height: Double) {
        self.memoryCacheData.insert(CGSize(width: width, height: height), forKey: url)
    }
}

extension ImageSizeService {
    public func calculate(for url: URL, andContainerWidth containerWidth: Double) -> CGSize {
        guard let size = self.get(for: url) else {
            return CGSize(width: containerWidth, height: containerWidth)
        }

        return self.calculate(width: size.width, height: size.height, andContainerWidth: containerWidth)
    }

    public func calculate(width: Double, height: Double, andContainerWidth containerWidth: Double) -> CGSize {
        let divider = Double(width) / containerWidth
        let calculatedHeight = Double(height) / divider

        let size = CGSize(
            width: containerWidth,
            height: (calculatedHeight > 0 && calculatedHeight < .infinity) ? calculatedHeight : containerWidth
        )

        return size
    }
}
