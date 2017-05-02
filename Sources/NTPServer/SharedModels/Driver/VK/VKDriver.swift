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
    
    func auth(with credentials: OAuthCredentials, completion: AuthCompletion) {
        
        let authResult = VKAuthService.shared.authorize(app: VK.App.current, credentials: credentials)
        
        switch authResult {
        case let .success(json):
            let accessToken = OAuthToken(json: json)
            completion(.success(value: accessToken))
        case let .error(authError):
            completion(.error(authError))
        }
    }
    
    func loadPosts(for category: SocialCategory,
                   wallFilter: VKWallService.WallFilter,
                   offset: Int,
                   count: Int,
                   token: String,
                   completion: PostsCompletion) {
        
//        let parameters: [String: Any] = [
//            "domain": category.domain,
////            "owner_id": -1,
//            "offset": offset,
//            "count": count,
//            "filter": "owner",
//            "extended": true,
//            "access_token": token,
//            "v": VK.API.version
//        ]
//        
//        let json = HTTPManager.shared.get("/method/wall.get", relatedTo: VK.API.baseURL, parameters: parameters)
        
        let responseResult = VKWallService.shared.wall(for: category,
                                                       wallFilter: wallFilter,
                                                       token: token,
                                                       offset: offset,
                                                       count: count)
        
        guard case let .success(json) = responseResult else {
            if case let .error(wallError) = responseResult {
                completion(.error(wallError))
            }
            return
        }
        
        let response = json["response"]
        
        guard let posts = response["items"].array else {
            completion(.success(value: []))
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
        completion(.success(value: parsedPosts))
    }
}
