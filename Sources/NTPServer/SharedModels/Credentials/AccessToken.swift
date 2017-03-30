//
//  AccessToken.swift
//  NTPServer
//
//  Created by Anton Poltoratskyi on 30.03.17.
//
//

struct AccessToken {
    
    var tokenString: String
    var expiresIn: Double
    var userId: String
    
    init(string: String, expiresIn timeInterval: Double, userId: String) {
        self.tokenString = string
        self.expiresIn = timeInterval
        self.userId = userId
    }
}

// MARK: - JSON
extension AccessToken {
    
    var dictionaryValue: [String: Any] {
        return [
            "token_string": tokenString,
            "expires_in": expiresIn,
            "user_id": userId
        ]
    }
}
