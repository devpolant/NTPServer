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
    
    let templateEngine: TemplateEngine
    
    init(templateEngine: TemplateEngine) {
        self.templateEngine = templateEngine
    }
    
    lazy var router: Router = {
        
        let router = Router()
//        router.setDefault(templateEngine: self.templateEngine)
        
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
        
        do {
            try response.render("/stencil/index", context: [:])
        } catch {
            print(error)
            return
        }
    }
    
    func signUpUser(request: RouterRequest, response: RouterResponse, next: () -> Void) throws {
        defer { next() }
        
        try response.render("/stencil/signup", context: [:])
    }
    
    // MARK: - Profile
    
    func getProfile(request: RouterRequest, response: RouterResponse, next: () -> Void) throws {
        defer { next() }
        
        try response.render("/stencil/user_profile", context: [:])
    }
    
    // MARK: - Dashboard
    
    func getDashboard(request: RouterRequest, response: RouterResponse, next: () -> Void) throws {
        defer { next() }
        
        try response.render("/stencil/dashboard", context: [:])
    }
    
    // MARK: Apps
    
    func createApp(request: RouterRequest, response: RouterResponse, next: () -> Void) throws {
        defer { next() }
        
        try response.render("/stencil/create_app", context: [:])
    }
    
    func selectedApp(request: RouterRequest, response: RouterResponse, next: () -> Void) throws {
        defer { next() }
        
        try response.render("/stencil/selected_app", context: [:])
    }

}
