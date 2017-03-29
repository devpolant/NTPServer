//
//  VKDriver.swift
//  NTPServer
//
//  Created by Anton Poltoratskyi on 28.03.17.
//
//

import Foundation

class VKDriver: SocialDriver {
    
    /*
     https://oauth.vk.com/access_token?client_id=5948504&client_secret=P4ThWqsQhMcM2wkMjW6y&code=d96e12f81e0c9f5e16&redirect_uri=http://localhost:8090/callback
     */
    func auth(with credentials: InitialCredentials, completion: (AuthResult) -> Void) {
        let code = credentials.stringValue
        
        let baseURL = URL(string: "https://oauth.vk.com")!
        
        let parameters: [String: Any] = [
            "client_id": "5948504",
            "client_secret": "",
            "code": code,
            "redirect_uri": "http://localhost:8090/vk_callback"
        ]
        
        guard let json = HTTPManager.shared.get("/access_token", relatedTo: baseURL, parameters: parameters) else {
            completion(.error(AuthError.internalError))
            return
        }
        let tokenString = json["access_token"].stringValue
        let timeInterval = json["expires_in"].doubleValue
        let userId = json["user_id"].stringValue
        
        let accessToken = AccessToken(string: tokenString, expiresIn: timeInterval, userId: userId)
        completion(.success(token: accessToken))
    }
    
    func loadPosts(for group: SocialGroup, offset: Int, count: Int, completion: ([SocialPost]) -> Void) {
        
    }
}
