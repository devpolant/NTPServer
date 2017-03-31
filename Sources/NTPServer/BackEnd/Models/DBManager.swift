//
//  DBManager.swift
//  NTPServer
//
//  Created by Anton Poltoratskyi on 30.03.17.
//
//

import Foundation
import MySQL

enum DBError: Swift.Error {
    case couldNotSave
    case userNotFound
}

enum TokenDestination {
    case app
    case vk
    
    var identifier: Int {
        switch self {
        case .vk:
            return SocialNetwork.vk.identifier
        case .app:
            return 1000
        }
    }
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
        // FIXME: return id in another way
        
        return try fetchUser(by: user.login, from: database, on: connection).id!
    }
    
    func fetchUser(by login: String, from database: Database, on connection: Connection) throws -> User {
        
        let query = "SELECT * FROM `users` WHERE `login` = ?;"
        let users = try database.execute(query, [login], connection)
        
        guard let user = users.first else {
            throw DBError.userNotFound
        }
        
        var userDictionary = [String: Any]()
        userDictionary["id"] = user["id"]?.int
        userDictionary["login"] = user["login"]?.string
        userDictionary["email"] = user["email"]?.string
        userDictionary["password"] = user["password"]?.string
        userDictionary["salt"] = user["salt"]?.string
        
        return User(with: userDictionary)
    }
    
    // MARK: - Tokens
    
    func addToken(_ token: AccessToken, destination: TokenDestination, to database: Database, on connection: Connection) throws {
        try database.execute("INSERT INTO `tokens` (token_string, expires_in, user_id, token_destination) VALUES (?, ?, ?, ?);",
                             [token.tokenString, token.expiresIn, token.userId, destination.identifier],
                             connection)
    }
    
    func setOAuthToken(_ token: OAuthToken, forUserWithId userId: Int, to database: Database, on connection: Connection) throws {
        
        // TODO: update this logic
        
        try database.execute("UPDATE `users` SET oauth_token = ? WHERE id = ?;",
                             [token.tokenString, userId],
                             connection)
    }
    
    func getOAuthTokenForUser(with userId: Int, to database: Database, on connection: Connection) throws -> String? {
        
        // TODO: update this logic
        
        let query = "SELECT * FROM `users` WHERE `id` = ?;"
        let users = try database.execute(query, [userId], connection)
        
        guard let user = users.first else {
            throw DBError.userNotFound
        }
        return user["oauth_token"]?.string
    }
    
    
    
    func deleteExpiredTokens(for user: User, destination: TokenDestination, from database: Database, on connection: Connection) throws {
        // Delete all tokens for user at now.
        
        let userID = String(user.id!)
        try database.execute("DELETE FROM `tokens` WHERE user_id = ? AND token_destination = ?",
                             [userID, destination.identifier],
                             connection)
    }
    
}
