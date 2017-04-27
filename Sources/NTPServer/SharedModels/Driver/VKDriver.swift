//
//  VKDriver.swift
//  NTPServer
//
//  Created by Anton Poltoratskyi on 28.03.17.
//
//

import Foundation

private struct VKAPI {
    static let baseURL = URL(string: "https://api.vk.com")!
    static let apiVersion = "5.63"
}

class VKDriver: SocialDriver {
    
    func auth(with credentials: OAuthCredentials, completion: (AuthResult<OAuthToken>) -> Void) {
        
        let code = credentials.stringValue
        let redirectURI = credentials.redirectURI
        
        let baseURL = URL(string: "https://oauth.vk.com")!
        
        let parameters: [String: Any] = [
            "client_id": "5948504",
            "client_secret": "P4ThWqsQhMcM2wkMjW6y",
            "code": code,
            "redirect_uri": redirectURI
        ]
        
        guard let json = HTTPManager.shared.get("/access_token", relatedTo: baseURL, parameters: parameters) else {
            completion(.error(AuthError.internalError))
            return
        }
        let tokenString = json["access_token"].stringValue
        let timeInterval = json["expires_in"].doubleValue
        let userId = json["user_id"].stringValue
        
        let accessToken = OAuthToken(string: tokenString, expiresIn: timeInterval, userId: userId)
        completion(.success(token: accessToken))
    }
    
    func loadPosts(for group: SocialGroup, offset: Int, count: Int, token: String, completion: ([SocialPost]) -> Void) {
        
        let parameters: [String: Any] = [
            "domain": group,
//            "owner_id": -1,
            "offset": offset,
            "count": count,
            "filter": "owner",
            "extended": true,
            "access_token": token,
            "v": VKAPI.apiVersion
        ]
        
        let json = HTTPManager.shared.get("/method/wall.get", relatedTo: VKAPI.baseURL, parameters: parameters)
        
        guard let response = json?["response"] else {
            completion([])
            return
        }
        
        guard let posts = response["items"].array else {
            completion([])
            return
        }
        
        let parsedPosts = posts.map { jsonObject -> SocialPost in
            let id = jsonObject["id"].stringValue
            let timestamp = jsonObject["date"].intValue
            let text = jsonObject["text"].stringValue
            return Post(id: id, timestamp: timestamp, text: text)
        }
        completion(parsedPosts)
    }
}
