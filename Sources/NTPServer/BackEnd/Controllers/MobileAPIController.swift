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
        router.post("/apps/:id", handler: self.getCurrentAppInfo)
        
        router.post("/posts/list", handler: self.getWallPosts)
        
        router.post("/path", handler: self.getPathDirection)
        
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
        
        let requiredFields = ["user_id", "code"]
        
        guard let fields = request.getPost(fields: requiredFields) else {
            try response.badRequest(expected: requiredFields).end()
            return
        }
        let userId = Int(fields["user_id"]!)!
        let code = fields["code"]!
        
        let credentials = OAuthCredentials(code: code)
        
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
    
    
    // MARK: - App
    
    func getCurrentAppInfo(request: RouterRequest, response: RouterResponse, next: () -> Void) throws {
        defer { next() }
        
        guard let appId = request.parameters["id"]?.int else {
            try response.badRequest(expected: ["id"]).end()
            return
        }
        
        let requiredFields = ["token", "user_id"]
        
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
        
        // Fetch app
        
        var app: App
        do {
            app = try DBVendorProvider.shared.fetchApp(with: appId, from: db, on: connection)
        } catch {
            let errorMessage = "Error while loading app with id=\(appId)"
            try response.internalServerError(message: errorMessage).end()
            return
        }
        
        // Fetch categories
        
        var categories: [Category]
        do {
            categories = try DBVendorProvider.shared.fetchCategories(forApp: appId, from: db, on: connection)
        } catch {
            let errorMessage = "Error while loading categories for app with id=\(appId)"
            try response.internalServerError(message: errorMessage).end()
            return
        }
        
        var appResponseDictionary = app.responseDictionary
        appResponseDictionary["categories"] = categories.map { $0.responseDictionary }
        
        let result: [String: Any] = [
            "error": false,
            "app": appResponseDictionary
        ]
        response.send(json: result)
    }
    
    
    // MARK: - Posts
    
    func getWallPosts(request: RouterRequest, response: RouterResponse, next: () -> Void) throws {
        defer { next() }
        
        let requiredFields = ["token", "count", "offset", "user_id", "category_id", "owners_only"]
        
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
        
        // Fetch social group to parse for category with id
        
        let categoryId = Int(fields["category_id"]!)!
        var category: Category?
        do {
            category = try DBVendorProvider.shared.fetchCategory(with: categoryId, from: db, on: connection)
        } catch {
            let errorMessage = "Error while loading app social group URL to parse"
            try? response.internalServerError(message: errorMessage).end()
            return
        }
        
        guard let socialCategory = category else { return }
        
        let count = Int(fields["count"]!)!
        let offset = Int(fields["offset"]!)!
        let ownersOnly: Bool = Int(fields["owners_only"]!)! != 0
        let wallFilter: VKWallService.WallFilter = ownersOnly ? .owner : .all
        
        var posts = [[String: Any]]()
        driver.loadPosts(for: socialCategory,
                         wallFilter: wallFilter,
                         offset: offset,
                         count: count,
                         token: socialToken) { result in
            
                            switch result {
                            case let .success(socialPosts):
                                let postsJSON = socialPosts.map { post -> [String: Any] in
                                    post.dictionaryValue
                                }
                                posts.append(contentsOf: postsJSON)
                            case .error(_):
                                break
                            }
        }
        
        response.send(json: [
            "error": false,
            "posts": posts
            ])
    }
    
    
    // MARK: - Path Direction
    
    func getPathDirection(request: RouterRequest, response: RouterResponse, next: () -> Void) throws {
        defer { next() }
        
        let requiredFields = ["token", "user_id"]
        
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
        
        var path: String?
        do {
            path = try DBUsersProvider.shared.getPathDirection(forUserWithId: String(userId), from: db, on: connection)
        } catch {
            try response.internalServerError(message: "Error while get path direction").end()
            return
        }
        
        response.send(json: [
            "error": false,
            "path": path ?? ""
            ])
    }
}
