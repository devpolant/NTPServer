//
//  AccessToken.swift
//  NTPServer
//
//  Created by Anton Poltoratskyi on 30.03.17.
//
//
import SwiftyJSON

/// Used only in OAuth
struct OAuthToken {
    
    var tokenString: String
    var expiresIn: Double
    var userId: String
    
    init(tokenString: String, expiresIn timeInterval: Double, userId: String) {
        self.tokenString = tokenString
        self.expiresIn = timeInterval
        self.userId = userId
    }
}

// MARK: - JSON Convertible

extension OAuthToken {
    
    init(json: JSON) {
        let tokenString = json["access_token"].stringValue
        let expireInterval = json["expires_in"].doubleValue
        let userId = json["user_id"].stringValue
        self.init(tokenString: tokenString, expiresIn: expireInterval, userId: userId)
    }
    
    var dictionaryValue: [String: Any] {
        return [
            "token_string": tokenString,
            "expires_in": expiresIn,
            "user_id": userId
        ]
    }
}
