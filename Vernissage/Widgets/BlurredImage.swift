//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import SwiftUI

struct BlurredImage: View {
    @State var blurhash: String?
    private let defaultBlurhash = "LFC6ZCso00OZ~q%29FNHE2tRr=RP"
    
    var body: some View {
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
