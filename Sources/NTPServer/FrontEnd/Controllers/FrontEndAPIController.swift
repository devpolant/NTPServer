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
import SwiftyJSON
import Cryptor
import LoggerAPI

class FrontEndAPIController: APIController {

    /// Name of folder, which contains template files
    let templateFolder: String
    
    init(templateFolder: String) {
        self.templateFolder = templateFolder
    }
    
    lazy var router: Router = {
        
        let router = Router()
        
        router.get("/", handler: self.loginUser)
        router.get("/signup", handler: self.signUpUser)
        
        router.get("/profile", handler: self.getProfile)
        
        router.get("/dashboard", handler: self.getDashboard)
        router.get("/dashboard/apps/create", handler: self.createApp)
        
        return router
    }()
    
    
    // MARK: - Auth
    
    func loginUser(request: RouterRequest, response: RouterResponse, next: () -> Void) throws {
        defer { next() }
        
        try response.render("\(templateFolder)/index", context: [:])
    }
    
    func signUpUser(request: RouterRequest, response: RouterResponse, next: () -> Void) throws {
        defer { next() }
        
        try response.render("\(templateFolder)/signup", context: [:])
    }
    
    // MARK: - Profile
    
    func getProfile(request: RouterRequest, response: RouterResponse, next: () -> Void) throws {
        defer { next() }
        
        try response.render("\(templateFolder)/user_profile", context: [:])
    }
    
    // MARK: - Dashboard
    
    func getDashboard(request: RouterRequest, response: RouterResponse, next: () -> Void) throws {
        defer { next() }
        
        try response.render("\(templateFolder)/dashboard", context: [:])
    }
    
    // MARK: Apps
    
    func createApp(request: RouterRequest, response: RouterResponse, next: () -> Void) throws {
        defer { next() }
        
        try response.render("\(templateFolder)/create_app", context: [:])
    }
    
    func selectedApp(request: RouterRequest, response: RouterResponse, next: () -> Void) throws {
        defer { next() }
        
        try response.render("\(templateFolder)/selected_app", context: [:])
    }

}
