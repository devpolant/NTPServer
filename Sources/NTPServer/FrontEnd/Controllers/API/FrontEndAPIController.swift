//
//  FrontEndViewController.swift
//  NTPServer
//
//  Created by Anton Poltoratskyi on 17.04.17.
//
//

import Foundation
import Kitura
import KituraTemplateEngine
import KituraCORS
import SwiftyJSON
import Cryptor
import LoggerAPI

class FrontEndAPIController {

    struct Path {
        static let auth     = "/web/vendor/auth"
        static let profile  = "/web/vendor/profile"
        static let apps     = "/web/vendor/apps"
    }
    
    let httpController: HttpController
    
    init(baseApiURL: URL) {
        self.httpController = HttpController(baseApiURL: baseApiURL)
    }
    
    
    // MARK: - Auth
    
    func login(request: RouterRequest, response: RouterResponse, next: () -> Void) throws {
        let requiredFields = ["email", "password"]
        
        guard let fields = request.getPost(fields: requiredFields) else {
            try response.badRequest(expected: requiredFields).end()
            return
        }
        
        let loginResult = httpController.post("\(Path.auth)/login", fields: fields)
        guard let jsonResult = loginResult else {
            return
        }
        response.send(json: jsonResult)
    }
    
    func signUp(request: RouterRequest, response: RouterResponse, next: () -> Void) throws {
        
        let requiredFields = ["login", "email", "password", "confirm_password"]
        
        guard let fields = request.getPost(fields: requiredFields) else {
            try response.badRequest(expected: requiredFields).end()
            return
        }
        
        let password = fields["password"]!
        let confirmPassword = fields["confirm_password"]!
        
        guard password == confirmPassword else {
            try response.badRequest(message: "Password doesn't match").end()
            return
        }
        
        let signupResult = httpController.post("\(Path.auth)/signup", fields: fields)
        guard let jsonResult = signupResult else {
            return
        }
        response.send(json: jsonResult)
    }
    
    
    // MARK: - Profile
    
    func getVendorProfile(request: RouterRequest, response: RouterResponse, next: () -> Void) throws {
        defer { next() }
        
        let requiredFields = ["token"]
        guard let fields = request.getPost(fields: requiredFields) else {
            try response.badRequest(expected: requiredFields).end()
            return
        }
        
        let appsListResult = httpController.post("\(Path.profile)", fields: fields)
        guard let jsonResult = appsListResult else {
            return
        }
        response.send(json: jsonResult)
    }

    
    // MARK: - Apps
    
    func appsList(request: RouterRequest, response: RouterResponse, next: () -> Void) throws {
        defer { next() }
        
        let requiredFields = ["token"]
        guard let fields = request.getPost(fields: requiredFields) else {
            try response.badRequest(expected: requiredFields).end()
            return
        }
        
        let appsListResult = httpController.post("\(Path.apps)/list", fields: fields)
        guard let jsonResult = appsListResult else {
            return
        }
        response.send(json: jsonResult)
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
        
        let appInfoResult = httpController.post("\(Path.apps)/\(appId)/info", fields: fields)
        guard let jsonResult = appInfoResult else {
            return
        }
        response.send(json: jsonResult)
    }
    
    func createApp(request: RouterRequest, response: RouterResponse, next: () -> Void) throws {
        defer { next() }
        
        let requiredFields = ["token", "name", "location", "social_group"]
        guard let fields = request.getPost(fields: requiredFields) else {
            try response.badRequest(expected: requiredFields).end()
            return
        }
        
        let createResult = httpController.post("\(Path.apps)/create", fields: fields)
        guard let jsonResult = createResult else {
            return
        }
        response.send(json: jsonResult)
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
        
        let updateResult = httpController.post("\(Path.apps)/\(appId)/update", fields: fields)
        guard let jsonResult = updateResult else {
            return
        }
        response.send(json: jsonResult)
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
        
        let deleteResult = httpController.post("\(Path.apps)/\(appId)/delete", fields: fields)
        guard let jsonResult = deleteResult else {
            return
        }
        response.send(json: jsonResult)
    }
    
}
