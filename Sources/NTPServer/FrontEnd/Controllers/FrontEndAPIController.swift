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

class FrontEndAPIController: APIController {

    /// Data Layer server url
    let baseApiURL: URL
    
    /// Name of folder, which contains template files
    let templateFolder: String
    
    init(baseApiURL: URL, templateFolder: String) {
        self.baseApiURL = baseApiURL
        self.templateFolder = templateFolder
    }

    lazy var router: Router = {
        
        let router = Router()
        
        router.get("/", handler: self.getMainPage)
        
        let authRouter = router.route("/auth")
        
        authRouter.post("/login", handler: self.login)
        authRouter.route("/signup")
            .get(handler: self.getSignUpPage)
            .post(handler: self.signUp)
        
        router.get("/profile", handler: self.getProfilePage)
        
        let dashboardRouter = router.route("/dashboard")
        dashboardRouter.get(handler: self.getDashboardPage)
        dashboardRouter.route("/apps")
            .get("/create", handler: self.getCreateAppPage)
            .get("/:id/info", handler: self.getSelectedAppPage)
        
        return router
    }()
    
    
    // MARK: - Auth
    
    // MARK: Login
    
    func getMainPage(request: RouterRequest, response: RouterResponse, next: () -> Void) throws {
        defer { next() }
        try response.render("\(templateFolder)/index", context: [:])
    }
    
    func login(request: RouterRequest, response: RouterResponse, next: () -> Void) throws {
        let requiredFields = ["email", "password"]
        
        guard let fields = request.getPost(fields: requiredFields) else {
            try response.badRequest(expected: requiredFields).end()
            return
        }
        
        guard let loginResult = HTTPManager.shared.post("/web/vendor/auth/login",
                                                         relatedTo: baseApiURL,
                                                         fields: fields) else {
                                                            return
        }
        response.send(json: loginResult)
    }
    
    // MARK: Sign Up
    
    func getSignUpPage(request: RouterRequest, response: RouterResponse, next: () -> Void) throws {
        defer { next() }
        try response.render("\(templateFolder)/signup", context: [:])
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
        
        guard let signupResult = HTTPManager.shared.post("/web/vendor/auth/signup",
                                                         relatedTo: baseApiURL,
                                                         fields: fields)?.dictionaryObject else {
                                                            return
        }
        response.send(json: signupResult)
    }
    
    // MARK: - Profile
    
    func getProfilePage(request: RouterRequest, response: RouterResponse, next: () -> Void) throws {
        defer { next() }
        try response.render("\(templateFolder)/user_profile", context: [:])
    }
    
    // MARK: - Dashboard
    
    func getDashboardPage(request: RouterRequest, response: RouterResponse, next: () -> Void) throws {
        defer { next() }
        try response.render("\(templateFolder)/dashboard", context: [:])
    }
    
    // MARK: Apps
    
    func getCreateAppPage(request: RouterRequest, response: RouterResponse, next: () -> Void) throws {
        defer { next() }
        try response.render("\(templateFolder)/create_app", context: [:])
    }
    
    func getSelectedAppPage(request: RouterRequest, response: RouterResponse, next: () -> Void) throws {
        defer { next() }
        try response.render("\(templateFolder)/selected_app", context: [:])
    }

}
