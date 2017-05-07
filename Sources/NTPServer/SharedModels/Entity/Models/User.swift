//
//  User.swift
//  NTPServer
//
//  Created by Anton Poltoratskyi on 30.03.17.
//
//

import Foundation

final class User {
    
    var id: Int?
    
    var login: String
    var email: String
    var password: String
    var salt: String
    
    init(id: Int? = nil, login: String, email: String, password: String, salt: String) {
        self.id = id
        self.login = login
        self.email = email
        self.password = password
        self.salt = salt
    }
    
    init(with dictionary: [String: Any]) {
        self.id = dictionary["id"] as? Int
        self.login = dictionary["login"] as! String
        self.email = dictionary["email"] as! String
        self.password = dictionary["password"] as! String
        self.salt = dictionary["salt"] as! String
    }
    
    // MARK: Entity
    
    static let entity: String = "users"
    static var primaryKey: String = "id"
    static var databaseFields: [String] = [
        
    ]
}
