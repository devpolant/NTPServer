//
//  IoTAPIController.swift
//  NTPServer
//
//  Created by Anton Poltoratskyi on 14.05.17.
//
//

import Foundation
import Kitura
import SwiftyJSON

class IoTAPIController: APIRouter {
    
    lazy var router: Router = {
        let router = Router()
        router.post("/login", handler: self.loginClient)
        router.post("/path", handler: self.setPathDirection)
        return router
    }()
    
    // MARK: - Auth
    
    func loginClient(request: RouterRequest, response: RouterResponse, next: () -> Void) throws {
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
        
        let tokenString: String?
        do {
            tokenString = try DBUsersProvider.shared.token(forUserWithId: String(user.id!), destination: .app, from: db, on: connection)
        } catch {
            let errorMessage = "Error while get user token"
            try response.internalServerError(message: errorMessage).end()
            return
        }
        
        let result: [String: Any] = [
            "error": false,
            "access_token": tokenString ?? "",
            "user_id": String(user.id!)
        ]
        response.send(json: result)
    }
    
    // MARK: - Paths
    
    func setPathDirection(request: RouterRequest, response: RouterResponse, next: () -> Void) throws {
        defer { next() }
        
        let requiredFields = ["token", "user_id", "path"]
        
        guard let fields = request.getPost(fields: requiredFields) else {
            try response.badRequest(expected: requiredFields).end()
            return
        }
        let token = fields["token"]!
        let userId = Int(fields["user_id"]!)!
        let path = fields["path"]!
        
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
        
        do {
            try DBUsersProvider.shared.setPathDirection(path, forUserWithId: String(userId), from: db, on: connection)
        } catch {
            try response.internalServerError(message: "Error while set path direction").end()
            return
        }
        
        response.send(json: [
            "error": false
            ])
    }
    
    
    
}

