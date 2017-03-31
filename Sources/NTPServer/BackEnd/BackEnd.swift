//
//  BackEnd.swift
//  NTPServer
//
//  Created by Anton Poltoratskyi on 28.03.17.
//
//

import Foundation
import Kitura
import SwiftyJSON
import Cryptor
import LoggerAPI


class BackEnd {
    
    lazy var router: Router = {
        
        let router = Router()
        router.post("/", middleware: BodyParser())
        
        router.post("/auth/signup", handler: self.signUpUser)
        router.post("/auth/login", handler: self.loginUser)
        
        return router
    }()
    
    let driver: SocialDriver = VKDriver()
    
    
    // MARK: - Routes
    
    // MARK: Auth
    
    func signUpUser(request: RouterRequest, response: RouterResponse, next: () -> Void) throws {
     
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
            let userId = try DBManager.shared.save(user: user, to: db, on: connection)
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
            try DBManager.shared.addToken(token: token, destination: .app, to: db, on: connection)
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
        let requiredFields = ["login", "password"]
        
        guard let fields = request.getPost(fields: requiredFields) else {
            try response.badRequest(expected: requiredFields).end()
            return
        }
        let login = fields["login"]!
        let password = fields["password"]!
        
        let (db, connection) = try MySQLConnector.connectToDatabase()
        guard let user = try? DBManager.shared.fetchUser(by: login, from: db, on: connection) else {
            return
        }
        
        // Use saved salf from database
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
            try DBManager.shared.deleteExpiredTokens(for: user, destination: .app, from: db, on: connection)
            try DBManager.shared.addToken(token: token, destination: .app, to: db, on: connection)
        } catch {
            let errorMessage = "Error while updating user token"
            try response.internalServerError(message: errorMessage).end()
            return
        }
        
        let result: [String: Any] = [
            "error": false,
            "access_token": token.dictionaryValue
        ]
        response.send(json: result)
    }
    
    
    // MARK: Social Auth
    
    func authSocialUser(request: RouterRequest, response: RouterResponse, next: () -> Void) {
        
        guard let fields = request.getPost(fields: ["code", "redirect_uri"]) else {
            response.status(.badRequest).send("'code' or 'redirect_uri' parameter missed")
            return
        }
        let code = fields["code"]!
        let redirectURI = fields["redirect_uri"]!
        
        let credentials = OAuthCredentials(stringValue: code, redirectURI: redirectURI)
        
        var json: JSON?
        driver.auth(with: credentials) { result in
            switch result {
            case .success(let token):
                json = JSON(["access_token": token.tokenString,
                             "userId": token.userId])
            case .error( _):
                break
            }
        }
        response.send(json: json ?? JSON(["error": true]))
    }
    
}
