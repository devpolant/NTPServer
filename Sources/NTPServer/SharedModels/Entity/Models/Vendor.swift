//
//  Vendor.swift
//  NTPServer
//
//  Created by Anton Poltoratskyi on 17.04.17.
//
//

import Foundation

final class Vendor {
    
    var id: Int?
    
    var login: String
    var email: String
    var password: String
    var salt: String
    var token: String
    
    init(id: Int? = nil, login: String, email: String, password: String, salt: String, token: String) {
        self.id = id
        self.login = login
        self.email = email
        self.password = password
        self.salt = salt
        self.token = token
    }
    
    init(with dictionary: [String: Any]) {
        self.id = dictionary["id"] as? Int
        self.login = dictionary["login"] as! String
        self.email = dictionary["email"] as! String
        self.password = dictionary["password"] as! String
        self.salt = dictionary["salt"] as! String
        self.token = dictionary["token"] as! String
    }
}

// MARK: - Entity

extension Vendor: Entity {
    static let entity: String = "vendors"
}

// MARK: - Response

extension Vendor {
    var responseDictionary: [String: Any] {
        var result: [String: Any] = [
            "login": login,
            "email": email,
            "token": token
        ]
        if let id = id {
            result["id"] = id
        }
        return result
    }
}
