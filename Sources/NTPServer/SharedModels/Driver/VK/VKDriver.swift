//
//  VKDriver.swift
//  NTPServer
//
//  Created by Anton Poltoratskyi on 28.03.17.
//
//

import Foundation
import SwiftyJSON

class VKDriver: SocialDriver {
    
    func auth(with credentials: OAuthCredentials, completion: (Result<OAuthToken>) -> Void) {
        
        let authResult = VKAuthService.shared.authorize(app: VK.App.current, credentials: credentials)
        
        switch authResult {
        case let .success(json):
            let accessToken = OAuthToken(json: json)
            completion(.success(value: accessToken))
        case let .error(authError):
            completion(.error(authError))
        }
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
            "v": VK.API.version
        ]
        
        let json = HTTPManager.shared.get("/method/wall.get", relatedTo: VK.API.baseURL, parameters: parameters)
        
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
            
            var photoURL: String?
            
            let attachments = jsonObject["attachments"].arrayValue
            
            if let attachment = attachments.first {
                if attachment["type"].stringValue == "photo" {
                    let photoDict = attachment["photo"].dictionaryValue
                    
                    if let photo604 = photoDict["photo_604"]?.stringValue {
                        photoURL = photo604
                    } else if let photo130 = photoDict["photo_130"]?.stringValue {
                        photoURL = photo130
                    }
                }
            }
            
            return Post(id: id, timestamp: timestamp, text: text, photoUrl: photoURL)
        }
        completion(parsedPosts)
    }
}
