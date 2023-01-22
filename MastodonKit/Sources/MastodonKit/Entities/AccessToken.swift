//
//  https://mczachurski.dev
//  Copyright © 2022 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import Foundation
import OAuthSwift

/// Access token returned by the server.
public struct AccessToken: Codable {
    
    /// Access token.
    public let token: String
    
    private enum CodingKeys: String, CodingKey {
        case token = "access_token"
    }
    
    #warning("This needs to be refactored, refresh token and other properties need to be available")
    public init(credential: OAuthSwiftCredential) {
        self.token = credential.oauthToken
    }
}
