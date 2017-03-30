//
//  DBManager.swift
//  NTPServer
//
//  Created by Anton Poltoratskyi on 30.03.17.
//
//

import Foundation
import MySQL

enum DBError {
    case couldNotSave
}

class DBManager {
    
    static let shared = DBManager()
    
    private init() {}
    
    // MARK: - Users
    
    /// Returns id of created user
    func save(user: User, to database: Database, on connection: Connection) throws -> Int {
        try database.execute("INSERT INTO `users` (login, email, password, salt) VALUES (?, ?, ?, ?);",
                             [user.login, user.email, user.password, user.salt],
                             connection)
        // FIXME: return correct id
        return 0
    }
    
    func fetchUser(by login: String, from database: Database, on connection: Connection) throws -> User {
        return User(id: nil, login: "", email: "", password: "", salt: "")
    }
    
    // MARK: - Tokens
    
    func addToken(token: AccessToken, to database: Database, on connection: Connection) throws {
        try database.execute("INSERT INTO `tokens` (string_value, expires, user_id) VALUES (?, ?, ?);",
                             [token.tokenString, token.expiresIn, token.userId],
                             connection)
    }
    
    func deleteExpiredTokens(from database: Database, on connection: Connection) throws {
        // try db.execute("DELETE FROM `tokens` WHERE `expires` < NOW()", [], connection)
    }
    
}
