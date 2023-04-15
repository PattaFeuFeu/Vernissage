//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import SwiftUI

public struct BlurredImage: View {
    private let blurhash: String?

    public init(blurhash: String? = nil) {
        self.blurhash = blurhash
    }

    public var body: some View {
        if let blurhash, let uiImage = UIImage(blurHash: blurhash, size: CGSize(width: 32, height: 32)) {
            Image(uiImage: uiImage)
                .resizable()
        } else {
            Image("Blurhash")
                .resizable()
        }
    }
}

struct BlurredImage_Previews: PreviewProvider {
    static var previews: some View {
        BlurredImage()
    }
}
