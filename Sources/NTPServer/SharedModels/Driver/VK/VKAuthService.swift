//
//  VKAuthManager.swift
//  NTPServer
//
//  Created by Anton Poltoratskyi on 01.05.17.
//
//

import Foundation
import SwiftyJSON

struct VKAuthService {
    
    private struct Path {
        static let baseURL = URL(string: "https://oauth.vk.com")!
        static let token = "/access_token"
    }
    
    private struct AuthParameters {
        let app: VK.App
        let credentials: OAuthCredentials
        
        var dictionary: [String: Any] {
            return [
                "client_id": app.clientId,
                "client_secret": app.clientSecret,
                "redirect_uri": app.redirectURI,
                "code": credentials.code
            ]
        }
    }
    
    static let shared = VKAuthService()
    private init() {}
    
    func authorize(app: VK.App, credentials: OAuthCredentials) -> Result<JSON> {
        
        let parameters = AuthParameters(app: app, credentials: credentials)
        let json = HTTPManager.shared.get(Path.token, relatedTo: Path.baseURL, parameters: parameters.dictionary)
        
        guard let jsonObject = json else {
            return .error(AuthError.internalError)
        }
        return .success(value: jsonObject)
    }
}
