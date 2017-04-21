//
//  WebController.swift
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

class WebAPIController: APIRouter {
    
    lazy var router: Router = {
        let router = Router()
        
        router.post("/vendor/auth/signup", handler: self.signUpVendor)
        router.post("/vendor/auth/login", handler: self.loginVendor)
        
        router.post("/vendor/profile", handler: self.getVendorProfile)
        router.post("/vendor/profile/update", handler: self.updateVendorProfile)
        
        router.post("/vendor/apps/list", handler: self.appsList)            // List
        router.post("/vendor/apps/:id/info", handler: self.appInfo)         // Read
        router.post("/vendor/apps/create", handler: self.createApp)         // Insert
        router.post("/vendor/apps/:id/update", handler: self.updateApp)     // Update
        router.post("/vendor/apps/:id/delete", handler: self.deleteApp)     // Delete
        
        return router
    }()
    
    
    // MARK: - Routes
    
    // MARK: Auth
    
    func signUpVendor(request: RouterRequest, response: RouterResponse, next: () -> Void) throws {
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
        let tokenString = UUID().uuidString
        
        let vendor = Vendor(login: login, email: email, password: encryptedPassword, salt: saltString, token: tokenString)
        
        // Save vendor
        
        // TODO: check if login or email already exists
        
        do {
            let id = try DBVendorProvider.shared.insertVendor(vendor, to: db, on: connection)
            vendor.id = id
        } catch {
            let errorMessage = "Error while saving Vendor"
            try response.internalServerError(message: errorMessage).end()
            return
        }
        
        try db.execute("COMMIT;", [], connection)
        
        let result: [String: Any] = [
            "error": false,
            "access_token": vendor.token
        ]
        response.send(json: result)
    }
    
    func loginVendor(request: RouterRequest, response: RouterResponse, next: () -> Void) throws {
        defer { next() }
        
        let requiredFields = ["email", "password"]
        
        guard let fields = request.getPost(fields: requiredFields) else {
            try response.badRequest(expected: requiredFields).end()
            return
        }
        let (db, connection) = try MySQLConnector.connectToDatabase()
        try db.execute("SET autocommit=0;", [], connection)
        
        let email = fields["email"]!
        let password = fields["password"]!
        
        guard let vendor = try? DBVendorProvider.shared.fetchVendor(withEmail: email, from: db, on: connection) else {
            let errorMessage = "Vendor not found"
            try response.badRequest(message: errorMessage).end()
            return
        }
        
        // Use saved salt from database
        let encryptedPassword = CryptoManager.shared.password(from: password,
                                                              salt: vendor.salt)
        
        guard encryptedPassword == vendor.password else {
            try response.badRequest(message: "Wrong password or login").end()
            return
        }
        let tokenString = UUID().uuidString
        vendor.token = tokenString
        
        // Update vendor token
        
        do {
            // FIXME: update works incorrect now
//            try DBVendorProvider.shared.updateVendor(vendor, in: db, on: connection)
        } catch {
            let errorMessage = "Error while updating Vendor's token"
            try response.internalServerError(message: errorMessage).end()
            return
        }
        
        try db.execute("COMMIT;", [], connection)
        
        let result: [String: Any] = [
            "error": false,
            "access_token": vendor.token
        ]
        response.send(json: result)
    }
    
    // MARK: Profile
    
    func getVendorProfile(request: RouterRequest, response: RouterResponse, next: () -> Void) throws {
        defer { next() }
        
        let requiredFields = ["token"]
        guard let fields = request.getPost(fields: requiredFields) else {
            try response.badRequest(expected: requiredFields).end()
            return
        }
        
        let token = fields["token"]!
        
        let (db, connection) = try MySQLConnector.connectToDatabase()
        guard let vendor = try? DBVendorProvider.shared.fetchVendor(withToken: token, from: db, on: connection) else {
            return
        }
        
        let result: [String: Any] = [
            "error": false,
            "profile": vendor.responseDictionary
        ]
        response.send(json: result)
    }
    
    func updateVendorProfile(request: RouterRequest, response: RouterResponse, next: () -> Void) throws {
        defer { next() }
        
        let requiredFields = ["token", "login", "email"]
        guard let fields = request.getPost(fields: requiredFields) else {
            try response.badRequest(expected: requiredFields).end()
            return
        }
        let token = fields["token"]!
        let login = fields["login"]!
        let email = fields["email"]!
        
        // TODO: check if login or email exists
        
        let (db, connection) = try MySQLConnector.connectToDatabase()
        guard let vendor = try? DBVendorProvider.shared.fetchVendor(withToken: token, from: db, on: connection) else {
            return
        }
        vendor.login = login
        vendor.email = email
        
        // Update vendor
        
        do {
            try DBVendorProvider.shared.updateVendor(vendor, in: db, on: connection)
        } catch {
            let errorMessage = "Error while updating Vendor"
            try response.internalServerError(message: errorMessage).end()
            return
        }
        
        let result: [String: Any] = [
            "error": false,
            "access_token": vendor.token
        ]
        response.send(json: result)
    }
    
    
    // MARK: - Apps
    
    func appsList(request: RouterRequest, response: RouterResponse, next: () -> Void) throws {
        defer { next() }
        
        let requiredFields = ["token"]
        guard let fields = request.getPost(fields: requiredFields) else {
            try response.badRequest(expected: requiredFields).end()
            return
        }
        
        let token = fields["token"]!
        
        let (db, connection) = try MySQLConnector.connectToDatabase()
        guard let vendor = try? DBVendorProvider.shared.fetchVendor(withToken: token, from: db, on: connection) else {
            return
        }
        
        var apps: [App]
        do {
            apps = try DBVendorProvider.shared.fetchApps(forVendorWithId: vendor.id!, from: db, on: connection)
        } catch {
            let errorMessage = "Error while loading vendor apps"
            try response.internalServerError(message: errorMessage).end()
            return
        }
        
        let appsResponse = apps.map { $0.responseDictionary }
        
        let result: [String: Any] = [
            "error": false,
            "apps": appsResponse
        ]
        response.send(json: result)
    }
    
    func appInfo(request: RouterRequest, response: RouterResponse, next: () -> Void) throws {
        defer { next() }
        
        guard let appId = request.queryParameters["id"]?.int else {
            try response.badRequest(expected: ["id"]).end()
            return
        }
        
        let requiredFields = ["token"]
        guard let fields = request.getPost(fields: requiredFields) else {
            try response.badRequest(expected: requiredFields).end()
            return
        }
        
        let token = fields["token"]!
        let (db, connection) = try MySQLConnector.connectToDatabase()
        guard let _ = try? DBVendorProvider.shared.fetchVendor(withToken: token, from: db, on: connection) else {
            return
        }
        
        var app: App
        do {
            app = try DBVendorProvider.shared.fetchApp(with: appId, from: db, on: connection)
        } catch {
            let errorMessage = "Error while loading app with id=\(appId)"
            try response.internalServerError(message: errorMessage).end()
            return
        }
        
        let result: [String: Any] = [
            "error": false,
            "app": app.responseDictionary
        ]
        response.send(json: result)
    }
    
    func createApp(request: RouterRequest, response: RouterResponse, next: () -> Void) throws {
        defer { next() }
        
        let requiredFields = ["token", "name", "location", "social_group"]
        guard let fields = request.getPost(fields: requiredFields) else {
            try response.badRequest(expected: requiredFields).end()
            return
        }
        
        let token = fields["token"]!
        let (db, connection) = try MySQLConnector.connectToDatabase()
        try db.execute("SET autocommit=0;", [], connection)
        guard let vendor = try? DBVendorProvider.shared.fetchVendor(withToken: token, from: db, on: connection) else {
            return
        }
        
        let name = fields["name"]!
        let location = fields["location"]!
        let socialGroupToParse = fields["social_group"]!
        
        let app = App(name: name, location: location, vendorId: vendor.id!, status: AppStatus.active.stringValue)
        do {
            let appId = try DBVendorProvider.shared.insertApp(app, to: db, on: connection)
            app.id = appId
        } catch {
            let errorMessage = "Error while creating app for vendor with id=\(vendor.id!)"
            try response.internalServerError(message: errorMessage).end()
            return
        }
        
        // TODO: customize category name
        let category = Category(name: name,
                                appId: app.id!,
                                socialGroupURL: socialGroupToParse,
                                socialNetworkId: SocialNetwork.vk.identifier)
        do {
            try DBVendorProvider.shared.insertCategory(category, to: db, on: connection)
        } catch {
            let errorMessage = "Error while creating category for app with id=\(app.id!)"
            try response.internalServerError(message: errorMessage).end()
            return
        }
        
        try db.execute("COMMIT;", [], connection)
        
        let result: [String: Any] = [
            "error": false,
            "created_app_id": app.id!
        ]
        response.send(json: result)
    }
    
    func updateApp(request: RouterRequest, response: RouterResponse, next: () -> Void) throws {
        defer { next() }
        
        guard let appId = request.queryParameters["id"]?.int else {
            try response.badRequest(expected: ["id"]).end()
            return
        }
        
        let requiredFields = ["token", "name", "location", "social_group"]
        guard let fields = request.getPost(fields: requiredFields) else {
            try response.badRequest(expected: requiredFields).end()
            return
        }
        
        let token = fields["token"]!
        let (db, connection) = try MySQLConnector.connectToDatabase()
        try db.execute("SET autocommit=0;", [], connection)
        guard (try? DBVendorProvider.shared.fetchVendor(withToken: token, from: db, on: connection)) != nil else {
            return
        }
        
        // Update App
        
        let app: App
        do {
            app = try DBVendorProvider.shared.fetchApp(with: appId, from: db, on: connection)
        } catch {
            let errorMessage = "Error while fetching app with id=\(appId)"
            try response.internalServerError(message: errorMessage).end()
            return
        }
        
        let name = fields["name"]!
        let location = fields["location"]!
        let socialGroupToParse = fields["social_group"]!
        
        app.name = name
        app.location = location
        
        do {
            try DBVendorProvider.shared.updateApp(app, in: db, on: connection)
        } catch {
            let errorMessage = "Error while updating app with id=\(appId)"
            try response.internalServerError(message: errorMessage).end()
            return
        }
        
        // Update category
        
        let category: Category
        do {
            category = try DBVendorProvider.shared.firstCategory(forApp: appId, from: db, on: connection)
        } catch {
            let errorMessage = "Error while fetching category for app with id=\(appId), description=\(error)"
            try response.internalServerError(message: errorMessage).end()
            return
        }
        
        category.socialGroupURL = socialGroupToParse
        do {
            try DBVendorProvider.shared.updateCategory(category, in: db, on: connection)
        } catch {
            let errorMessage = "Error while updating category with id=\(category.id!), description=\(error)"
            try response.internalServerError(message: errorMessage).end()
            return
        }
        
        try db.execute("COMMIT;", [], connection)
        
        let result: [String: Any] = [
            "error": false
        ]
        response.send(json: result)
    }
    
    func deleteApp(request: RouterRequest, response: RouterResponse, next: () -> Void) throws {
        defer { next() }
        
        guard let appId = request.queryParameters["id"]?.int else {
            try response.badRequest(expected: ["id"]).end()
            return
        }
        
        let requiredFields = ["token"]
        guard let fields = request.getPost(fields: requiredFields) else {
            try response.badRequest(expected: requiredFields).end()
            return
        }
        
        let token = fields["token"]!
        let (db, connection) = try MySQLConnector.connectToDatabase()
        try db.execute("SET autocommit=0;", [], connection)
        guard let _ = try? DBVendorProvider.shared.fetchVendor(withToken: token, from: db, on: connection) else {
            return
        }
        
        do {
            try DBVendorProvider.shared.deleteApp(with: appId, from: db, on: connection)
        } catch {
            let errorMessage = "Error while deleting app with id=\(appId), description=\(error)"
            try response.internalServerError(message: errorMessage).end()
            return
        }
        try db.execute("COMMIT;", [], connection)
        
        let result: [String: Any] = [
            "error": false,
            "deleted_app_id": appId
        ]
        response.send(json: result)
    }
    
}
