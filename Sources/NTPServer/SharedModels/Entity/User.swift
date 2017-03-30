//
//  User.swift
//  NTPServer
//
//  Created by Anton Poltoratskyi on 30.03.17.
//
//

import Foundation

class User {
    
    var id: String?
    
    var login: String
    var email: String
    var password: String
    var salt: String
    
    init(id: String? = nil, login: String, email: String, password: String, salt: String) {
        self.login = login
        self.email = email
        self.password = password
        self.salt = salt
    }
}
