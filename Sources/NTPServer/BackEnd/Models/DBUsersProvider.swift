//
//  DBManager.swift
//  NTPServer
//
//  Created by Anton Poltoratskyi on 30.03.17.
//
//

import Foundation
import MySQL

enum TokenDestination {
    case app
    case vk
    
    var identifier: Int {
        switch self {
        case .vk:
            return SocialNetwork.vk.identifier
        case .app:
            return Int(Int32.max)
        }
    }
}

class DBUsersProvider {
    
    static let shared = DBUsersProvider()
    
    private init() {}
    
    // MARK: - Users
    
    // MARK: Save
    
    /// Returns id of created user
    @discardableResult
    func save(user: User, to database: Database, on connection: Connection) throws -> Int {
        try database.execute("INSERT INTO `\(User.entity)` (login, email, password, salt) VALUES (?, ?, ?, ?);",
                             [user.login, user.email, user.password, user.salt],
                             connection)
        return try fetchUser(by: user.login, from: database, on: connection).id!
    }
    
    // MARK: Fetch
    
    func fetchUser(by login: String, from database: Database, on connection: Connection) throws -> User {
        
        let query = "SELECT * FROM `\(User.entity)` WHERE `login` = ?;"
        let arguments: [NodeRepresentable] = [login]
        
        let users = try database.execute(query, arguments, connection)
        guard let userNode = users.first else {
            throw DBError.entityNotFound(entityName: User.entity)
        }
        return User(with: userNode)
    }
    
    
    // MARK: - Tokens
    
    func addToken(_ token: AccessToken, destination: TokenDestination, to database: Database, on connection: Connection) throws {
        
        // Delete current tokens and add new token for appropriate destination ('app' or 'vk').
        try self.deleteExpiredTokens(forUserWithId: token.userId.stringValue,
                                     destination: destination,
                                     from: database,
                                     on: connection)
        
        let insertQuery = "INSERT INTO `\(UserToken.entity)` (token_string, expires_in, user_id, token_destination) VALUES (?, ?, ?, ?);"
        let arguments: [NodeRepresentable] = [token.tokenString, token.expiresIn, token.userId, destination.identifier]
        try database.execute(insertQuery, arguments, connection)
    }
    
    // MARK: OAuth
    
    func setOAuthToken(_ token: OAuthToken, forUserWithId userId: Int, to database: Database, on connection: Connection) throws {
        
        // Convert OAuth token to app token
        let accessToken = AccessToken(string: token.tokenString,
                                      expiresIn: token.expiresIn,
                                      userId: userId)
        
        try self.addToken(accessToken, destination: .vk, to: database, on: connection)
    }
    
    func getOAuthTokenForUser(with userId: Int, to database: Database, on connection: Connection) throws -> String? {
        return try token(forUserWithId: userId.stringValue, destination: .vk, from: database, on: connection)
    }
    
    // MARK: Fetch
    
    func token(forUserWithId userId: String, destination: TokenDestination, from database: Database, on connection: Connection) throws -> String?  {
        
        let findQuery = "SELECT * FROM `\(UserToken.entity)` WHERE user_id = ? AND token_destination = ?;"
        let arguments: [NodeRepresentable] = [userId, destination.identifier]
        
        let tokens = try database.execute(findQuery, arguments, connection)
        guard let token = tokens.first else {
            throw DBError.tokenNotFound(destination: destination)
        }
        return token["token_string"]?.string
    }
    
    // MARK: Delete
    
    func deleteExpiredTokens(forUserWithId userId: String, destination: TokenDestination, from database: Database, on connection: Connection) throws {
        // Delete all tokens for user at now.
        
        let deleteQuery = "DELETE FROM `\(UserToken.entity)` WHERE user_id = ? AND token_destination = ?;"
        let arguments: [NodeRepresentable] = [userId, destination.identifier]
        
        try database.execute(deleteQuery, arguments, connection)
    }
    
    
    // MARK: - Path Directions
    
    // MARK: Read
    
    func getPathDirection(forUserWithId userId: String, from database: Database, on connection: Connection) throws -> String? {
        let query = "SELECT path FROM `\(User.entity)` WHERE id = ?;"
        let arguments: [NodeRepresentable] = [userId]
        
        let result = try database.execute(query, arguments, connection)
        guard let first = result.first, let path = first["path"]?.string else {
            return nil
        }
        return path
    }
    
    // MARK: Update
    
    func setPathDirection(_ path: String, forUserWithId userId: String, from database: Database, on connection: Connection) throws {
        let query = "UPDATE `\(User.entity)` SET path = ? WHERE id = ?;"
        let arguments: [NodeRepresentable] = [path, userId]
        
        try database.execute(query, arguments, connection)
    }
    
}
