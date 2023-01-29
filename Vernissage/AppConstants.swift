//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//
    
import Foundation

public struct AppConstants {
    public static let oauthApplicationName = "Vernissage"
    public static let oauthScheme = "oauth-vernissage"
    public static let oauthCallbackPart = "oauth-callback"
    public static let oauthRedirectUri = "\(AppConstants.oauthScheme)://\(oauthCallbackPart)/pixelfed"
    public static let oauthScopes = ["read", "write", "follow", "push"]
  
    public static let imagePipelineCacheName = "dev.mczachurski.Vernissage.DataCache"
    public static let coreDataPersistantContainerName = "Vernissage"
}
