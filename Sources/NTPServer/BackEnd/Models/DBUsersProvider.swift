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
    case tokenNotFound(destination: TokenDestination)
}

enum TokenDestination {
    case app
    case vk
    
    var identifier: Int {
        switch self {
        case .vk:
            return SocialNetwork.vk.identifier
        case .app:
            return Int.max
        }
    }
}

class DBUsersProvider {
    
    static let shared = DBUsersProvider()
    
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
        
        // Delete current tokens and add new token for appropriate destination.
        try self.deleteExpiredTokens(forUserWithId: token.userId.stringValue,
                                     destination: destination,
                                     from: database,
                                     on: connection)
        
        try database.execute("INSERT INTO `tokens` (token_string, expires_in, user_id, token_destination) VALUES (?, ?, ?, ?);",
                             [token.tokenString, token.expiresIn, token.userId, destination.identifier],
                             connection)
    }
    
    func setOAuthToken(_ token: OAuthToken, forUserWithId userId: Int, to database: Database, on connection: Connection) throws {
        
        let accessToken = AccessToken(string: token.tokenString,
                                      expiresIn: token.expiresIn,
                                      userId: Int(token.userId)!)
        
        try self.addToken(accessToken, destination: .vk, to: database, on: connection)
    }
    
    func getOAuthTokenForUser(with userId: Int, to database: Database, on connection: Connection) throws -> String? {
        return try findToken(forUserWithId: userId.stringValue, destination: .vk, from: database, on: connection)
    }
    
    
    func findToken(forUserWithId userId: String, destination: TokenDestination, from database: Database, on connection: Connection) throws -> String?  {
        
        let tokens = try database.execute("SELECT * FROM `user_tokens` WHERE user_id = ? AND token_destination = ?",
                                          [userId, destination.identifier],
                                          connection)
        
        
        guard let token = tokens.first else {
            throw DBError.tokenNotFound(destination: destination)
        }
        return token["token_string"]?.string
    }
    
    func deleteExpiredTokens(forUserWithId userId: String, destination: TokenDestination, from database: Database, on connection: Connection) throws {
        // Delete all tokens for user at now.
        
        try database.execute("DELETE FROM `user_tokens` WHERE user_id = ? AND token_destination = ?",
                             [userId, destination.identifier],
                             connection)
    }
    
}
