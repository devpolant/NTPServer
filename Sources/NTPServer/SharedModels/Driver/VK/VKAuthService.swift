//
//  VKAuthManager.swift
//  NTPServer
//
//  Created by Anton Poltoratskyi on 01.05.17.
//
//

import Foundation
import SwiftyJSON

class VKAuthService {
    
    static let shared = VKAuthService()
    private init() {}
    
    private struct Path {
        static let baseURL = URL(string: "https://oauth.vk.com")!
        static let token = "/access_token"
    }
    
    private struct AuthRequest {
        let app: VK.App
        let credentials: OAuthCredentials
        
        var parameters: [String: Any] {
            return [
                "client_id": app.clientId,
                "client_secret": app.clientSecret,
                "redirect_uri": app.redirectURI,
                "code": credentials.code
            ]
        }
    }
    
    func authorize(app: VK.App, credentials: OAuthCredentials) -> Result<JSON> {
        
        let request = AuthRequest(app: app, credentials: credentials)
        let json = HTTPManager.shared.get(Path.token, relatedTo: Path.baseURL, parameters: request.parameters)
        
        guard let jsonObject = json else {
            return .error(AuthError.internalError)
        }
        return .success(value: jsonObject)
    }
}
