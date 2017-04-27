//
//  MobileAPIController.swift
//  NTPServer
//
//  Created by Anton Poltoratskyi on 17.04.17.
//
//

import Foundation
import Kitura
import SwiftyJSON
import Cryptor
import LoggerAPI

class MobileAPIController: APIRouter {
    
    lazy var router: Router = {
        let router = Router()
        
        router.post("/auth/signup", handler: self.signUpUser)
        router.post("/auth/login", handler: self.loginUser)
        
        router.post("/oauth/vk", handler: self.authSocialUser)
        
        router.post("/posts/list", handler: self.getWallPosts)
        
        return router
    }()
    
    
    let driver: SocialDriver = VKDriver()
    
    
    // MARK: - Auth
    
    func signUpUser(request: RouterRequest, response: RouterResponse, next: () -> Void) throws {
        defer { next() }
        
        let requiredFields = ["login", "email", "password"]
        
        guard let fields = request.getPost(fields: requiredFields) else {
            try response.badRequest(expected: requiredFields).end()
            return
        }
        let (db, connection) = try MySQLConnector.connectToDatabase()
        try db.execute("SET autocommit=0;", [], connection)
        
        let login = fields["login"]!
        let email = fields["email"]!
        let password = fields["password"]!
        
        let saltString: String
        if let salt = try? Random.generate(byteCount: 64) {
            saltString = CryptoUtils.hexString(from: salt)
        } else {
            saltString = "\(login)\(email)\(password)".digest(using: .sha512)
        }
        
        let encryptedPassword = CryptoManager.shared.password(from: password, salt: saltString)
        
        let user = User(login: login,
                        email: email,
                        password: encryptedPassword,
                        salt: saltString)
        
        // Save user
        
        // TODO: check if email already exists
        
        do {
            let userId = try DBUsersProvider.shared.save(user: user, to: db, on: connection)
            user.id = userId
        } catch {
            let errorMessage = "Error while saving user"
            try response.internalServerError(message: errorMessage).end()
            return
        }
        guard let userId = user.id else { return }
        
        // Save token
        
        let token = AccessToken(string: UUID().uuidString,
                                expiresIn: 0,
                                userId: userId)
        
        do {
            try DBUsersProvider.shared.addToken(token, destination: .app, to: db, on: connection)
        } catch {
            let errorMessage = "Error while saving user access token"
            try response.internalServerError(message: errorMessage).end()
            return
        }
        
        try db.execute("COMMIT;", [], connection)
        
        let result: [String: Any] = [
            "error": false,
            "access_token": token.dictionaryValue
        ]
        response.send(json: result)
    }
    
    func loginUser(request: RouterRequest, response: RouterResponse, next: () -> Void) throws {
        defer { next() }
        
        let requiredFields = ["login", "password"]
        
        guard let fields = request.getPost(fields: requiredFields) else {
            try response.badRequest(expected: requiredFields).end()
            return
        }
        let login = fields["login"]!
        let password = fields["password"]!
        
        let (db, connection) = try MySQLConnector.connectToDatabase()
        guard let user = try? DBUsersProvider.shared.fetchUser(by: login, from: db, on: connection) else {
            return
        }
        
        // Use saved salt from database
        let encryptedPassword = CryptoManager.shared.password(from: password,
                                                              salt: user.salt)
        
        guard encryptedPassword == user.password else {
            try response.badRequest(message: "Wrong password or login").end()
            return
        }
        
        // Update token
        
        let token = AccessToken(string: UUID().uuidString,
                                expiresIn: 0,
                                userId: user.id!)
        do {
            try DBUsersProvider.shared.deleteExpiredTokens(forUserWithId: user.id!.stringValue,
                                                           destination: .app,
                                                           from: db, on: connection)
            try DBUsersProvider.shared.addToken(token, destination: .app, to: db, on: connection)
        } catch {
            let errorMessage = "Error while updating user token"
            try response.internalServerError(message: errorMessage).end()
            return
        }
        
        let result: [String: Any] = [
            "error": false,
            "access_token": token.dictionaryValue,
            "user_login": user.login,
            "user_email": user.email
        ]
        response.send(json: result)
    }
    
    
    // MARK: OAuth
    
    func authSocialUser(request: RouterRequest, response: RouterResponse, next: () -> Void) throws {
        defer { next() }
        
        let requiredFields = ["user_id", "code", "redirect_uri"]
        
        guard let fields = request.getPost(fields: requiredFields) else {
            try response.badRequest(expected: requiredFields).end()
            return
        }
        let code = fields["code"]!
        let redirectURI = fields["redirect_uri"]!
        let userId = Int(fields["user_id"]!)!
        
        let credentials = OAuthCredentials(stringValue: code, redirectURI: redirectURI)
        
        var json: JSON?
        driver.auth(with: credentials) { result in
            switch result {
            case .success(let token):
                
                do {
                    let (db, connection) = try MySQLConnector.connectToDatabase()
                    try DBUsersProvider.shared.setOAuthToken(token, forUserWithId: userId, to: db, on: connection)
                } catch {
                    let errorMessage = "Error while set user oauth token"
                    try? response.internalServerError(message: errorMessage).end()
                    return
                }
                
                json = JSON(["error": false,
                             "message": "Authorized"])
            case .error( _):
                break
            }
        }
        response.send(json: json ?? JSON(["error": true]))
    }
    
    
    // MARK: - Posts
    
    func getWallPosts(request: RouterRequest, response: RouterResponse, next: () -> Void) throws {
        defer { next() }
        
        let requiredFields = ["token", "app_id", "count", "offset", "user_id"]
        
        guard let fields = request.getPost(fields: requiredFields) else {
            try response.badRequest(expected: requiredFields).end()
            return
        }
        let token = fields["token"]!
        let userId = Int(fields["user_id"]!)!
        
        // Check token
        
        let (db, connection) = try MySQLConnector.connectToDatabase()
        var savedToken: String?
        do {
            savedToken = try DBUsersProvider.shared.token(forUserWithId: String(userId),
                                                          destination: .app,
                                                          from: db,
                                                          on: connection)
        } catch {
            let errorMessage = "Error while checking token"
            try? response.internalServerError(message: errorMessage).end()
            return
        }

        guard let validToken = savedToken, validToken == token else {
            let errorMessage = "Invalid token"
            try response.internalServerError(message: errorMessage).end()
            return
        }
        
        // Fetch social token
        
        var oAuthToken: String?
        do {
            oAuthToken = try DBUsersProvider.shared.getOAuthTokenForUser(with: userId, to: db, on: connection)
        } catch {
            let errorMessage = "Error while loading posts"
            try? response.internalServerError(message: errorMessage).end()
            return
        }
        guard let socialToken = oAuthToken else { return }
        
        // Fetch social group to parse for app with id
        
        let appId = Int(fields["app_id"]!)!
        
        var socialGroupToParse: String?
        do {
            let category = try DBVendorProvider.shared.firstCategory(forApp: appId,
                                                                     from: db,
                                                                     on: connection)
            socialGroupToParse = category.socialGroupDomainName
        } catch {
            let errorMessage = "Error while loading app social group URL to parse"
            try? response.internalServerError(message: errorMessage).end()
            return
        }
        
        guard let socialGroup = socialGroupToParse else { return }
        
        let count = Int(fields["count"]!)!
        let offset = Int(fields["offset"]!)!
        
        var posts = [[String: Any]]()
        driver.loadPosts(for: socialGroup, offset: offset, count: count, token: socialToken) { socialPosts in
            
            let postsJSON = socialPosts.map { post -> [String: Any] in
                post.dictionaryValue
            }
            posts.append(contentsOf: postsJSON)
        }
        
        response.send(json: [
            "error": false,
            "posts": posts
            ])
    }
    
    
}
